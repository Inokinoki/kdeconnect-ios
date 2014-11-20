//Copyright 3/7/14  YANG Qiao yangqiao0505@me.com
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

#import "MousePad.h"
#import "MousePadViewController.h"
#import "device.h"
#import "NavigationController.h"

@interface MousePad()
@property(nonatomic) UIView* _view;
@property(nonatomic) MousePadViewController* _mousePadController;
@property(nonatomic) UIViewController* _deviceViewController;
@end

@implementation MousePad

@synthesize _device;
@synthesize _pluginInfo;
@synthesize _pluginDelegate;
@synthesize _view;
@synthesize _mousePadController;
@synthesize _deviceViewController;

- (id) init
{
    if ((self=[super init])) {
        _pluginDelegate=nil;
        _device=nil;
        _view=nil;
        _mousePadController=nil;
    }
    return self;
}

- (BOOL) onDevicePackageReceived:(NetworkPackage *)np
{
    if ([[np _Type] isEqualToString:PACKAGE_TYPE_PING]) {
        //NSLog(@"mouse pad receive a package");
        return true;
    }
    return false;
}

- (UIView*) getView:(UIViewController*)vc
{
    if ([_device isReachable]) {
        _view=[[UIView alloc] initWithFrame:CGRectMake(0,0,400, 60)];
        UILabel* label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 400, 30)];
        [label setText:NSLocalizedString(@"Mouse Pad",nil)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:NSLocalizedString(@"open touch pad",nil) forState:UIControlStateNormal];
        button.frame= CGRectMake(0, 30, 300, 30);
        button.layer.borderWidth=1;
        button.layer.cornerRadius=10.0;
        button.layer.borderColor=[[UIColor grayColor] CGColor];
        [button addTarget:self action:@selector(openPad:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:label];
        [_view addSubview:button];
        if (isPad) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-100-[button]-100-|" options:0 metrics:nil views:@{@"button": button}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-50-[label]" options:0 metrics:nil views:@{@"label": label}]];
            [_view addConstraints:constraints];
        }
        if (isPhone) {
            NSArray* constraints=[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[button]-10-|" options:0 metrics:nil views:@{@"button": button}];
            constraints=[constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[label]" options:0 metrics:nil views:@{@"label": label}]];
            [_view addConstraints:constraints];
        }
        label.translatesAutoresizingMaskIntoConstraints=NO;
        button.translatesAutoresizingMaskIntoConstraints=NO;
    }
    else{
        _view=nil;
    }
    _deviceViewController=vc;
    return _view;
}

+ (PluginInfo*) getPluginInfo
{
    return [[PluginInfo alloc] initWithInfos:@"MousePad" displayName:NSLocalizedString(@"MousePad",nil) description:NSLocalizedString(@"MousePad",nil) enabledByDefault:true];

}

- (void) stop
{
    
}

- (void) openPad:(id)sender
{
    if (!_mousePadController) {
        if (isPhone) {
            _mousePadController=[[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MousePadViewController"];
        }
        if (isPad) {
            _mousePadController=[[UIStoryboard storyboardWithName:@"Main_iPad" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MousePadViewController"];
        }
        [_mousePadController setPlugin:self];
        [_mousePadController setTitle:NSLocalizedString(@"Mouse Pad",nil)];
    }
    NavigationController *aNavController = [[NavigationController alloc] initWithRootViewController:_mousePadController];
    [_deviceViewController presentViewController:aNavController animated:YES completion:nil];
}

#pragma mark mouse actions

- (void) sendPointsWithDx:(double)x Dy:(double)y
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setDouble:x forKey:@"dx"];
    [np setDouble:y forKey:@"dy"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}

- (void) sendSingleClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"singleclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}

- (void) sendDoubleClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"doubleclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
- (void) sendMiddleClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"middleclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
- (void) sendRightClick
{
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"rightclick"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
- (void) sendScrollWithDx:(double)x Dy:(double)y
{
    CGSize screenSize=[[UIScreen mainScreen] bounds].size;
    x/=screenSize.width;
    y/=screenSize.height;
    NetworkPackage* np=[[NetworkPackage alloc] initWithType:PACKAGE_TYPE_MOUSEPAD];
    [np setBool:YES forKey:@"scroll"];
    [np setDouble:x forKey:@"dx"];
    [np setDouble:y forKey:@"dy"];
    [_device sendPackage:np tag:PACKAGE_TAG_MOUSEPAD];
}
@end
