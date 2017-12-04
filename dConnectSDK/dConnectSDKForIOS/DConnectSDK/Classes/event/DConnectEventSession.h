//
//  DConnectEventSession.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DConnectEventSession : NSObject

@property(nonatomic, weak) /* DConnectMessageService */ DConnectManager *context;
@property(nonatomic, strong) NSString *receiverId;
@property(nonatomic, strong) NSString *serviceId;
@property(nonatomic, strong) NSString *pluginId;
@property(nonatomic, strong) NSString *profileName;
@property(nonatomic, strong) NSString *interfaceName;
@property(nonatomic, strong) NSString *attributeName;
@property(nonatomic, strong) NSString *accessToken;

#pragma mark - Override Methods.

- (void) sendEvent: (DConnectMessage *) event;

@end
