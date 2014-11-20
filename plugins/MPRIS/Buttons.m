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
//----------------------------------------------------------------------

#import "Buttons.h"
#import "MyStyleKit.h"

@interface PlayPauseButton ()
{
    bool isplay;
}
@end

@implementation PlayPauseButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isplay=true;
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    if (isplay) {
        [self setImage:[MyStyleKit imageOfPlay] forState:UIControlStateNormal];
        [self setImage:[MyStyleKit imageOfPlayHighlighted] forState:UIControlStateHighlighted];
    }
    else{
        [self setImage:[MyStyleKit imageOfPause] forState:UIControlStateNormal];
        [self setImage:[MyStyleKit imageOfPauseHighlighted] forState:UIControlStateHighlighted];
    }


}

- (void) setplay
{
    isplay=true;
    [self setNeedsDisplay];
}

- (void) setpause
{
    isplay=false;
    [self setNeedsDisplay];
}

@end

@implementation ForwardButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfForward] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfForwardHighlighted] forState:UIControlStateHighlighted];
}

@end

@implementation BackButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfBack] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfBackHighlighted] forState:UIControlStateHighlighted];
}

@end

@implementation PreviousButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfPrevious] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfPreviousHighlighted] forState:UIControlStateHighlighted];
}

@end

@implementation FollowingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [self setImage:[MyStyleKit imageOfFollowing] forState:UIControlStateNormal];
    [self setImage:[MyStyleKit imageOfFollowingHighlighted] forState:UIControlStateHighlighted];
}

@end
