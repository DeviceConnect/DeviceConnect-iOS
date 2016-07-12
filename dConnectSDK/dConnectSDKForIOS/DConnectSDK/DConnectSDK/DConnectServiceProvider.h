//
//  DConnectServiceProvider.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectService.h>

@class DConnectService;

@protocol DConnectServiceProvider <NSObject>

- (BOOL) hasService: (NSString *) serviceId;

- (DConnectService *) service: (NSString *) serviceId;

/*!
 @brief サービス配列を返す.
 @retval DConnectServiceの配列
 */
- (NSArray *) services;

- (void) addService: (DConnectService *) service;

- (void) removeService: (DConnectService *) service;

- (void) removeAllServices;

@end
