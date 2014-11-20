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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MyStyleKit : NSObject

// Colors
+ (UIColor*)navbar;
+ (UIColor*)buttonNormal;
+ (UIColor*)buttonHighlighted;
+ (UIColor*)intro;
+ (UIColor*)intro1;
+ (UIColor*)intro2;
+ (UIColor*)intro3;

// Drawing Methods
+ (void)drawPlay;
+ (void)drawPlayHighlighted;
+ (void)drawPause;
+ (void)drawPauseHighlighted;
+ (void)drawForward;
+ (void)drawForwardHighlighted;
+ (void)drawBack;
+ (void)drawBackHighlighted;
+ (void)drawPrevious;
+ (void)drawPreviousHighlighted;
+ (void)drawFollowing;
+ (void)drawFollowingHighlighted;
+ (void)drawMousePadIntro;
+ (void)drawMousePadIntro1Small;
+ (void)drawMousePadIntro2Small;
+ (void)drawMousePadIntro3Small;
+ (void)drawMousePadIntro4Small;
+ (void)drawGear;
+ (void)drawGearHighlighted;
+ (void)drawMore;
+ (void)drawMoreHighlighted;

// Generated Images
+ (UIImage*)imageOfPlay;
+ (UIImage*)imageOfPlayHighlighted;
+ (UIImage*)imageOfPause;
+ (UIImage*)imageOfPauseHighlighted;
+ (UIImage*)imageOfForward;
+ (UIImage*)imageOfForwardHighlighted;
+ (UIImage*)imageOfBack;
+ (UIImage*)imageOfBackHighlighted;
+ (UIImage*)imageOfPrevious;
+ (UIImage*)imageOfPreviousHighlighted;
+ (UIImage*)imageOfFollowing;
+ (UIImage*)imageOfFollowingHighlighted;
+ (UIImage*)imageOfMousePadIntro;
+ (UIImage*)imageOfMousePadIntro1Small;
+ (UIImage*)imageOfMousePadIntro2Small;
+ (UIImage*)imageOfMousePadIntro3Small;
+ (UIImage*)imageOfMousePadIntro4Small;
+ (UIImage*)imageOfGear;
+ (UIImage*)imageOfGearHighlighted;
+ (UIImage*)imageOfMore;
+ (UIImage*)imageOfMoreHighlighted;

@end
