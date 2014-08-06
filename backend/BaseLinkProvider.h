//
//  BaseLinkProvider.h
//  kdeconnect_test1
//
//  Created by yangqiao on 4/27/14.
//  
//

#import <Foundation/Foundation.h>
#import "NetworkPackage.h"
#import "BaseLink.h"

@interface BaseLinkProvider : NSObject

@property(nonatomic) id _linkProviderDelegate;
@property(nonatomic) NSMutableDictionary* _connectedLinks;

- (BaseLinkProvider*) initWithDelegate:(id)linkProviderDelegate;
- (void) onStart;
- (void) onRefresh;
- (void) onStop;
- (void) onNetworkChange;
- (void) onLinkDestroyed:(BaseLink*)link;

@end

@protocol linkProviderDelegate <NSObject>
@optional
- (void) onConnectionReceived:(NetworkPackage*)np link:(BaseLink*)link;
@end
