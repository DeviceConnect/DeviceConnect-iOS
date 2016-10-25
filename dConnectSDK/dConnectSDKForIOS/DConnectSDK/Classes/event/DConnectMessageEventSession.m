//
//  DConnectMessageEventSession.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectMessageEventSession.h"
#import "DConnectManager+Private.h"

@interface DConnectMessageEventSession()

@property (nonatomic, weak) id<DConnectManagerDelegate> delegate;

@property (nonatomic, weak) DConnectWebSocket *webSocket;

@property (nonatomic, weak) NSString *origin;

@property (nonatomic, weak) DConnectManager *manager;

@end

@implementation DConnectMessageEventSession

- (instancetype) initWithDelegate: (id<DConnectManagerDelegate>) delegate webSocket: (DConnectWebSocket *) webSocket origin: (NSString *) origin {
    
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.webSocket = webSocket;
        self.origin = origin;
    }
    return self;
}


#pragma mark - Override Methods.

- (void) sendEvent: (DConnectMessage *) event {

    if ([self.delegate respondsToSelector:@selector(manager:didReceiveDConnectMessage:)]) {
        [self.delegate manager:self.context didReceiveDConnectMessage:event];
    } else {
        NSString *json = [event convertToJSONString];
        [[DConnectManager sharedManager].webServer sendEvent:json forReceiverId:self.receiverId];
    }
}

@end
