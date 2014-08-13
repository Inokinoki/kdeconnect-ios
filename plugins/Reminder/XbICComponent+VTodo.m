//
//  XbICComponent+VTodo.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/28/14.
//  
//

#import "XbICComponent+VTodo.h"

@implementation XbICComponent (VTodo)


-(NSDate *) dateStart {
    NSArray * properties = [self propertiesOfKind:ICAL_DTSTART_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_DTSTART_PROPERTY");
        return nil;
    }
    return (NSDate *)[((XbICProperty *)properties[0]) value];
    
}

-(NSDate *) dateEnd {
    NSArray * properties = [self propertiesOfKind:ICAL_DTEND_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_DTEND_PROPERTY");
        return nil;
    }
    return (NSDate *)[((XbICProperty *)properties[0]) value];
    
}

-(NSDate *) dateStamp {
    NSArray * properties = [self propertiesOfKind:ICAL_DTSTAMP_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_DTSTAMP_PROPERTY");
        return nil;
    }
    return (NSDate *)[((XbICProperty *)properties[0]) value];
    
}

-(NSDate *) dateCreated {
    NSArray * properties = [self propertiesOfKind:ICAL_CREATED_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_CREATED_PROPERTY");
        return nil;
    }
    return (NSDate *)[((XbICProperty *)properties[0]) value];
    
}

-(NSDate *) dateDue {
    NSArray * properties = [self propertiesOfKind:ICAL_DUE_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_DUE_PROPERTY");
        return nil;
    }
    return (NSDate *)[((XbICProperty *)properties[0]) value];
    
}

-(NSDate *) dateLastModified {
    NSArray * properties = [self propertiesOfKind:ICAL_LASTMODIFIED_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_LASTMODIFIED_PROPERTY");
        return nil;
    }
    return (NSDate *)[((XbICProperty *)properties[0]) value];
    
}

-(NSDate *) completed {
    NSArray * properties = [self propertiesOfKind:ICAL_COMPLETED_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_COMPLETED_PROPERTY");
        return nil;
    }
    return (NSDate *)[((XbICProperty *)properties[0]) value];
    
}

-(NSNumber *) percentCompleted {
    NSArray * properties = [self propertiesOfKind:ICAL_PERCENTCOMPLETE_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_PERCENTCOMPLETED_PROPERTY");
        return nil;
    }
    return (NSNumber *)[((XbICProperty *)properties[0]) value];
    
}

-(NSNumber *) sequence {
    NSArray * properties = [self propertiesOfKind:ICAL_SEQUENCE_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_SEQUENCE_PROPERTY");
        return nil;
    }
    return (NSNumber *)[((XbICProperty *)properties[0]) value];
    
}
-(NSString *) UID {
    NSArray * properties = [self propertiesOfKind:ICAL_UID_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_UID_PROPERTY");
        return nil;
    }
    return (NSString *)[((XbICProperty *)properties[0]) value];
}

-(NSString *) location {
    NSArray * properties = [self propertiesOfKind:ICAL_LOCATION_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_LOCATION_PROPERTY");
        return nil;
    }
    return (NSString *)[((XbICProperty *)properties[0]) value];
}

-(NSString *) summary {
    NSArray * properties = [self propertiesOfKind:ICAL_SUMMARY_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_SUMMARY_PROPERTY");
        return nil;
    }
    return (NSString *)[((XbICProperty *)properties[0]) value];
}
-(NSString *) status {
    NSArray * properties = [self propertiesOfKind:ICAL_STATUS_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_STATUS_PROPERTY");
        return nil;
    }
    return (NSString *)[((XbICProperty *)properties[0]) value];
}
-(NSString *) description {
    NSArray * properties = [self propertiesOfKind:ICAL_DESCRIPTION_PROPERTY];
    if (properties.count != 1 ) {
        //NSLog(@"ICAL_STATUS_PROPERTY");
        return nil;
    }
    return (NSString *)[((XbICProperty *)properties[0]) value];
}

-(NSArray *) attendees; {
    return [self propertiesOfKind:ICAL_ATTENDEE_PROPERTY];
}

@end
