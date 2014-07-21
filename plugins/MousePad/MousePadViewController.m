//
//  MousePadViewController.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MousePadViewController.h"
#import "MousePad.h"
#import "custumRecognizers.h"

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

#pragma mark Gestion Recognizer Delegates

//// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return YES;
//}
//
//// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
//// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
////
//// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//
//// called once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
//// return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer
////
//// note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0)
//{
//    return NO;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer NS_AVAILABLE_IOS(7_0)
//{
//    BOOL is=gestureRecognizer==_longpressRecognizer && otherGestureRecognizer==_scrollRecognizer;
//    UIGestureRecognizerState stat=[_scrollRecognizer state];
//    if(gestureRecognizer==_longpressRecognizer && otherGestureRecognizer==_scrollRecognizer && [_scrollRecognizer state]==UIGestureRecognizerStateChanged){
//        return YES;
//    }
//    return NO;
//}
//
//// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}


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
