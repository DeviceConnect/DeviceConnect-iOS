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
#import <DConnectSDK/DConnectServiceInformationProfile.h>

@class DConnectService;

@protocol OnStatusChangeListener <NSObject>

- (void) didStatusChange: (DConnectService *)service;

@end

@interface DConnectService : DConnectProfileProvider

/*!
 @brief サービスID.
 */
@property(nonatomic, strong) NSString *serviceId;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) NSString *networkType;

@property(readwrite, getter=online, setter=setOnline:) BOOL online;

@property(nonatomic, strong) NSString *config;

@property(nonatomic, weak) id<OnStatusChangeListener> statusListener;


- (instancetype) initWithServiceId: (NSString *)serviceId plugin: (id) plugin dataSource: (id<DConnectServiceInformationProfileDataSource>) dataSource;

- (BOOL) didReceiveRequest: (DConnectRequestMessage *) request response: (DConnectResponseMessage *)response;

@end
