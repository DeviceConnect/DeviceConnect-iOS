//
//  DPHostSettingProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostSettingProfile.h"
#import "DPHostUtils.h"

@implementation DPHostSettingProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // API登録(didReceiveGetDateRequest相当)
        NSString *getDateRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectSettingProfileAttrDate];
        [self addGetPath: getDateRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
                          NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                          
                          [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
                          [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
                          [rfc3339DateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                          
                          [DConnectSettingProfile setDate:[rfc3339DateFormatter stringFromDate:[NSDate date]] target:response];
                          [response setResult:DConnectMessageResultTypeOk];
                          
                          return YES;
                      }];

        // API登録(didReceiveGetLightRequest相当)
        NSString *getLightRequestApiPath = [self apiPath: DConnectSettingProfileInterfaceDisplay
                                           attributeName: DConnectSettingProfileAttrBrightness];
        [self addGetPath: getLightRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         [DConnectSettingProfile setLightLevel:[UIScreen mainScreen].brightness target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];

        // API登録(didReceivePutLightRequest相当)
        NSString *putLightRequestApiPath = [self apiPath: DConnectSettingProfileInterfaceDisplay
                                           attributeName: DConnectSettingProfileAttrBrightness];
        [self addPutPath: putLightRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSNumber *level = [DConnectSettingProfile levelFromRequest:request];
                         
                         if (!level) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"level must be specified."];
                             return YES;
                         }
                         NSString *levelString = [request stringForKey:DConnectSettingProfileParamLevel];
                         if ([level compare:@0] == NSOrderedAscending || [level compare:@1] == NSOrderedDescending
                             || !levelString || ![DPHostUtils existFloatWithString:levelString]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"level must be within range of [0, 1.0]."];
                             return YES;
                         }
                         
                         [UIScreen mainScreen].brightness = [level doubleValue];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
    }
    return self;
}

@end
