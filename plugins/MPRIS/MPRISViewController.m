//
//  MPRISViewController.m
//  kdeconnect-ios
//
//  Created by yangqiao on 5/22/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MPRISViewController.h"
#import "MPRIS.h"
@interface MPRISViewController ()

@end

@implementation MPRISViewController
{
    __strong MPRIS* _mprisPlugin;
    __strong NSString* _currentSong;
    NSUInteger _volume;
    __strong NSArray* _playerList;
    __strong NSString* _player;
    BOOL _playing;
}

@synthesize _volumeSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _mprisPlugin=nil;
        _currentSong=nil;
        _volume=50;
        _playerList=nil;
        _player=nil;
        _playing=false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setPlugin:(MPRIS*)mprisPlugin
{
    _mprisPlugin=mprisPlugin;
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateVolume:(id)sender
{
    float value=[_volumeSlider value];
    if (!_mprisPlugin) {
        [_mprisPlugin setVolume:value*100];
    }
}
- (IBAction)playPause:(id)sender
{
    if (!_mprisPlugin) {
        [_mprisPlugin sendAction:@"PlayPause"];
    }
}

- (IBAction)previous:(id)sender {
    if (!_mprisPlugin) {
        [_mprisPlugin sendAction:@"Previous"];
    }
}

- (IBAction)next:(id)sender {
    if (!_mprisPlugin) {
        [_mprisPlugin sendAction:@" Next"];
    }
}

- (IBAction)rewind:(id)sender {
    if (!_mprisPlugin) {
        [_mprisPlugin seek:-10000000];
    }
}

- (IBAction)forward:(id)sender {
    if (!_mprisPlugin) {
        [_mprisPlugin seek:10000000];
    }
}

- (void) onPlayerListUpdated
{
    _playerList=[_mprisPlugin getPlayerList];
}

- (void) onPlayerStatusUpdated
{
    _currentSong=[_mprisPlugin getCurrentSong];
    _volume=[_mprisPlugin getVolume];
    _playing=[_mprisPlugin isPlaying];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
