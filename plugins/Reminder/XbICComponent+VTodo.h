//
//  XbICComponent+VTodo.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/28/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "ical.h"
#import "XbICComponent.h"
#import "XbICPerson.h"

@interface XbICComponent (VTodo)

-(NSDate *) dateStart;
-(NSDate *) dateStamp;
-(NSDate *) dateCreated;
-(NSDate *) dateDue;
-(NSDate *) dateLastModified;
-(NSDate *) completed;
-(NSNumber *) percentCompleted;
-(NSString *) UID;
-(NSString *) location;
-(NSString *) description;
-(NSNumber *) sequence;
-(NSString *) status;
-(NSString *) summary;

@end
