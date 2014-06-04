//
//  MPRIS.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/22/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MPRIS.h"
#import "MPRISViewController.h"
#import "DeviceViewController.h"

@implementation MPRIS
{
    __strong UIView* _view;
    MPRISViewController* _mprisViewController;
    UIViewController* _deviceViewController;
    __strong NSString* _currentSong;
    NSUInteger _volume;
    __strong NSArray* _playerList;
    __strong NSString* _player;
    BOOL _playing;
}

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;

- (id) init
{
    if ((self=[super init])) {
        _pluginInfo=[[PluginInfo alloc] initWithInfos:@"MPRISPlugin" displayName:@"MPRIS" description:@"MPRIS" enabledByDefault:true];
        _pluginDelegate=nil;
        _device=nil;
        _view=nil;
        _mprisViewController=nil;
        _deviceViewController=nil;
        _currentSong=nil;
        _volume=50;
        _playerList=nil;
        _player=nil;
        _playing=false;
        [self requestPlayerList];
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    NSLog(@"mpris receive a package");
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_MPRIS]) {
        if ([np bodyHasKey:@"nowPlaying"]||[np bodyHasKey:@"volume"]||[np bodyHasKey:@"isPlaying"]) {
            if ([[[np _Body] valueForKey:@"player"] isEqualToString:_player]) {
                if ([np bodyHasKey:@"nowPlaying"]) {
                    _currentSong=[[np _Body] valueForKey:@"nowPlaying"];
                }
                if ([np bodyHasKey:@"volume"]) {
                    _volume=[[[np _Body] valueForKey:@"volume"] unsignedIntegerValue];
                }
                if ([np bodyHasKey:@"isPlaying"]) {
                    _playing=[[[np _Body] valueForKey:@"isPlaying"] boolValue];
                }
                if (_pluginDelegate) {
                    [_pluginDelegate onPlayerStatusUpdated];
                }
                
            }
        }
        if ([[np _Body] valueForKey:@"playerList"]){
            NSArray* newPlayerList=[[np _Body] valueForKey:@"playerList"];
            if (![_playerList isEqualToArray:newPlayerList] ) {
                _playerList=newPlayerList;
                if (_pluginDelegate) {
                    [_pluginDelegate onPlayerListUpdated];
                }
            }
        }   
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    NSLog(@"mpris get view");
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:@"MPRIS"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"Open MPRIS Panel" forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        [button addTarget:self action:@selector(openPanel:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
    }
    _deviceViewController=vc;
    return _view;
}

- (void) openPanel:(id)sender
{
    if (!_mprisViewController) {
        _mprisViewController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MPRISViewController"];
            [_mprisViewController setTitle:FORMAT(@"MPRIS Panel for %@",[_device _name])];
            [_mprisViewController setPlugin:self];
    }
    [_deviceViewController.navigationController presentViewController:_mprisViewController animated:YES completion:^(void){}];
}

- (void) sendAction:(NSString *)action
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [[np _Body] setValue:_player forKey:@"player"];
    [[np _Body] setValue:action forKey:@"action"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

- (void) setVolume:(NSUInteger)volume
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [[np _Body] setValue:_player forKey:@"player"];
    [[np _Body] setValue:[NSNumber numberWithUnsignedInteger:volume] forKey:@"setVolume"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

- (void) seek:(NSInteger)offset
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [[np _Body] setValue:_player forKey:@"player"];
    [[np _Body] setValue:[NSNumber numberWithUnsignedInteger:offset] forKey:@"Seek"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

- (NSString*) getCurrentSong
{
    return _currentSong;
}

- (NSArray*) getPlayerList
{
    return _playerList;
}

- (NSUInteger) getVolume
{
    return _volume;
}

- (void) setPlayer:(NSString*)player
{
    if (_player!=player) {
        _player=player;
        _currentSong=nil;
        _volume=50;
        _playing=false;
        [self requestPlayerStatus];
    }
}

- (BOOL) isPlaying
{
    return _playing;
}

- (void) requestPlayerStatus
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [[np _Body] setValue:_player forKey:@"player"];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"requestNowPlaying"];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"requestVolume"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

- (void) requestPlayerList
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [[np _Body] setValue:[NSNumber numberWithBool:true] forKey:@"requestPlayerList"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

@end