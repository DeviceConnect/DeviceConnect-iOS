//
//  DCMTVProfile.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMTVProfile.h"


NSString *const DCMTVProfileName = @"tv";


NSString *const DCMTVProfileAttrChannel = @"channel";

NSString *const DCMTVProfileAttrVolume = @"volume";

NSString *const DCMTVProfileAttrBroadcastwave = @"broadcastwave";

NSString *const DCMTVProfileAttrMute = @"mute";

NSString *const DCMTVProfileAttrEnlproperty = @"enlproperty";

NSString *const DCMTVProfileParamControl = @"control";

NSString *const DCMTVProfileParamTuning = @"tuning";

NSString *const DCMTVProfileParamSelect = @"select";

NSString *const DCMTVProfileParamEPC = @"epc";

NSString *const DCMTVProfileParamValue = @"value";

NSString *const DCMTVProfileParamPowerStatus = @"powerstatus";

NSString *const DCMTVProfileParamProperties = @"properties";

NSString *const DCMTVProfileParamPowerStatusOn = @"ON";
NSString *const DCMTVProfileParamPowerStatusOff = @"OFF";
NSString *const DCMTVProfileParamPowerStatusUnknown = @"UNKNOWN";

NSString *const DCMTVProfileChannelStateNext = @"next";
NSString *const DCMTVProfileChannelStatePrevious = @"previous";

NSString *const DCMTVProfileVolumeStateUp = @"up";
NSString *const DCMTVProfileVolumeStateDown = @"down";


NSString *const DCMTVProfileBroadcastwaveDTV = @"DTV";
NSString *const DCMTVProfileBroadcastwaveBS = @"BS";
NSString *const DCMTVProfileBroadcastwaveCS = @"CS";


@implementation DCMTVProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DCMTVProfileName;
}

@end
