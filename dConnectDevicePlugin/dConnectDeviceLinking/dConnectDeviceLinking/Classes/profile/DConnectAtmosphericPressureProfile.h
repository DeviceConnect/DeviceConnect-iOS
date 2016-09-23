//
//  DConnectAtmosphericPressureProfile.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

extern NSString *const DConnectAtmosphericPressureProfileName;
extern NSString *const DConnectAtmoshpericPressureProfileParamAtmosphericPressure;
extern NSString *const DConnectAtmoshpericPressureProfileParamTimeStamp;
extern NSString *const DConnectAtmoshpericPressureProfileParamTimeStampString;

@interface DConnectAtmosphericPressureProfile : DConnectProfile

+ (void) setAtmosphericPressure:(float)atmosphericPressure target:(DConnectMessage *)message;
+ (void) setTimeStamp:(long)timeStamp target:(DConnectMessage *)message;

@end
