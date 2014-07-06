//
//  MPRIS.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/22/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MPRIS.h"
#import "MPRISViewController.h"
#import "device.h"

@interface MPRIS()
{
    NSUInteger _volume; 
    BOOL _playing;
}
@property(nonatomic) UIView* _view;
@property(nonatomic) MPRISViewController* _mprisViewController;
@property(nonatomic) UIViewController* _deviceViewController;
@property(nonatomic) NSString* _currentSong;
@property(nonatomic) NSArray* _playerList;
@property(nonatomic) NSString* _player;
@end

@implementation MPRIS

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _deviceViewController;
@synthesize _view;
@synthesize _currentSong;
@synthesize _mprisViewController;
@synthesize _player;
@synthesize _playerList;

- (id) init
{
    if ((self=[super init])) {
        _pluginInfo=[[PluginInfo alloc] initWithInfos:@"MPRIS" displayName:@"MPRIS" description:@"MPRIS" enabledByDefault:true];
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
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_MPRIS]) {
        NSLog(@"mpris receive a package");
        if ([np bodyHasKey:@"nowPlaying"]||[np bodyHasKey:@"volume"]||[np bodyHasKey:@"isPlaying"]) {
            if ([[np objectForKey:@"player"] isEqualToString:_player]) {
                if ([np bodyHasKey:@"nowPlaying"]) {
                    _currentSong=[np objectForKey:@"nowPlaying"];
                }
                if ([np bodyHasKey:@"volume"]) {
                    _volume=[np integerForKey:@"volume"];
                }
                if ([np bodyHasKey:@"isPlaying"]) {
                    _playing=[np boolForKey:@"isPlaying"];
                }
                if (_pluginDelegate) {
                    [_pluginDelegate onPlayerStatusUpdated];
                }
                
            }
        }
        if ([np objectForKey:@"playerList"]){
            NSArray* newPlayerList=[np objectForKey:@"playerList"];
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
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        [button addTarget:self action:@selector(openPanel:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
    }
    else{
        _view=nil;
    }
    _deviceViewController=vc;
    return _view;
}

- (void) openPanel:(id)sender
{
    if (!_mprisViewController) {
        _mprisViewController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MPRISViewController"];
        [_mprisViewController setPlugin:self];
        [_mprisViewController setTitle:@"MPRIS"];
    }
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:_mprisViewController];
    [_deviceViewController presentViewController:aNavController animated:YES completion:nil];
}

- (void) sendAction:(NSString *)action
{
    if (!_player) {
        return;
    }
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [np setObject:_player forKey:@"player"];
    [np setObject:action forKey:@"action"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

- (void) setVolume:(NSUInteger)volume
{
    if (!_player) {
        return;
    }
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [np setObject:_player forKey:@"player"];
    [np setObject:[NSNumber numberWithUnsignedInteger:volume] forKey:@"setVolume"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

- (void) seek:(NSInteger)offset
{
    if (!_player) {
        return;
    }
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [np setObject:_player forKey:@"player"];
    [np setInteger:offset forKey:@"Seek"];
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
    [np setObject:_player forKey:@"player"];
    [np setBool:YES forKey:@"requestNowPlaying"];
    [np setBool:YES forKey:@"requestVolume"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

- (void) requestPlayerList
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MPRIS];
    [np setBool:YES forKey:@"requestPlayerList"];
    [_device sendPackage:np tag:PACKAGE_TAG_MPRIS];
}

@end