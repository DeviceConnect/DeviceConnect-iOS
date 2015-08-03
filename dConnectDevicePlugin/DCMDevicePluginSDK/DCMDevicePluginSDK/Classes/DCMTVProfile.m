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

NSString *const DCMTVProfileParamTVId = @"tvId";

NSString *const DCMTVProfileParamAction = @"action";

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
    NSString *tvId = [request stringForKey:DCMTVProfileParamTVId];
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    if (profile) {
        if ([profile isEqualToString:DCMTVProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:didReceiveGetTVRequest:response:serviceId:tvId:) response:response])
        {
            
            send = [_delegate profile:self
            didReceiveGetTVRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId
                    ];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrEnlproperty]
                   && [self hasMethod:@selector(profile:
                                                didReceiveGetTVEnlpropertyRequest:
                                                response:
                                                serviceId:
                                                tvId:
                                                epc:)
                             response:response])
        {
            NSString *epc = [request stringForKey:DCMTVProfileParamEPC];
            send = [_delegate profile:self
       didReceiveGetTVEnlpropertyRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId
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
    NSLog(@"put");
    NSString *serviceId = [request serviceId];
    NSString *tvId = [request stringForKey:DCMTVProfileParamTVId];
    NSString *tuning = [request stringForKey:DCMTVProfileParamTuning];
    NSString *action = [request stringForKey:DCMTVProfileParamAction];
    NSString *select = [request stringForKey:DCMTVProfileParamSelect];
    NSString *epc = [request stringForKey:DCMTVProfileParamEPC];
    NSString *value = [request stringForKey:DCMTVProfileParamValue];
    
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([profile isEqualToString:DCMTVProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceivePutTVRequest:
                                         response:
                                         serviceId:
                                         tvId:)
                      response:response])
        {
            send = [_delegate profile:self
            didReceivePutTVRequest:request
                             response:response
                            serviceId:serviceId
                              tvId:tvId];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrChannel]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVChannelRequest:
                                                response:
                                                serviceId:
                                                tvId:
                                                tuning:
                                                action:)
                             response:response])
        {
            send = [_delegate profile:self
       didReceivePutTVChannelRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId
                               tuning:tuning
                           action:action];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrVolume]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVVolumeRequest:
                                                response:
                                                serviceId:
                                                tvId:
                                                action:)
                             response:response])
        {
            send = [_delegate profile:self
        didReceivePutTVVolumeRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId
                               action:action];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrBroadcastwave]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVBroadcastWaveRequest:
                                                response:
                                                serviceId:
                                                tvId:
                                                select:)
                             response:response])
        {
            send = [_delegate profile:self
         didReceivePutTVBroadcastWaveRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId
                               select:select];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrMute]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVMuteRequest:
                                                response:
                                                serviceId:
                                                tvId:)
                             response:response])
        {
            send = [_delegate profile:self
           didReceivePutTVMuteRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrEnlproperty]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutTVEnlpropertyRequest:
                                                response:
                                                serviceId:
                                                tvId:
                                                epc:
                                                value:)
                             response:response])
        {
            send = [_delegate        profile:self
           didReceivePutTVEnlpropertyRequest:request
                                    response:response
                                   serviceId:serviceId
                                        tvId:tvId
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
    NSString *tvId = [request stringForKey:DCMTVProfileParamTVId];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([profile isEqualToString:DCMTVProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceiveDeleteTVRequest:
                                         response:
                                         serviceId:
                                         tvId:)
                      response:response])
        {
            send = [_delegate profile:self
            didReceiveDeleteTVRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId];
        } else if ([profile isEqualToString:DCMTVProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMTVProfileAttrMute]
                   && [self hasMethod:@selector(profile:
                                                didReceiveDeleteTVMuteRequest:
                                                response:
                                                serviceId:
                                                tvId:)
                             response:response])
        {
            send = [_delegate profile:self
        didReceiveDeleteTVMuteRequest:request
                             response:response
                            serviceId:serviceId
                                 tvId:tvId];
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