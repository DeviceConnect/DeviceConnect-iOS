//
//  DConnectService.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectServiceProvider.h>
#import <DConnectSDK/DConnectProfileProvider.h>

@interface DConnectService : DConnectProfileProvider

/*!
 @brief サービスID.
 */
@property(nonatomic, strong) NSString *serviceId;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) NSString *networkType;

@property(nonatomic) BOOL isOnline;

@property(nonatomic, strong) NSString *config;


- (instancetype) initWithServiceId: (NSString *)serviceId;

- (BOOL) onRequest: request response: response;

@end
