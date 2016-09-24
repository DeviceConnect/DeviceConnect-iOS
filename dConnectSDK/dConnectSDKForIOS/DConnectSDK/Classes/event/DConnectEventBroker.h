//
//  DConnectEventBroker.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DConnectManager.h"
#import "DConnectEventSessionTable.h"
#import "DConnectLocalOAuthDB.h"
#import "DConnectDevicePluginManager.h"
#import "DConnectDevicePlugin.h"

@protocol DConnectEventRegistrationListener <NSObject>

- (void) onPutEventSession: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) plugin;
- (void) onDeleteEventSession: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) plugin;

@end

@interface DConnectEventBroker : NSObject

- (instancetype) initWithContext : (/* DConnectMessageService */DConnectManager *) context
                            table: (DConnectEventSessionTable *) table
                       localOAuth: (DConnectLocalOAuthDB *) localOAuth
                    pluginManager: (DConnectDevicePluginManager *)pluginManager;


- (void) setRegistrationListener: (id<DConnectEventRegistrationListener>) listener;

- (void) onRequest: (DConnectMessage *) request plugin: (DConnectDevicePlugin *) dest;

@end
