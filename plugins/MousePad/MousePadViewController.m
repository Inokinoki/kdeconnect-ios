//
//  MousePadViewController.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/3/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import "MousePadViewController.h"
#import "MousePad.h"

@interface MousePadViewController ()
@property (nonatomic) MousePad* _mousePadPlugin;
@property (nonatomic) IBOutlet UITapGestureRecognizer* _singleTapRecognizer;
@end

@implementation MousePadViewController
@synthesize _mousePadPlugin;
@synthesize _singleTapRecognizer;

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
    _singleTapRecognizer.numberOfTapsRequired =1;
    [self.view addGestureRecognizer:_singleTapRecognizer];
    
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
    // Enumerate over all the touches and draw a red dot on the screen where the touches were
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
    {
        // Get a single touch and it's location
        UITouch *touch = obj;
        CGPoint touchPoint = [touch locationInView:self.view];
        [_mousePadPlugin setStartPointWithX:touchPoint.x Y:touchPoint.y];
    }];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches)
    {
        CGPoint touchPoint= [touch locationInView:self.view];
        [_mousePadPlugin sendPointsWithX:touchPoint.x Y:touchPoint.y];
    }
}

- (IBAction)singleTap:(UITapGestureRecognizer *)recognizer
{
    [_mousePadPlugin sendSingleClick];
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
