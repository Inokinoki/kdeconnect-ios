//Copyright 5/8/14  YANG Qiao yangqiao0505@me.com
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
//---------------------------------------------------------------------

#import "MyStyleKit.h"


@implementation MyStyleKit

#pragma mark Cache

static UIColor* _navbar = nil;
static UIColor* _buttonNormal = nil;
static UIColor* _buttonHighlighted = nil;
static UIColor* _intro=nil;
static UIColor* _intro1=nil;
static UIColor* _intro2=nil;
static UIColor* _intro3=nil;
static UIImage* _imageOfPlay = nil;
static UIImage* _imageOfPlayHighlighted = nil;
static UIImage* _imageOfPause = nil;
static UIImage* _imageOfPauseHighlighted = nil;
static UIImage* _imageOfForward = nil;
static UIImage* _imageOfForwardHighlighted = nil;
static UIImage* _imageOfBack = nil;
static UIImage* _imageOfBackHighlighted = nil;
static UIImage* _imageOfPrevious = nil;
static UIImage* _imageOfPreviousHighlighted = nil;
static UIImage* _imageOfFollowing = nil;
static UIImage* _imageOfFollowingHighlighted = nil;
static UIImage* _imageOfMousePadIntro = nil;
static UIImage* _imageOfMousePadIntro1Small = nil;
static UIImage* _imageOfMousePadIntro2Small = nil;
static UIImage* _imageOfMousePadIntro3Small = nil;
static UIImage* _imageOfMousePadIntro4Small = nil;
static UIImage* _imageOfGear= nil;
static UIImage* _imageOfGearHighlighted= nil;
static UIImage* _imageOfMore= nil;
static UIImage* _imageOfMoreHighlighted= nil;

#pragma mark Initialization

+ (void)initialize
{
    // Colors Initialization
    _navbar = [UIColor colorWithRed: 0.109 green: 0.452 blue: 1 alpha: 0.995];
    _buttonNormal = [UIColor colorWithRed: 0 green: 0.693 blue: 1 alpha: 1];
    _buttonHighlighted = [UIColor colorWithRed: 0 green: 0.693 blue: 1 alpha: 0.26];
    _intro = [UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65];
    _intro1 = [UIColor colorWithRed: 1 green: 0.774 blue: 0.134 alpha: 0.65];
    _intro2 = [UIColor colorWithRed: 0.134 green: 0.806 blue: 1 alpha: 0.65];
    _intro3 = [UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:0.65];
}

#pragma mark Colors

+ (UIColor*)navbar { return _navbar; }
+ (UIColor*)buttonNormal { return _buttonNormal; }
+ (UIColor*)buttonHighlighted { return _buttonHighlighted; }
+ (UIColor*)intro { return _intro; }
+ (UIColor*)intro1 { return _intro1; }
+ (UIColor*)intro2 { return _intro2; }
+ (UIColor*)intro3 { return _intro3; }

//// In trial version of PaintCode, the code generation is limited to one canvas

#pragma mark Drawing Methods

//// PaintCode Trial Version
//// www.paintcodeapp.com

+ (void)drawPlay;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(7, 5)];
    [bezierPath addLineToPoint: CGPointMake(44, 26.71)];
    [bezierPath addLineToPoint: CGPointMake(7, 46)];
    [bezierPath addLineToPoint: CGPointMake(7, 5)];
    [bezierPath closePath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonNormal setFill];
    [bezierPath fill];
    [MyStyleKit.buttonNormal setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
}

+ (void)drawPlayHighlighted;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(7, 5)];
    [bezierPath addLineToPoint: CGPointMake(44, 26.71)];
    [bezierPath addLineToPoint: CGPointMake(7, 46)];
    [bezierPath addLineToPoint: CGPointMake(7, 5)];
    [bezierPath closePath];
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonHighlighted setFill];
    [bezierPath fill];
    [MyStyleKit.buttonHighlighted setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
}

+ (void)drawPause;
{
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(12.5, 8)];
        [bezierPath addCurveToPoint: CGPointMake(12.5, 43) controlPoint1: CGPointMake(12.5, 39.11) controlPoint2: CGPointMake(12.5, 43)];
        bezierPath.lineCapStyle = kCGLineCapRound;
        
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        
        [MyStyleKit.buttonNormal setStroke];
        bezierPath.lineWidth = 3;
        [bezierPath stroke];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(35.5, 8)];
        [bezier2Path addLineToPoint: CGPointMake(35.5, 43)];
        bezier2Path.lineCapStyle = kCGLineCapRound;
        
        bezier2Path.lineJoinStyle = kCGLineJoinRound;
        
        [MyStyleKit.buttonNormal setStroke];
        bezier2Path.lineWidth = 3;
        [bezier2Path stroke];
    }
}

+ (void)drawPauseHighlighted;
{
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(12.5, 8)];
        [bezierPath addCurveToPoint: CGPointMake(12.5, 43) controlPoint1: CGPointMake(12.5, 39.11) controlPoint2: CGPointMake(12.5, 43)];
        bezierPath.lineCapStyle = kCGLineCapRound;
        
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        
        [MyStyleKit.buttonHighlighted setStroke];
        bezierPath.lineWidth = 3;
        [bezierPath stroke];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
        [bezier2Path moveToPoint: CGPointMake(35.5, 8)];
        [bezier2Path addLineToPoint: CGPointMake(35.5, 43)];
        bezier2Path.lineCapStyle = kCGLineCapRound;
        
        bezier2Path.lineJoinStyle = kCGLineJoinRound;
        
        [MyStyleKit.buttonHighlighted setStroke];
        bezier2Path.lineWidth = 3;
        [bezier2Path stroke];
    }
}

+ (void)drawForward;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(10, 5)];
    [bezierPath addCurveToPoint: CGPointMake(40, 26.46) controlPoint1: CGPointMake(40, 26.46) controlPoint2: CGPointMake(40, 26.46)];
    [bezierPath addLineToPoint: CGPointMake(10, 45)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonNormal setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
}

+ (void)drawForwardHighlighted;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(10, 5)];
    [bezierPath addCurveToPoint: CGPointMake(40, 26.46) controlPoint1: CGPointMake(40, 26.46) controlPoint2: CGPointMake(40, 26.46)];
    [bezierPath addLineToPoint: CGPointMake(10, 45)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonHighlighted setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
}

+ (void)drawBack;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(40, 5)];
    [bezierPath addLineToPoint: CGPointMake(10, 27)];
    [bezierPath addLineToPoint: CGPointMake(40, 45)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonNormal setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
}

+ (void)drawBackHighlighted;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(40, 5)];
    [bezierPath addLineToPoint: CGPointMake(10, 27)];
    [bezierPath addLineToPoint: CGPointMake(40, 45)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonHighlighted setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
}

+ (void)drawPrevious;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(45, 5)];
    [bezierPath addLineToPoint: CGPointMake(15, 26.05)];
    [bezierPath addLineToPoint: CGPointMake(45, 45)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonNormal setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(7.5, 4.5)];
    [bezier2Path addLineToPoint: CGPointMake(7.5, 45.5)];
    bezier2Path.lineCapStyle = kCGLineCapRound;
    
    bezier2Path.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonNormal setStroke];
    bezier2Path.lineWidth = 3;
    [bezier2Path stroke];
}

+ (void)drawPreviousHighlighted;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(45, 5)];
    [bezierPath addLineToPoint: CGPointMake(15, 26.05)];
    [bezierPath addLineToPoint: CGPointMake(45, 45)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonHighlighted setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(7.5, 4.5)];
    [bezier2Path addLineToPoint: CGPointMake(7.5, 45.5)];
    bezier2Path.lineCapStyle = kCGLineCapRound;
    
    bezier2Path.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonHighlighted setStroke];
    bezier2Path.lineWidth = 3;
    [bezier2Path stroke];
    
}

+ (void)drawFollowing
{
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(45, 4.5)];
    [bezierPath addLineToPoint: CGPointMake(45, 45.5)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonNormal setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
    
    
    //// Bezier 1 Drawing
    UIBezierPath* bezier1Path = UIBezierPath.bezierPath;
    [bezier1Path moveToPoint: CGPointMake(7.5, 45)];
    [bezier1Path addLineToPoint: CGPointMake(37.5, 25)];
    [bezier1Path addLineToPoint: CGPointMake(7.5, 5)];
    bezier1Path.lineCapStyle = kCGLineCapRound;
    
    bezier1Path.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonNormal setStroke];
    bezier1Path.lineWidth = 3;
    [bezier1Path stroke];

}

+ (void)drawFollowingHighlighted
{
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(45, 4.5)];
    [bezierPath addLineToPoint: CGPointMake(45, 45.5)];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    bezierPath.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonHighlighted setStroke];
    bezierPath.lineWidth = 3;
    [bezierPath stroke];
    
    
    //// Bezier 1 Drawing
    UIBezierPath* bezier1Path = UIBezierPath.bezierPath;
    [bezier1Path moveToPoint: CGPointMake(7.5, 45)];
    [bezier1Path addLineToPoint: CGPointMake(37.5, 25)];
    [bezier1Path addLineToPoint: CGPointMake(7.5, 5)];
    bezier1Path.lineCapStyle = kCGLineCapRound;
    
    bezier1Path.lineJoinStyle = kCGLineJoinRound;
    
    [MyStyleKit.buttonHighlighted setStroke];
    bezier1Path.lineWidth = 3;
    [bezier1Path stroke];
    
}

+ (void)drawMousePadIntro;
{
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(17.5, 203.5)];
    [bezierPath addLineToPoint: CGPointMake(577.5, 203.5)];
    [UIColor.whiteColor setStroke];
    bezierPath.lineWidth = 3.5;
    [bezierPath stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(311.5, 38.5)];
    [bezier2Path addLineToPoint: CGPointMake(311.5, 338.5)];
    [UIColor.whiteColor setStroke];
    bezier2Path.lineWidth = 3.5;
    [bezier2Path stroke];
    
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(350, 38, 201, 141);
    NSMutableParagraphStyle* text2Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    text2Style.alignment = NSTextAlignmentCenter;
    
    NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: text2Style};
    
    [NSLocalizedString(@"right Click intro",nil) drawInRect: text2Rect withAttributes: text2FontAttributes];
    
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(32, 38, 232, 134);
    NSMutableParagraphStyle* text3Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    text3Style.alignment = NSTextAlignmentCenter;
    
    NSDictionary* text3FontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: text3Style};
    
    [NSLocalizedString(@"left click intro",nil) drawInRect: text3Rect withAttributes: text3FontAttributes];
    
    
    //// Text 4 Drawing
    CGRect text4Rect = CGRectMake(48, 233, 200, 118);
    NSMutableParagraphStyle* text4Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    text4Style.alignment = NSTextAlignmentCenter;
    
    NSDictionary* text4FontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: text4Style};
    
    [NSLocalizedString(@"middle click intro",nil) drawInRect: text4Rect withAttributes: text4FontAttributes];
    
    //// Text Drawing
    CGRect textRect = CGRectMake(350, 233, 216, 118);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: textStyle};
    
    [NSLocalizedString(@"scroll intro",nil) drawInRect: textRect withAttributes: textFontAttributes];
    
}

+ (void)drawMousePadIntro1Small;
{
    
    //// Text 3 Drawing
    CGRect text3Rect = CGRectMake(27, 125, 250, 129);
    NSMutableParagraphStyle* text3Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    text3Style.alignment = NSTextAlignmentCenter;
    
    NSDictionary* text3FontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: text3Style};
    
    [NSLocalizedString(@"left click intro",nil) drawInRect: text3Rect withAttributes: text3FontAttributes];

}

+ (void)drawMousePadIntro2Small;
{
    
    //// Text 2 Drawing
    CGRect text2Rect = CGRectMake(27, 125, 250, 196);
    NSMutableParagraphStyle* text2Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    text2Style.alignment = NSTextAlignmentCenter;
    
    NSDictionary* text2FontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: text2Style};
    
    [NSLocalizedString(@"right Click intro",nil) drawInRect: text2Rect withAttributes: text2FontAttributes];
    
}

+ (void)drawMousePadIntro3Small;
{
    //// Text 4 Drawing
    CGRect text4Rect = CGRectMake(27, 125, 250, 183);
    NSMutableParagraphStyle* text4Style = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    text4Style.alignment = NSTextAlignmentCenter;
    
    NSDictionary* text4FontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: text4Style};
    
    [NSLocalizedString(@"middle click intro",nil) drawInRect: text4Rect withAttributes: text4FontAttributes];
    
}

+ (void)drawMousePadIntro4Small;
{
    //// Text Drawing
    CGRect textRect = CGRectMake(27, 125, 250, 127);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 20], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: textStyle};
    
    [NSLocalizedString(@"scroll intro",nil) drawInRect: textRect withAttributes: textFontAttributes];
}

+ (void)drawGear;
{
    
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(20, 2)];
    [bezierPath addLineToPoint: CGPointMake(22.71, 2.18)];
    [bezierPath addLineToPoint: CGPointMake(23.87, 6.04)];
    [bezierPath addCurveToPoint: CGPointMake(28.8, 8.32) controlPoint1: CGPointMake(24.46, 7.96) controlPoint2: CGPointMake(26.92, 9.11)];
    [bezierPath addLineToPoint: CGPointMake(32.52, 6.77)];
    [bezierPath addLineToPoint: CGPointMake(34.31, 8.82)];
    [bezierPath addLineToPoint: CGPointMake(32.41, 12.37)];
    [bezierPath addCurveToPoint: CGPointMake(34.28, 17.47) controlPoint1: CGPointMake(31.45, 14.14) controlPoint2: CGPointMake(32.39, 16.69)];
    [bezierPath addLineToPoint: CGPointMake(38, 19)];
    [bezierPath addLineToPoint: CGPointMake(37.82, 21.71)];
    [bezierPath addLineToPoint: CGPointMake(33.96, 22.87)];
    [bezierPath addCurveToPoint: CGPointMake(31.68, 27.8) controlPoint1: CGPointMake(32.04, 23.46) controlPoint2: CGPointMake(30.89, 25.92)];
    [bezierPath addLineToPoint: CGPointMake(33.23, 31.52)];
    [bezierPath addLineToPoint: CGPointMake(31.18, 33.31)];
    [bezierPath addLineToPoint: CGPointMake(27.63, 31.41)];
    [bezierPath addCurveToPoint: CGPointMake(22.53, 33.28) controlPoint1: CGPointMake(25.86, 30.45) controlPoint2: CGPointMake(23.31, 31.39)];
    [bezierPath addLineToPoint: CGPointMake(21, 37)];
    [bezierPath addLineToPoint: CGPointMake(18.29, 36.82)];
    [bezierPath addLineToPoint: CGPointMake(17.13, 32.96)];
    [bezierPath addCurveToPoint: CGPointMake(12.2, 30.68) controlPoint1: CGPointMake(16.54, 31.04) controlPoint2: CGPointMake(14.08, 29.89)];
    [bezierPath addLineToPoint: CGPointMake(8.48, 32.23)];
    [bezierPath addLineToPoint: CGPointMake(6.69, 30.18)];
    [bezierPath addLineToPoint: CGPointMake(8.59, 26.63)];
    [bezierPath addCurveToPoint: CGPointMake(6.72, 21.53) controlPoint1: CGPointMake(9.55, 24.86) controlPoint2: CGPointMake(8.61, 22.31)];
    [bezierPath addLineToPoint: CGPointMake(3, 20)];
    [bezierPath addLineToPoint: CGPointMake(3.18, 17.29)];
    [bezierPath addLineToPoint: CGPointMake(7.04, 16.13)];
    [bezierPath addCurveToPoint: CGPointMake(9.32, 11.2) controlPoint1: CGPointMake(8.96, 15.54) controlPoint2: CGPointMake(10.11, 13.08)];
    [bezierPath addLineToPoint: CGPointMake(7.77, 7.48)];
    [bezierPath addLineToPoint: CGPointMake(9.82, 5.69)];
    [bezierPath addLineToPoint: CGPointMake(13.37, 7.59)];
    [bezierPath addCurveToPoint: CGPointMake(18.47, 5.72) controlPoint1: CGPointMake(15.14, 8.55) controlPoint2: CGPointMake(17.69, 7.61)];
    [bezierPath addLineToPoint: CGPointMake(20, 2)];
    [bezierPath addLineToPoint: CGPointMake(20, 2)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(20.36, 11.47)];
    [bezierPath addCurveToPoint: CGPointMake(11.68, 19.63) controlPoint1: CGPointMake(15.57, 11.47) controlPoint2: CGPointMake(11.68, 15.12)];
    [bezierPath addCurveToPoint: CGPointMake(20.36, 27.8) controlPoint1: CGPointMake(11.68, 24.14) controlPoint2: CGPointMake(15.57, 27.8)];
    [bezierPath addCurveToPoint: CGPointMake(29.04, 19.63) controlPoint1: CGPointMake(25.15, 27.8) controlPoint2: CGPointMake(29.04, 24.14)];
    [bezierPath addCurveToPoint: CGPointMake(20.36, 11.47) controlPoint1: CGPointMake(29.04, 15.12) controlPoint2: CGPointMake(25.15, 11.47)];
    [bezierPath closePath];
    [MyStyleKit.buttonNormal setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}

+ (void)drawGearHighlighted;
{
    
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(20, 2)];
    [bezierPath addLineToPoint: CGPointMake(22.71, 2.18)];
    [bezierPath addLineToPoint: CGPointMake(23.87, 6.04)];
    [bezierPath addCurveToPoint: CGPointMake(28.8, 8.32) controlPoint1: CGPointMake(24.46, 7.96) controlPoint2: CGPointMake(26.92, 9.11)];
    [bezierPath addLineToPoint: CGPointMake(32.52, 6.77)];
    [bezierPath addLineToPoint: CGPointMake(34.31, 8.82)];
    [bezierPath addLineToPoint: CGPointMake(32.41, 12.37)];
    [bezierPath addCurveToPoint: CGPointMake(34.28, 17.47) controlPoint1: CGPointMake(31.45, 14.14) controlPoint2: CGPointMake(32.39, 16.69)];
    [bezierPath addLineToPoint: CGPointMake(38, 19)];
    [bezierPath addLineToPoint: CGPointMake(37.82, 21.71)];
    [bezierPath addLineToPoint: CGPointMake(33.96, 22.87)];
    [bezierPath addCurveToPoint: CGPointMake(31.68, 27.8) controlPoint1: CGPointMake(32.04, 23.46) controlPoint2: CGPointMake(30.89, 25.92)];
    [bezierPath addLineToPoint: CGPointMake(33.23, 31.52)];
    [bezierPath addLineToPoint: CGPointMake(31.18, 33.31)];
    [bezierPath addLineToPoint: CGPointMake(27.63, 31.41)];
    [bezierPath addCurveToPoint: CGPointMake(22.53, 33.28) controlPoint1: CGPointMake(25.86, 30.45) controlPoint2: CGPointMake(23.31, 31.39)];
    [bezierPath addLineToPoint: CGPointMake(21, 37)];
    [bezierPath addLineToPoint: CGPointMake(18.29, 36.82)];
    [bezierPath addLineToPoint: CGPointMake(17.13, 32.96)];
    [bezierPath addCurveToPoint: CGPointMake(12.2, 30.68) controlPoint1: CGPointMake(16.54, 31.04) controlPoint2: CGPointMake(14.08, 29.89)];
    [bezierPath addLineToPoint: CGPointMake(8.48, 32.23)];
    [bezierPath addLineToPoint: CGPointMake(6.69, 30.18)];
    [bezierPath addLineToPoint: CGPointMake(8.59, 26.63)];
    [bezierPath addCurveToPoint: CGPointMake(6.72, 21.53) controlPoint1: CGPointMake(9.55, 24.86) controlPoint2: CGPointMake(8.61, 22.31)];
    [bezierPath addLineToPoint: CGPointMake(3, 20)];
    [bezierPath addLineToPoint: CGPointMake(3.18, 17.29)];
    [bezierPath addLineToPoint: CGPointMake(7.04, 16.13)];
    [bezierPath addCurveToPoint: CGPointMake(9.32, 11.2) controlPoint1: CGPointMake(8.96, 15.54) controlPoint2: CGPointMake(10.11, 13.08)];
    [bezierPath addLineToPoint: CGPointMake(7.77, 7.48)];
    [bezierPath addLineToPoint: CGPointMake(9.82, 5.69)];
    [bezierPath addLineToPoint: CGPointMake(13.37, 7.59)];
    [bezierPath addCurveToPoint: CGPointMake(18.47, 5.72) controlPoint1: CGPointMake(15.14, 8.55) controlPoint2: CGPointMake(17.69, 7.61)];
    [bezierPath addLineToPoint: CGPointMake(20, 2)];
    [bezierPath addLineToPoint: CGPointMake(20, 2)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(20.36, 11.47)];
    [bezierPath addCurveToPoint: CGPointMake(11.68, 19.63) controlPoint1: CGPointMake(15.57, 11.47) controlPoint2: CGPointMake(11.68, 15.12)];
    [bezierPath addCurveToPoint: CGPointMake(20.36, 27.8) controlPoint1: CGPointMake(11.68, 24.14) controlPoint2: CGPointMake(15.57, 27.8)];
    [bezierPath addCurveToPoint: CGPointMake(29.04, 19.63) controlPoint1: CGPointMake(25.15, 27.8) controlPoint2: CGPointMake(29.04, 24.14)];
    [bezierPath addCurveToPoint: CGPointMake(20.36, 11.47) controlPoint1: CGPointMake(29.04, 15.12) controlPoint2: CGPointMake(25.15, 11.47)];
    [bezierPath closePath];
    [MyStyleKit.buttonHighlighted setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}

+ (void)drawMore;
{
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(6.5, 17.5, 5, 5)];
    [MyStyleKit.buttonNormal setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(17.5, 17.5, 5, 5)];
    [MyStyleKit.buttonNormal setStroke];
    oval2Path.lineWidth = 1;
    [oval2Path stroke];
    
    
    //// Oval 3 Drawing
    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(28.5, 17.5, 5, 5)];
    [MyStyleKit.buttonNormal setStroke];
    oval3Path.lineWidth = 1;
    [oval3Path stroke];
}

+ (void)drawMoreHighlighted;
{
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(6.5, 17.5, 5, 5)];
    [MyStyleKit.buttonHighlighted setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(17.5, 17.5, 5, 5)];
    [MyStyleKit.buttonHighlighted setStroke];
    oval2Path.lineWidth = 1;
    [oval2Path stroke];
    
    
    //// Oval 3 Drawing
    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(28.5, 17.5, 5, 5)];
    [MyStyleKit.buttonHighlighted setStroke];
    oval3Path.lineWidth = 1;
    [oval3Path stroke];
}

#pragma mark Generated Images

+ (UIImage*)imageOfPlay;
{
    if (_imageOfPlay)
        return _imageOfPlay;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawPlay];
    _imageOfPlay = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfPlay;
}

+ (UIImage*)imageOfPlayHighlighted;
{
    if (_imageOfPlayHighlighted)
        return _imageOfPlayHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawPlayHighlighted];
    _imageOfPlayHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfPlayHighlighted;
}


+ (UIImage*)imageOfPause;
{
    if (_imageOfPause)
        return _imageOfPause;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawPause];
    _imageOfPause = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfPause;
}

+ (UIImage*)imageOfPauseHighlighted;
{
    if (_imageOfPauseHighlighted)
        return _imageOfPauseHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawPauseHighlighted];
    _imageOfPauseHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfPauseHighlighted;
}

+ (UIImage*)imageOfForward;
{
    if (_imageOfForward)
        return _imageOfForward;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawForward];
    _imageOfForward = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfForward;
}

+ (UIImage*)imageOfForwardHighlighted;
{
    if (_imageOfForwardHighlighted)
        return _imageOfForwardHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawForwardHighlighted];
    _imageOfForwardHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfForwardHighlighted;
}


+ (UIImage*)imageOfBack;
{
    if (_imageOfBack)
        return _imageOfBack;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawBack];
    _imageOfBack = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfBack;
}

+ (UIImage*)imageOfBackHighlighted;
{
    if (_imageOfBackHighlighted)
        return _imageOfBackHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawBackHighlighted];
    _imageOfBackHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfBackHighlighted;
}

+ (UIImage*)imageOfPrevious;
{
    if (_imageOfPrevious)
        return _imageOfPrevious;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawPrevious];
    _imageOfPrevious = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfPrevious;
}

+ (UIImage*)imageOfPreviousHighlighted;
{
    if (_imageOfPreviousHighlighted)
        return _imageOfPreviousHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawPreviousHighlighted];
    _imageOfPreviousHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfPreviousHighlighted;
}

+ (UIImage*)imageOfFollowing;
{
    if (_imageOfFollowing)
        return _imageOfFollowing;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawFollowing];
    _imageOfFollowing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfFollowing;
}

+ (UIImage*)imageOfFollowingHighlighted;
{
    if (_imageOfFollowingHighlighted)
        return _imageOfFollowingHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(50, 50), NO, 0.0f);
    [MyStyleKit drawFollowingHighlighted];
    _imageOfFollowingHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfFollowingHighlighted;
}

+ (UIImage*)imageOfMousePadIntro;
{
    if (_imageOfMousePadIntro)
        return _imageOfMousePadIntro;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(600, 400), NO, 0.0f);
    [MyStyleKit drawMousePadIntro];
    _imageOfMousePadIntro = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfMousePadIntro;
}

+ (UIImage*)imageOfMousePadIntro1Small;
{
    if (_imageOfMousePadIntro1Small)
        return _imageOfMousePadIntro1Small;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, 400), NO, 0.0f);
    [MyStyleKit drawMousePadIntro1Small];
    _imageOfMousePadIntro1Small = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfMousePadIntro1Small;
}

+ (UIImage*)imageOfMousePadIntro2Small;
{
    if (_imageOfMousePadIntro2Small)
        return _imageOfMousePadIntro2Small;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, 400), NO, 0.0f);
    [MyStyleKit drawMousePadIntro2Small];
    _imageOfMousePadIntro2Small = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfMousePadIntro2Small;
}

+ (UIImage*)imageOfMousePadIntro3Small;
{
    if (_imageOfMousePadIntro3Small)
        return _imageOfMousePadIntro3Small;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, 400), NO, 0.0f);
    [MyStyleKit drawMousePadIntro3Small];
    _imageOfMousePadIntro3Small = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfMousePadIntro3Small;
}

+ (UIImage*)imageOfMousePadIntro4Small;
{
    if (_imageOfMousePadIntro4Small)
        return _imageOfMousePadIntro4Small;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, 400), NO, 0.0f);
    [MyStyleKit drawMousePadIntro4Small];
    _imageOfMousePadIntro4Small = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfMousePadIntro4Small;
}

+ (UIImage*)imageOfGear;
{
    if (_imageOfGear)
        return _imageOfGear;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0.0f);
    [MyStyleKit drawGear];
    _imageOfGear = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfGear;
}

+ (UIImage*)imageOfGearHighlighted;
{
    if (_imageOfGearHighlighted)
        return _imageOfGearHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0.0f);
    [MyStyleKit drawGearHighlighted];
    _imageOfGearHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfGearHighlighted;
}

+ (UIImage*)imageOfMore;
{
    if (_imageOfMore)
        return _imageOfMore;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0.0f);
    [MyStyleKit drawMore];
    _imageOfMore = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfMore;
}

+ (UIImage*)imageOfMoreHighlighted;
{
    if (_imageOfMoreHighlighted)
        return _imageOfMoreHighlighted;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0.0f);
    [MyStyleKit drawMoreHighlighted];
    _imageOfMoreHighlighted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return _imageOfMoreHighlighted;
}
@end
