//
//  custumRecognizers.m
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/4/14.
//  
//

#import "custumRecognizers.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation custumRecognizer

- (void)reset
{
    [super reset];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}
@end
