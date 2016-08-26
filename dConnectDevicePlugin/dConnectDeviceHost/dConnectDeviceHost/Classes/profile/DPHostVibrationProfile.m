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
#import "DPHostUtils.h"

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
        __weak DPHostVibrationProfile *weakSelf = self;
        
        // API登録(didReceivePutVibrateRequest相当)
        NSString *putVibrateRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectVibrationProfileAttrVibrate];
        [self addPutPath: putVibrateRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *patternStr = [DConnectVibrationProfile patternFromRequest:request];
                         NSArray *pattern = patternStr ? [weakSelf parsePattern:patternStr] : nil;
                         
                         NSString *patternString = [request stringForKey:DConnectVibrationProfileParamPattern];
                         if ((patternString
                              && ![DPHostUtils existCSVWithString:patternString]
                              && ![DPHostUtils existDigitWithString:patternString])
                             || (patternString
                                 && [DPHostUtils existCSVWithString:patternString]
                                 && ![self existNumberInArray:pattern])
                             || (patternString
                                 && [DPHostUtils existCSVWithString:patternString]
                                 && ![DPHostUtils existDigitWithString:patternString]
                                 && ![self existNumberInArray:pattern])
                             ) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }
                         AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                         [response setResult:DConnectMessageResultTypeOk];
                         
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteVibrateRequest相当)
        NSString *deleteVibrateRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectVibrationProfileAttrVibrate];
        [self addDeletePath: deleteVibrateRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            [response setErrorToNotSupportProfileWithMessage:@"Vibration Stop API is not supported."];
                            return YES;
                        }];
    }
    return self;
}

#pragma mark - Private Methods

- (BOOL)existNumberInArray:(NSArray*)pattern
{
    if (pattern) {
        for (NSNumber *pat in pattern) {
            if (![DPHostUtils existDigitWithString:pat.stringValue]
                || pat.intValue < 0) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}


@end
