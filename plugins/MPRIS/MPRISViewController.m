//Copyright 22/5/14  YANG Qiao yangqiao0505@me.com
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

#import "MPRISViewController.h"
#import "MPRIS.h"
#import "Buttons.h"
#import "MyStyleKit.h"

@interface MPRISViewController ()
@property (weak, nonatomic) IBOutlet UILabel *_currentText;
@property (weak, nonatomic) IBOutlet UISlider *_volumeSlider;
@property (weak, nonatomic) IBOutlet PlayPauseButton *_playPause;
@property (weak, nonatomic) IBOutlet FollowingButton *_following;
@property (weak, nonatomic) IBOutlet ForwardButton *_foward;
@property (weak, nonatomic) IBOutlet PreviousButton *_previous;
@property (weak, nonatomic) IBOutlet BackButton *_back;
@property (weak, nonatomic) IBOutlet UIPickerView *_playerPicker;
@property (nonatomic) MPRIS* _mprisPlugin;
@property (nonatomic) NSArray* _playerList;
@property (nonatomic) NSString* _player;

@end

@implementation MPRISViewController

@synthesize _volumeSlider;
@synthesize _currentText;
@synthesize _playPause;
@synthesize _playerPicker;
@synthesize _playerList;
@synthesize _player;
@synthesize _mprisPlugin;
@synthesize _back;
@synthesize _following;
@synthesize _foward;
@synthesize _previous;

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
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismiss:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    [_volumeSlider setMinimumTrackTintColor:[MyStyleKit buttonNormal]];
    [_volumeSlider setNeedsDisplay];
    [_playPause setTitle:@"" forState:UIControlStateNormal];
    [_previous setTitle:@"" forState:UIControlStateNormal];
    [_back setTitle:@"" forState:UIControlStateNormal];
    [_foward setTitle:@"" forState:UIControlStateNormal];
    [_following setTitle:@"" forState:UIControlStateNormal];
    [_playPause setNeedsDisplay];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isPlaying) {
            [_playPause setpause];
        }
        else{
            [_playPause setplay];
        }
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
            _player=[_playerList firstObject];
        }
    }
    if (!_player) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_playerPicker reloadAllComponents];
            [_currentText setText:nil];
        });
        return;
    }
    [_mprisPlugin setPlayer:_player];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_playerPicker reloadAllComponents];
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
