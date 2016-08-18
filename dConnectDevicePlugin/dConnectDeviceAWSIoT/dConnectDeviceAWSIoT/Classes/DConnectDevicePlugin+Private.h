//
//  DConnectMessage_Private.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DConnectDevicePlugin ()

- (BOOL) executeRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;

@end
