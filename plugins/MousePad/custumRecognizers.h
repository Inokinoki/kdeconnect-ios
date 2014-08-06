//
//  custumRecognizers.h
//  kdeconnect-ios
//
//  Created by YANG Qiao on 7/4/14.
//  
//

#import <UIKit/UIKit.h>

@interface custumRecognizer : UIGestureRecognizer
- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end
