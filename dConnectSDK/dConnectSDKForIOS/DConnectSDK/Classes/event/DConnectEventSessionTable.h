//
//  DConnectEventSessionTable.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectEventSession.h"
#import "DConnectDevicePlugin.h"

@interface DConnectEventSessionTable : NSObject

- (NSArray *) all;

- (NSArray *) findEventSessionsForPlugin: (DConnectDevicePlugin *) plugin;

- (void) add: (DConnectEventSession *) session;

- (void) remove: (DConnectEventSession *) session;

@end
