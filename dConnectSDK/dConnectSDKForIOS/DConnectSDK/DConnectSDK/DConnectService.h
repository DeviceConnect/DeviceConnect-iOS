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

extern NSString * const DConnectServiceAnonymousOrigin;

extern NSString * const DConnectServiceInnerType;
extern NSString * const DConnectServiceInnerTypeHttp;


@class DConnectService;

@protocol OnStatusChangeListener <NSObject>

- (void) didStatusChange: (DConnectService *)service;

@end

@interface DConnectService : DConnectProfileProvider<DConnectServiceInformationProfileDataSource>

/*!
 @brief サービスID.
 */
@property(nonatomic, strong) NSString *serviceId;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) NSString *networkType;

@property(readwrite, getter=online, setter=setOnline:) BOOL online;

@property(nonatomic, strong) NSString *config;

@property(nonatomic, weak) id<OnStatusChangeListener> statusListener;


- (instancetype) initWithServiceId: (NSString *)serviceId plugin: (id) plugin;

- (BOOL) didReceiveRequest: (DConnectRequestMessage *) request response: (DConnectResponseMessage *)response;

@end
