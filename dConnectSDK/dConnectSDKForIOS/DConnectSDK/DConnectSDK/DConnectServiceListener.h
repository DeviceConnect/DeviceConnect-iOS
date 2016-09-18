//
//  DConnectServiceListener.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

@class DConnectService;

@protocol DConnectServiceListener <NSObject>
@optional

- (void) didServiceAdded: (DConnectService *) service;

- (void) didServiceRemoved: (DConnectService *) service;

- (void) didStatusChange: (DConnectService *) service;

@end
