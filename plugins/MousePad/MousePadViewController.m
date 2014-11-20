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

#import "MousePadViewController.h"
#import "MousePad.h"
#import "custumRecognizers.h"
#import "MYIntroductionPanel.h"
#import "MYBlurIntroductionView.h"
#import "MyStyleKit.h"
#import "common.h"
#import "NavigationController.h"

@interface MousePadViewController ()
{
    CGPoint preTouchPoint1,preTouchPoint2,preTouchPoint3;
    int touchesCount;
}
@property (nonatomic) MousePad* _mousePadPlugin;
@property (nonatomic) UITapGestureRecognizer* _singleTapRecognizer;
@property (nonatomic) UITapGestureRecognizer* _singleTapWithTwoRecognizer;
@property (nonatomic) UITapGestureRecognizer* _doubleTapRecognizer;
@property (nonatomic) UILongPressGestureRecognizer* _longpressRecognizer;
@end

@implementation MousePadViewController
@synthesize _mousePadPlugin;
@synthesize _doubleTapRecognizer;
@synthesize _singleTapRecognizer;
@synthesize _longpressRecognizer;
@synthesize _singleTapWithTwoRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help",nil) style:UIBarButtonItemStylePlain target:self action:@selector(openHelp:)];
    self.navigationItem.leftBarButtonItem = buttonItem2;
    [self.view setMultipleTouchEnabled:YES];
    
    _singleTapRecognizer=[[UITapGestureRecognizer alloc]
                          initWithTarget:self action:@selector(singleTap:)];
    _doubleTapRecognizer=[[UITapGestureRecognizer alloc]
                          initWithTarget:self action:@selector(doubleTap:)];
    _longpressRecognizer=[[UILongPressGestureRecognizer alloc]
                          initWithTarget:self action:@selector(longPress:)];
    _singleTapWithTwoRecognizer=[[UITapGestureRecognizer alloc]
                                 initWithTarget:self action:@selector(singleTapWithTwo:)];
    _singleTapRecognizer.numberOfTapsRequired =1;
    _singleTapWithTwoRecognizer.numberOfTapsRequired=1;
    _singleTapWithTwoRecognizer.numberOfTouchesRequired=2;
    _doubleTapRecognizer.numberOfTapsRequired =2;
    _longpressRecognizer.minimumPressDuration =0.3;
 
    [self.view addGestureRecognizer:_singleTapRecognizer];
    [self.view addGestureRecognizer:_doubleTapRecognizer];
    [self.view addGestureRecognizer:_longpressRecognizer];
    [self.view addGestureRecognizer:_singleTapWithTwoRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setPlugin:(MousePad*)mousePadPlugin
{
    _mousePadPlugin=mousePadPlugin;
}

#pragma mark Actions
- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)openHelp:(id)sender
{
    NSArray *panels;
    if (isPad) {
        MYIntroductionPanel *panel1 =[[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:NSLocalizedString(@"Mouse pad intro title",nil) description:NSLocalizedString(@"Mouse pad intro description",nil) image:[MyStyleKit imageOfMousePadIntro]];
        //Add panels to an array
        panels= @[panel1];
    }
    
    if (isPhone) {
        MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:NSLocalizedString(@"Mouse pad intro title",nil) description:NSLocalizedString(@"Mouse pad intro description",nil) image:[MyStyleKit imageOfMousePadIntro1Small]];
        MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:nil description:nil image:[MyStyleKit imageOfMousePadIntro2Small]];
        MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:nil description:nil image:[MyStyleKit imageOfMousePadIntro3Small]];
        MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:nil description:nil image:[MyStyleKit imageOfMousePadIntro4Small]];
        //Add panels to an array
        panels= @[panel1,panel2,panel3,panel4];
    }
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;

    [introductionView setBackgroundColor:[MyStyleKit intro]];
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.view addSubview:introductionView];
    
    NavigationController* navc = self.navigationController;
    [navc setNavigationBarHidden:YES animated:YES];
    [navc set_enableRotateMask:NO];
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    //NSLog(@"Introduction did change to panel %d", panelIndex);
    if (panelIndex == 0) {
        [introductionView setBackgroundColor:[MyStyleKit intro]];
    }
    else if (panelIndex == 1){
        [introductionView setBackgroundColor:[MyStyleKit intro1]];
    }
    else if (panelIndex == 2){
        [introductionView setBackgroundColor:[MyStyleKit intro2]];
    }
    else if (panelIndex == 3){
        [introductionView setBackgroundColor:[MyStyleKit intro3]];
    }
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    //NSLog(@"Introduction did finish");
    NavigationController* navc = self.navigationController;
    [navc setNavigationBarHidden:NO animated:YES];
    [navc set_enableRotateMask:YES];
}



#pragma mark Gestions

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchesCount+=[touches count];
    
    NSArray* touchArray=[touches allObjects];
    
    CGPoint touchPoint1,touchPoint2,touchPoint3;
    
    switch ([touches count]) {
        case 1:
            touchPoint1= [[touchArray objectAtIndex:0] locationInView:self.view];
            preTouchPoint1=touchPoint1;
            break;
            
        case 2:
            touchPoint1= [[touchArray objectAtIndex:0] locationInView:self.view];
            touchPoint2= [[touchArray objectAtIndex:1] locationInView:self.view];
            preTouchPoint1=touchPoint1;
            preTouchPoint2=touchPoint2;
            break;
        case 3:
            touchPoint1= [[touchArray objectAtIndex:0] locationInView:self.view];
            touchPoint2= [[touchArray objectAtIndex:1] locationInView:self.view];
            touchPoint3= [[touchArray objectAtIndex:1] locationInView:self.view];
            preTouchPoint1=touchPoint1;
            preTouchPoint2=touchPoint2;
            preTouchPoint3=touchPoint3;
            break;
        default:
            break;
    }

}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([touches count]!=touchesCount){
        return;
    }
    
    NSArray* touchArray=[touches allObjects];
    CGPoint touchPoint1,touchPoint2,touchPoint3;
    UIGestureRecognizerState state;
    switch ([touches count]) {
        case 1:
            touchPoint1= [[touchArray objectAtIndex:0] locationInView:self.view];
            [_mousePadPlugin sendPointsWithDx:touchPoint1.x-preTouchPoint1.x Dy:touchPoint1.y-preTouchPoint1.y];
            preTouchPoint1=touchPoint1;
            break;
            
        case 2:
            touchPoint1= [[touchArray objectAtIndex:0] locationInView:self.view];
            touchPoint2= [[touchArray objectAtIndex:1] locationInView:self.view];
            [_mousePadPlugin sendScrollWithDx:touchPoint2.x-preTouchPoint2.x Dy:touchPoint2.y-preTouchPoint2.y];
            preTouchPoint2=touchPoint2;
            break;
            
        case 3:
            touchPoint1= [[touchArray objectAtIndex:0] locationInView:self.view];
            touchPoint2= [[touchArray objectAtIndex:1] locationInView:self.view];
            touchPoint3= [[touchArray objectAtIndex:1] locationInView:self.view];
            break;
        default:
            break;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchesCount-=[touches count];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchesCount-=[touches count];
}

- (void)singleTap:(UITapGestureRecognizer *)recognizer
{
//    FIX-ME: everytime when trigger doubleTap, singleTap will be triggered as well , which might cause problems
    if ([recognizer state]==UIGestureRecognizerStateRecognized) {
        [_mousePadPlugin sendSingleClick];
    }
}

- (void)singleTapWithTwo:(UITapGestureRecognizer *)recognizer
{
    if ([recognizer state]==UIGestureRecognizerStateRecognized) {
        [_mousePadPlugin sendMiddleClick];
    }
}

- (void)doubleTap:(UITapGestureRecognizer*) recognizer
{
    if ([recognizer state]==UIGestureRecognizerStateRecognized) {
        [_mousePadPlugin sendDoubleClick];
    }
}

- (void)longPress:(UILongPressGestureRecognizer*) recognizer
{
    UIGestureRecognizerState stat=[recognizer state];
    if ([recognizer state]==UIGestureRecognizerStateRecognized) {
        [_mousePadPlugin sendRightClick];
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
