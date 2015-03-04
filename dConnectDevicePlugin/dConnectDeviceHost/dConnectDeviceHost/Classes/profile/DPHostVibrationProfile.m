//
//  DPHostVibrationProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AudioToolbox/AudioToolbox.h>

#import "DPHostVibrationProfile.h"

@implementation DPHostVibrationProfile

- (instancetype)init
{
    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) {
        // iPhoneを除く以下のモデルは振動機能無しという事にする。
        // iPod touch, iPhone Simulator, iPad, iPad Simulator
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - Put Methods

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!self.delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([attribute isEqualToString:DConnectVibrationProfileAttrVibrate]) {
        NSString *patternStr = [DConnectVibrationProfile patternFromRequest:request];
        NSArray *pattern = patternStr ? [self parsePattern:patternStr] : nil;
        send = [self profile:self didReceivePutVibrateRequest:request response:response
                    serviceId:[request serviceId] pattern:pattern];
    } else {
        [response setErrorToUnknownAttribute];
    }
    
    return send;
}

- (BOOL)            profile:(DConnectVibrationProfile *)profile
didReceivePutVibrateRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                   serviceId:(NSString *)serviceId
                    pattern:(NSArray *) pattern
{
    if (!pattern) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:
            @"pattern is not supported; This parameter must be ommited."];
    }
    return YES;
}

#pragma mark - Delete Methods
- (BOOL)               profile:(DConnectVibrationProfile *)profile
didReceiveDeleteVibrateRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    [response setErrorToNotSupportProfileWithMessage:@"Vibration Stop API is not supported."];
    return YES;
}

@end
