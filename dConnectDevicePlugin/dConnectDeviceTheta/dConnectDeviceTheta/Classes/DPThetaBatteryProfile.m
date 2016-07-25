//
//  DPThetaBatteryProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaDevicePlugin.h"
#import "DPThetaBatteryProfile.h"
#import "DPThetaManager.h"

@interface DPThetaBatteryProfile ()

@end

@implementation DPThetaBatteryProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
        // API登録(didReceiveGetLevelRequest相当)
        NSString *getLevelRequestApiPath = [self apiPathWithProfile: self.profileName
                                                      interfaceName: nil
                                                      attributeName: DConnectBatteryProfileAttrLevel];
        [self addGetPath: getLevelRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            CONNECT_CHECK();
            float level = [[DPThetaManager sharedManager] getBatteryLevel] / (float) 100.0;
            if (level < 0 || level > 1) {
                // 未知のステータス；エラーレスポンスを返す。
                [response setErrorToUnknownWithMessage:@"Battery status is unknown."];
            } else {
                [DConnectBatteryProfile setLevel:level target:response];
                [response setResult:DConnectMessageResultTypeOk];
            }
            return YES;
            
        }];
        
        // API登録(didReceiveGetAllRequest相当)
        NSString *getAllRequestApiPath = [self apiPathWithProfile: self.profileName
                                                    interfaceName: nil
                                                    attributeName: nil];
        [self addGetPath: getAllRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            CONNECT_CHECK();
            float level = [[DPThetaManager sharedManager] getBatteryLevel] / (float) 100.0;
            if (level >= 0 && level <= 1) {
                [response setResult:DConnectMessageResultTypeOk];
                [DConnectBatteryProfile setCharging:NO target:response];
                [DConnectBatteryProfile setLevel:level target:response];
            } else {
                // 未知のステータス；エラーレスポンスを返す。
                [response setErrorToUnknownWithMessage:@"Battery status is unknown."];
            }
            return YES;
        }];
        
    }
    return self;
}

@end
