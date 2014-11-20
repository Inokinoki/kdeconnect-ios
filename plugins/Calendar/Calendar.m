//Copyright 9/7/14  YANG Qiao yangqiao0505@me.com
//kdeconnect is distributed under two licenses.
//
//* The Mozilla Public License (MPL) v2.0
//
//or
//
//* The General Public License (GPL) v2.1
//
//----------------------------------------------------------------------
//
//Software distributed under these licenses is distributed on an "AS
//IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
//implied. See the License for the specific language governing rights
//and limitations under the License.
//kdeconnect is distributed under both the GPL and the MPL. The MPL
//notice, reproduced below, covers the use of either of the licenses.
//
//----------------------------------------------------------------------

#import "Calendar.h"
#import "Device.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "XBICalendar.h"

@interface Calendar ()
@property(nonatomic)EKEventStore *_eventStore;
@property(nonatomic)NSArray *_eventsList;
@property(nonatomic)NSMutableArray *_invalideUids;
@property(nonatomic)BOOL _shouldSend;
@property(nonatomic)BOOL _isProcessing;
@end

@implementation Calendar
@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _eventsList;
@synthesize _eventStore;
@synthesize _invalideUids;
@synthesize _shouldSend;
@synthesize _isProcessing;

- (id) init
{
    if ((self=[super init])) {
        _pluginDelegate=nil;
        _device=nil;
        _eventStore = [[EKEventStore alloc] init];
        _eventsList = [NSArray array];
        _invalideUids = [NSMutableArray array];
        _shouldSend=false;
        _isProcessing=false;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(storeChanged:)
                                                    name:EKEventStoreChangedNotification  object:_eventStore];
        [self checkEventStoreAccessForCalendar];
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_CALENDAR]) {
        //NSLog(@"Calendar plugin receive a package");
        if ([np bodyHasKey:@"request"]) {
            //send calender event list
            [self fetchEvents];
            if ([_eventsList count]==0) {
                NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CALENDAR];
                [np setBool:YES forKey:@"request"];
                [_device sendPackage:np tag:PACKAGE_TAG_CALENDAR];
            }
            _shouldSend=true;
            [self sendCalendar];
        }
        else {
            if ([ [np objectForKey:@"status"] isEqualToString:@"begin"]) {
                _isProcessing=true;
                return true;
            }
            else if ([ [np objectForKey:@"status"] isEqualToString:@"end"] ) {
                _isProcessing=false;
                [self fetchEvents];
                [self sendCalendar];
                return true;
            }
            else{
                _isProcessing=true;
            }
            
            NSError* err;
            EKEvent* event=[Calendar retrieveEvent:np withStore:_eventStore error:&err];
            
            if ([err.domain isEqualToString:@"iCal parse failed"]) {
                return true;
            }
            
            if ([[np objectForKey:@"op"] isEqualToString:@"delete"]){
                [_eventStore removeEvent:event span:nil commit:YES error:&err];
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
                if (!oldEvent ||
                    ![Calendar event:event isIdenToEvent:oldEvent]){
                    [_eventStore saveEvent:event span:nil commit:YES error:&err];
                    _shouldSend=true;
                }
            }
        }
        return true;
    }
    return false;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"Calendar" displayName:NSLocalizedString(@"Calendar",nil) description:NSLocalizedString(@"Calendar",nil) enabledByDefault:true];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Warning",nil) message:NSLocalizedString(@"Permission was not granted for Calendar",nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
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
    tomorrowDateComponents.day = 6;
	
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
    
    // Create the predicate
	NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:nil];
	
	// Fetch all events that match the predicate
	_eventsList =[_eventStore eventsMatchingPredicate:predicate];
}

- (void) storeChanged:(id) sender
{
    _shouldSend=true;
    [self fetchEvents];
    [self sendCalendar];
}

- (void) sendCalendar
{
    if ( _isProcessing || !_shouldSend)
        return;
    
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CALENDAR];
    [np setObject:@"merge" forKey:@"op"];
    [np setObject:@"begin" forKey:@"status"];
    [_device sendPackage:np tag:PACKAGE_TAG_CALENDAR];
    for (EKEvent* e in _eventsList) {
        NetworkPackage* np=[Calendar createNetworkPackage:e];
        [np setObject:@"merge" forKey:@"op"];
        [np setObject:@"proccess" forKey:@"status"];
        [_device sendPackage:np tag:PACKAGE_TAG_CALENDAR];
    }
    NetworkPackage* np2=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_CALENDAR];
    [np setObject:@"merge" forKey:@"op"];
    [np setObject:@"end" forKey:@"status"];
    [_device sendPackage:np tag:PACKAGE_TAG_CALENDAR];
    _shouldSend=false;

}

+ (BOOL) event:(EKEvent*) event1 isIdenToEvent:(EKEvent*) event2
{
    return [event1.title isEqualToString:event2.title] &&
        [event1.startDate isEqualToDate:event2.startDate] &&
        [event1.endDate isEqualToDate:event2.endDate] &&
        event1.allDay ==event2.allDay;
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
    [np setObject:event.eventIdentifier forKey:@"uid"];
    return np;
}

+ (EKEvent*) iCalToEvent: (NSString*) iCal withStore:(EKEventStore*) eventstore error:( NSError*__autoreleasing*)err
{
    XbICVCalendar * vCalendar =  [XbICVCalendar vCalendarFromString:iCal];
    XbICVEvent* xbicvevent=(XbICVEvent*)[vCalendar firstComponentOfKind:ICAL_VEVENT_COMPONENT];

    NSString* uid=xbicvevent.UID;
    NSString* summary=xbicvevent.summary;
    NSDate* dt_s=xbicvevent.dateStart;
    NSDate* dt_e=xbicvevent.dateEnd;
    NSDate* dt_created=xbicvevent.dateCreated;
    NSDate* dt_modified=xbicvevent.dateLastModified;
    NSCalendar* calendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDateComponents* component_s=[calendar components:(NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit)  fromDate:dt_s];
    NSDateComponents* component_e=[calendar components:(NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit)  fromDate:dt_e];
    BOOL allDay=!dt_e ||
    (component_s.hour==0 && component_s.minute==0 && component_s.second==0
     && component_e.hour==0 && component_e.minute==0 && component_e.second==0);
    
    if (!uid||!summary||!dt_s) {
        *err=[[NSError alloc] initWithDomain:@"iCal parse failed" code:0 userInfo:nil];
        return nil;
    }
    EKEvent* event=[eventstore eventWithIdentifier:uid];
    if (!event) {
        event=[EKEvent eventWithEventStore:eventstore];
        [event setCalendar:[eventstore defaultCalendarForNewEvents]];
        [event setTitle:summary];
        [event setStartDate:dt_s];
        if (!allDay) {
            [event setEndDate:dt_e];
        }else{
            [event setEndDate:dt_s];
        }
        [event setCalendar:[eventstore defaultCalendarForNewEvents]];
        [event setAllDay:allDay];
        *err=[[NSError alloc] initWithDomain:@"iCal fix uid" code:1 userInfo:@{@"uid": uid}];
        return event;
    }
    if ( (![summary isEqualToString:event.title] ||
        ![dt_s isEqualToDate:event.startDate] ||
        ![dt_e isEqualToDate:event.endDate])
        && [event.lastModifiedDate compare:dt_modified]==NSOrderedAscending) {
        [event setTitle:summary];
        [event setAllDay:allDay];
        [event setStartDate:dt_s];
        if (!allDay) {
            [event setEndDate:dt_e];
        }else{
            if ([dt_e compare:dt_s]!=NSOrderedDescending) {
                [event setEndDate:dt_s];
            }
            else{
                [event setEndDate:[dt_e dateByAddingTimeInterval:-24*3600]];
            }
        }
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
    if (event.allDay) {
        NSDateFormatter* df2=[[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        [df setTimeZone:timeZone];
        [df setDateFormat:@"yyyyMMdd"];
        NSString* dt_s=[df stringFromDate:event.startDate];
        NSString* dt_e=[df stringFromDate:[event.endDate dateByAddingTimeInterval:24*3600]];
        [iCal appendFormat:@"DTSTART;VALUE=DATE:%@\n",dt_s];
        [iCal appendFormat:@"DTEND;VALUE=DATE:%@\n",dt_e];
    }
    else{
        NSString* dt_s=[df stringFromDate:event.startDate];
        NSString* dt_e=[df stringFromDate:event.endDate];
        [iCal appendFormat:@"DTSTART:%@\n",dt_s];
        [iCal appendFormat:@"DTEND:%@\n",dt_e];
    }
    [iCal appendFormat:@"TRANSP:OPAQUE\n"];
    [iCal appendString:@"END:VEVENT\n"];
    [iCal appendString:@"END:VCALENDAR\n"];
    return iCal;
}
@end
