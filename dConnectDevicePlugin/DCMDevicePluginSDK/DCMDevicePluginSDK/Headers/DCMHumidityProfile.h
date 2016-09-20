//
//  DCMHumidityProfile.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#ifndef DCMHumidityProfile_h
#define DCMHumidityProfile_h

#import <DConnectSDK/DConnectSDK.h>

/*!
 @brief プロファイル名: humidity。
 */
extern NSString *const DCMHumidityProfileName;
extern NSString *const DCMHumidityProfileParamHumidity;
extern NSString *const DCMHumidityProfileParamTimeStamp;
extern NSString *const DCMHumidityProfileParamTimeStampString;


@class DCMHumidityProfile;

@protocol DCMHumidityProfileDelegate <NSObject>
@optional
@end

@interface DCMHumidityProfile : DConnectProfile

@property (nonatomic, assign) id<DCMHumidityProfileDelegate> delegate;

+ (void) setHumidity:(float)humidity target:(DConnectMessage *)message;
+ (void) setTimeStamp:(long)timeStamp target:(DConnectMessage *)message;

@end

#endif /* DCMHumidityProfile_h */
