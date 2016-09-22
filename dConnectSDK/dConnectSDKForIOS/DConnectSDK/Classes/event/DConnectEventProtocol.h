//
//  DConnectEventProtocol.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DConnectEventSession.h"
#import "DConnectEventSessionTable.h"

@interface DConnectEventProtocol : NSObject

@property(nonatomic, weak) /*DConnectMessageService*/ DConnectManager *messageService;

+ (DConnectEventProtocol *) getInstance: (/*DConnectMessageService * */DConnectManager *) context
                                request: (DConnectRequestMessage *) request;

- (BOOL) removeSession: (DConnectEventSessionTable *) table request: (DConnectRequestMessage *) request plugin: (DConnectDevicePlugin *)plugin;

- (BOOL) addSession: (DConnectEventSessionTable *) table request: (DConnectRequestMessage *) request plugin: (DConnectDevicePlugin *) plugin;

+ (NSString *) convertSessionKey2PluginId: (NSString *) sessionKey;

+ (NSString *) convertSessionKey2Key: (NSString *) sessionKey;

@end
