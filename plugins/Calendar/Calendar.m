//
//  Calendar.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/9/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "Calendar.h"
#import "Device.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface Calendar ()
@property(nonatomic)EKEventStore *_eventStore;
@property(nonatomic)EKCalendar *_calendar;
@property(nonatomic)NSArray *_eventsList;
@property(nonatomic)NSMutableArray *_invalideUids;
@end

@implementation Calendar
@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _calendar;
@synthesize _eventsList;
@synthesize _eventStore;
@synthesize _invalideUids;

- (id) init
{
    if ((self=[super init])) {
        _pluginDelegate=nil;
        _device=nil;
        _eventStore = [[EKEventStore alloc] init];
        _eventsList = [NSArray array];
        _invalideUids = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(storeChanged:)
                                                    name:EKEventStoreChangedNotification  object:_eventStore];
        [self checkEventStoreAccessForCalendar];
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_CALENDAR]) {
        NSLog(@"Calendar plugin receive a package");
        if ([np bodyHasKey:@"request"]) {
            //send calender event list
            [self fetchEvents];
            if ([_eventsList count]==0) {
                NetworkPackage* np2=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CALENDAR];
                [np2 setBool:YES forKey:@"request"];
                [_device sendPackage:np2 tag:PACKAGE_TAG_CALENDAR];
            }else{
                [self sendCalendar];
            }
        }
        else {
            NSError* err;
            EKEvent* event=[Calendar retrieveEvent:np withStore:_eventStore error:&err];
            
            if ([err.domain isEqualToString:@"iCal parse failed"]) {
                return true;
            }
            
            if ([[np objectForKey:@"op"] isEqualToString:@"delete"]){
                [_eventStore removeEvent:event span:EKSpanThisEvent error:&err];
                if (err) {
                    NSLog(@"Calendar plugin:delete event error");
                }
            }
            else if ([[np objectForKey:@"op"] isEqualToString:@"merge"]){
                
                if ([err.domain isEqualToString:@"iCal fix uid"]) {
                    NSString* uid=[[err userInfo] objectForKey:@"uid"];
                    if (![_invalideUids containsObject:uid]) {
                        NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CALENDAR];
                        [np setObject:@"delete" forKey:@"op"];
                        [np setObject:uid forKey:@"uid"];
                        [_device sendPackage:np tag:PACKAGE_TAG_CALENDAR];
                        [_invalideUids addObject:uid];
                    }
                }

                EKEvent* oldEvent=[_eventStore eventWithIdentifier:event.eventIdentifier];
                if (!oldEvent){
                    [_eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                }
                else if (![Calendar event:event isIdenToEvent:oldEvent]){
                    [_eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                }
                else if ( [err.domain isEqualToString: @"iCal peer outdated"]){
                    [self sendCalendar];
                }
            }
        }
        return true;
    }
    return false;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Calendar" displayName:@"Calendar" description:@"Calendar" enabledByDefault:true];
}

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             [self accessGrantedForCalendar];
         }
     }];
}

// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    _calendar = _eventStore.defaultCalendarForNewEvents;
    // Fetch all events happening in the next 24 hours and put them into eventsList
    [self fetchEvents];
}

// Fetch all events happening in the next 24 hours
- (void) fetchEvents
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    NSDate *startDate= [calendar dateFromComponents:components];
    
    
    //Create the end date components
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = 2;
	
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
	// We will only search the default calendar for our events
	NSArray *calendarArray = [NSArray arrayWithObject:_calendar];
    
    // Create the predicate
	NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:calendarArray];
	
	// Fetch all events that match the predicate
	_eventsList =[_eventStore eventsMatchingPredicate:predicate];
}

- (void) storeChanged:(id) sender
{
    [self fetchEvents];
    [self sendCalendar];
}

- (void) sendCalendar
{
    for (EKEvent* e in _eventsList) {
        NetworkPackage* np=[Calendar createNetworkPackage:e];
        [np setObject:@"merge" forKey:@"op"];
        [_device sendPackage:np tag:PACKAGE_TAG_CALENDAR];
    }
}

+ (BOOL) event:(EKEvent*) event1 isIdenToEvent:(EKEvent*) event2
{
    if (![event1.title isEqualToString:event2.title] ||
        ![event1.startDate isEqualToDate:event2.startDate] ||
        ![event1.endDate isEqualToDate:event2.endDate]) {
        return false;
    }
    return true;
}

+ (EKEvent*) retrieveEvent:(NetworkPackage*)np withStore:(EKEventStore*) eventstore error:( NSError*__autoreleasing*)err
{
    return [Calendar iCalToEvent:[np objectForKey:@"iCal"] withStore:eventstore error:err];
}

+ (NetworkPackage*) createNetworkPackage: (EKEvent*)event
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CALENDAR];
    NSString* ical=[Calendar EventToiCal:event];
    if (!ical) {
        return nil;
    }
    [np setObject:ical forKey:@"iCal"];
    return np;
}

+ (EKEvent*) iCalToEvent: (NSString*) iCal withStore:(EKEventStore*) eventstore error:( NSError*__autoreleasing*)err
{

    NSCharacterSet* set=[NSCharacterSet characterSetWithCharactersInString:@"\r "];
    NSCharacterSet* set2=[NSCharacterSet characterSetWithCharactersInString:@";:= "];

    NSArray* strArray=[iCal componentsSeparatedByString:@"\n"];
    NSString* uid;
    NSString* summary;
    NSDate* dt_s;
    NSDate* dt_e;
    NSDate* dt_created;
    NSDate* dt_modified;
    NSDateFormatter* df=[[NSDateFormatter alloc] init];
    NSTimeZone *timezone;
    BOOL uid_finished=true;
    for (NSString* string in strArray) {
        NSString* str=[string stringByTrimmingCharactersInSet:set];
        if (!uid_finished) {
            uid=[NSString stringWithFormat:@"%@%@",uid,str];
            uid_finished=true;
        }
        if ([str hasPrefix:@"UID:"]) {
            uid= [str substringFromIndex:4];
            if ([str hasSuffix:@":"]) {
                uid_finished=false;
            }
        }
        if ([str hasPrefix:@"SUMMARY:"]) {
            summary=[str substringFromIndex:8];
        }
        if ([str hasPrefix:@"DTSTART"]) {
            NSArray* split=[str componentsSeparatedByCharactersInSet:set2];
            if ([str hasSuffix:@"Z"]) {
                timezone=[NSTimeZone timeZoneWithName:@"UTC"];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
                dt_s=[df dateFromString:[split lastObject]];
            }
            else{
                if (![split[1] isEqualToString:@"TZID"]) {
                    continue;
                }
                NSString* tz=[split objectAtIndex:[split count]-2];
                timezone=[NSTimeZone timeZoneWithName:tz];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss"];
                dt_s=[df dateFromString:[split lastObject]];
            }
        }
        if ([str hasPrefix:@"DTEND"]) {
            NSArray* split=[str componentsSeparatedByCharactersInSet:set2];
            if ([str hasSuffix:@"Z"]) {
                timezone=[NSTimeZone timeZoneWithName:@"UTC"];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
                dt_e=[df dateFromString:[split lastObject]];
            }
            else{
                if (![split[1] isEqualToString:@"TZID"]) {
                    continue;
                }
                NSString* tz=[split objectAtIndex:[split count]-2];
                timezone=[NSTimeZone timeZoneWithName:tz];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss"];
                dt_e=[df dateFromString:[split lastObject]];
            }
        }
        if ([str hasPrefix:@"CREATED"]) {
            NSArray* split=[str componentsSeparatedByCharactersInSet:set2];
            if ([str hasSuffix:@"Z"]) {
                timezone=[NSTimeZone timeZoneWithName:@"UTC"];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
                dt_created=[df dateFromString:[split lastObject]];
            }
            else{
                if (![split[1] isEqualToString:@"TZID"]) {
                    continue;
                }
                NSString* tz=[split objectAtIndex:[split count]-2];
                timezone=[NSTimeZone timeZoneWithName:tz];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss"];
                dt_created=[df dateFromString:[split lastObject]];
            }
        }
        if ([str hasPrefix:@"LAST-MODIFIED"]) {
            NSArray* split=[str componentsSeparatedByCharactersInSet:set2];
            if ([str hasSuffix:@"Z"]) {
                timezone=[NSTimeZone timeZoneWithName:@"UTC"];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
                dt_modified=[df dateFromString:[split lastObject]];
            }
            else{
                if (![split[1] isEqualToString:@"TZID"]) {
                    continue;
                }
                NSString* tz=[split objectAtIndex:[split count]-2];
                timezone=[NSTimeZone timeZoneWithName:tz];
                [df setTimeZone:timezone];
                [df setDateFormat:@"yyyyMMdd'T'HHmmss"];
                dt_modified=[df dateFromString:[split lastObject]];
            }
        }
    }
    if (!uid||!summary||!dt_s) {
        *err=[[NSError alloc] initWithDomain:@"iCal parse failed" code:0 userInfo:nil];
        return nil;
    }
    if (!dt_e) {
        dt_e=[dt_e dateByAddingTimeInterval:3600];
    }
    EKEvent* event=[eventstore eventWithIdentifier:uid];
    if (!event) {
        event=[EKEvent eventWithEventStore:eventstore];
        [event setCalendar:[eventstore defaultCalendarForNewEvents]];
        [event setTitle:summary];
        [event setStartDate:dt_s];
        [event setEndDate:dt_e];
        [event setCalendar:[eventstore defaultCalendarForNewEvents]];
        *err=[[NSError alloc] initWithDomain:@"iCal fix uid" code:1 userInfo:@{@"uid": uid}];
        return event;
    }
    if ( (![summary isEqualToString:event.title] ||
        ![dt_s isEqualToDate:event.startDate] ||
        ![dt_e isEqualToDate:event.endDate])
        && [event.lastModifiedDate compare:dt_modified]==NSOrderedAscending) {
        [event setTitle:summary];
        [event setStartDate:dt_s];
        [event setEndDate:dt_e];
        [event setCalendar:[eventstore defaultCalendarForNewEvents]];
    }
    if ([event.lastModifiedDate compare:dt_modified]==NSOrderedDescending) {
        *err=[[NSError alloc] initWithDomain:@"iCal peer outdated" code:1 userInfo:nil];
    }
    return event;
}

+ (NSString*) EventToiCal: (EKEvent*)event
{
    if (!event || [event.title isEqualToString:@""]) {
        return nil;
    }
    NSDateFormatter* df=[[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    [df setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
    NSString* t=event.title;
    NSString* dt_stamp=[df stringFromDate:[event creationDate]];
    NSString* dt_created=[df stringFromDate:[event creationDate]];
    NSString* dt_modified=[df stringFromDate:[event lastModifiedDate]];
    NSString* dt_s=[df stringFromDate:[event startDate]];
    NSString* dt_e=[df stringFromDate:[event endDate]];
    NSMutableString* iCal=[NSMutableString string];
    [iCal appendString:@"BEGIN:VCALENDAR\n"];
    [iCal appendString:@"VERSION:2.0\n"];
    [iCal appendString:@"PRODID:-//kde//kdeconnect-ios v0.1/EN\n"];
    [iCal appendString:@"BEGIN:VEVENT\n"];
    [iCal appendFormat:@"DTSTAMP:%@\n",dt_stamp];
    [iCal appendFormat:@"CREATED:%@\n",dt_created];
    [iCal appendFormat:@"LAST_MODIFIED:%@\n",dt_modified];
    [iCal appendFormat:@"UID:%@\n",[event eventIdentifier]];
    [iCal appendFormat:@"SUMMARY:%@\n",t];
    [iCal appendFormat:@"DTSTART:%@\n",dt_s];
    [iCal appendFormat:@"DTEND:%@\n",dt_e];
    [iCal appendFormat:@"TRANSP:OPAQUE\n"];
    [iCal appendString:@"END:VEVENT\n"];
    [iCal appendString:@"END:VCALENDAR\n"];
    return iCal;
}
@end
