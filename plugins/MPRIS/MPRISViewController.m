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
@property (weak, nonatomic) IBOutlet UILabel *_currentText;
@property (weak, nonatomic) IBOutlet UISlider *_volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *_playPause;
@property (weak, nonatomic) IBOutlet UIPickerView *_playerPicker;
@property (weak, nonatomic) IBOutlet UILabel *_currentPlayer;
@property (nonatomic) MPRIS* _mprisPlugin;
@property (nonatomic) NSArray* _playerList;
@property (nonatomic) NSString* _player;

@end

@implementation MPRISViewController

@synthesize _volumeSlider;
@synthesize _currentText;
@synthesize _playPause;
@synthesize _currentPlayer;
@synthesize _playerPicker;
@synthesize _playerList;
@synthesize _player;
@synthesize _mprisPlugin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _mprisPlugin=nil;
        _playerList=nil;
        _player=nil;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self onPlayerStatusUpdated];
    [self onPlayerListUpdated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setPlugin:(MPRIS*)mprisPlugin
{
    _mprisPlugin=mprisPlugin;
    [_mprisPlugin set_pluginDelegate:self];
}

- (void) onPlayerStatusUpdated
{
    if (!_mprisPlugin) {
        return;
    }
    NSString* s=[_mprisPlugin getCurrentSong];
    float v=[_mprisPlugin getVolume];
    BOOL isPlaying=[_mprisPlugin isPlaying];
    NSString* buttonText;
    if (isPlaying) {
        buttonText=@"Pause";
    }
    else{
        buttonText=@"Play";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSAttributedString* attributedTitle=[_playPause attributedTitleForState:UIControlStateNormal];
//        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
//        [mas.mutableString setString:buttonText];
//        [_playPause setAttributedTitle:mas forState:UIControlStateNormal];
        [_playPause setTitle:buttonText forState:UIControlStateNormal];
        [_currentText setText:s];
        [_volumeSlider setValue:(v/100)];
    });
}

- (void) onPlayerListUpdated
{
    if (!_mprisPlugin) {
        return;
    }
    _playerList=_mprisPlugin.getPlayerList;
    if (!_player) {
        _player=[_playerList objectAtIndex:0];
    }
    if (!_playerList) {
        _player=nil;
    }
    else{
        if (![_playerList containsObject:_player]) {
            _player=[_playerList objectAtIndex:0];
        }
    }
    [_mprisPlugin setPlayer:_player];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_playerPicker reloadAllComponents];
        [_currentPlayer setText:_player];
        [_playerPicker selectRow:[_playerList indexOfObject:_player] inComponent:0 animated:NO];
    });
}

#pragma mark Actions
- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)updateVolume:(id)sender
{
    float value=[_volumeSlider value];
    if (_mprisPlugin) {
        [_mprisPlugin setVolume:value*100];
    }
}
- (IBAction)playPause:(id)sender
{
    if (_mprisPlugin) {
        [_mprisPlugin sendAction:@"PlayPause"];
    }
}

- (IBAction)previous:(id)sender {
    if (_mprisPlugin) {
        [_mprisPlugin sendAction:@"Previous"];
    }
}

- (IBAction)next:(id)sender {
    if (_mprisPlugin) {
        [_mprisPlugin sendAction:@"Next"];
    }
}

- (IBAction)rewind:(id)sender {
    if (_mprisPlugin) {
        [_mprisPlugin seek:-10000000];
    }
}

- (IBAction)forward:(id)sender {
    if (_mprisPlugin) {
        [_mprisPlugin seek:10000000];
    }
}

#pragma mark UIPickerViewDatasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [_playerList count];
}

#pragma mark UIPickerViewDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [_playerList objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    if (_player!=[_playerList objectAtIndex:row]) {
        _player=[_playerList objectAtIndex:row];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_currentPlayer setText:_player];
            [_currentText setText:[_mprisPlugin getCurrentSong]];
        });
        [_mprisPlugin setPlayer:_player];
    }
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
