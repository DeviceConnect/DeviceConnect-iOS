//
//  DPAllJoynSupportCheck.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>


@class AJNMessageArgument;
@class DPAllJoynServiceEntity;


@interface DPAllJoynSupportCheck : NSObject

+ (instancetype)alloc NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/*!
 @retval YES AllJoyn service can be a Device Connect service.
 @retval NO AllJoyn service can not be a Device Connect service.
 */
+ (BOOL)isSupported:(AJNMessageArgument *)busObjectDescriptions;
/*!
 Returns names of Device Connect profiles that can be implemented using a
 specified AllJoyn service.
 */
+ (NSArray *)supportedProfileNamesWithProvider:(id<DConnectProfileProvider>)provider
                                       service:(DPAllJoynServiceEntity *)service;
/*!
 @retval YES AllJoyn interfaces are supported in the AllJoyn service.
 @retval NO AllJoyn interfaces are not supported in the AllJoyn service.
 */
+ (BOOL)areAJInterfacesSupported:(NSArray *)ifaces
                     withService:(DPAllJoynServiceEntity *)service;

/*!
 Returns a dictionary supporting specified interfaces where key and value are
 object path and interfaces respectively.
 */
+ (NSDictionary *)objectPathDescriptionsWithInterface:(NSArray *)ifaces
                                              service:(DPAllJoynServiceEntity *)service;

@end
