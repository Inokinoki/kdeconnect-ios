//
//  DeviceSettingsStore.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 6/11/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "SettingsStore.h"

@interface SettingsStore()
@property(nonatomic) NSMutableDictionary* _dict;

@end

@implementation SettingsStore

@synthesize _filePath;
@synthesize _dict;

- (id)initWithPath:(NSString*)path
{
    //get app document path
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath = [paths objectAtIndex:0];
    _filePath=[plistPath stringByAppendingPathComponent:path];
    if((self = [super init])) {
        _dict = [[NSMutableDictionary alloc] initWithContentsOfFile:_filePath];
        if(_dict == nil) {
            _dict = [NSMutableDictionary dictionaryWithCapacity:1];
        }
    }
    return self;
}

- (NSArray*)getAllKeys
{
    return [_dict allKeys];
}

- (void)setObject:(id)value forKey:(NSString *)key {
    [_dict setObject:value forKey:key];
}

- (id)objectForKey:(NSString *)key {
    return [_dict objectForKey:key];
}

- (BOOL)synchronize {
    return [_dict writeToFile:_filePath atomically:YES];
}

@end
