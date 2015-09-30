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


@interface DCMTVProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DCMTVProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DCMTVProfileName;
}

#pragma mark - DConnectProfile Method


/*
 GETリクエストを振り分ける。
 */
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    if (profile) {
        if ([profile isEqualToString:DCMTVProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:didReceiveGetTVRequest:response:serviceId:) response:response])
        {
            
            send = [_delegate profile:self
            didReceiveGetTVRequest:request
                             response:response
                            serviceId:serviceId
                    ];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrEnlproperty]
                   && [self hasMethod:@selector(profile:
                                                didReceiveGetTVEnlpropertyRequest:
                                                response:
                                                serviceId:
                                                epc:)
                             response:response])
        {
            NSString *epc = [request stringForKey:DCMTVProfileParamEPC];
            send = [_delegate profile:self
       didReceiveGetTVEnlpropertyRequest:request
                             response:response
                            serviceId:serviceId
                                  epc:epc];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}


/*
 PUTリクエストを振り分ける。
 */
- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    NSString *serviceId = [request serviceId];
    NSString *tuning = [request stringForKey:DCMTVProfileParamTuning];
    NSString *control = [request stringForKey:DCMTVProfileParamControl];
    NSString *select = [request stringForKey:DCMTVProfileParamSelect];
    NSString *epc = [request stringForKey:DCMTVProfileParamEPC];
    NSString *value = [request stringForKey:DCMTVProfileParamValue];
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([profile isEqualToString:DCMTVProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceivePutTVRequest:
                                         response:
                                         serviceId:)
                      response:response])
        {
            send = [_delegate profile:self
            didReceivePutTVRequest:request
                             response:response
                            serviceId:serviceId];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrChannel]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVChannelRequest:
                                                response:
                                                serviceId:
                                                tuning:
                                                control:)
                             response:response])
        {
            send = [_delegate profile:self
       didReceivePutTVChannelRequest:request
                             response:response
                            serviceId:serviceId
                               tuning:tuning
                               control:control];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrVolume]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVVolumeRequest:
                                                response:
                                                serviceId:
                                                control:)
                             response:response])
        {
            send = [_delegate profile:self
        didReceivePutTVVolumeRequest:request
                             response:response
                            serviceId:serviceId
                               control:control];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrBroadcastwave]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVBroadcastWaveRequest:
                                                response:
                                                serviceId:
                                                select:)
                             response:response])
        {
            send = [_delegate profile:self
         didReceivePutTVBroadcastWaveRequest:request
                             response:response
                            serviceId:serviceId
                               select:select];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrMute]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVMuteRequest:
                                                response:
                                                serviceId:)
                             response:response])
        {
            send = [_delegate profile:self
           didReceivePutTVMuteRequest:request
                             response:response
                            serviceId:serviceId];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrEnlproperty]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVEnlpropertyRequest:
                                                response:
                                                serviceId:
                                                epc:
                                                value:)
                             response:response])
        {
            send = [_delegate        profile:self
           didReceivePutTVEnlpropertyRequest:request
                                    response:response
                                   serviceId:serviceId
                                         epc:epc
                                       value:value];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

/*
 DELETEリクエストを振り分ける。
 */
- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([profile isEqualToString:DCMTVProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceiveDeleteTVRequest:
                                         response:
                                         serviceId:)
                      response:response])
        {
            send = [_delegate profile:self
            didReceiveDeleteTVRequest:request
                             response:response
                            serviceId:serviceId];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrMute]
                   && [self hasMethod:@selector(profile:
                                                didReceiveDeleteTVMuteRequest:
                                                response:
                                                serviceId:)
                             response:response])
        {
            send = [_delegate profile:self
        didReceiveDeleteTVMuteRequest:request
                             response:response
                            serviceId:serviceId];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}



#pragma mark - Private Methods


/*
 メソッドが存在するかを確認する。
 */
- (BOOL) hasMethod:(SEL)method
          response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
