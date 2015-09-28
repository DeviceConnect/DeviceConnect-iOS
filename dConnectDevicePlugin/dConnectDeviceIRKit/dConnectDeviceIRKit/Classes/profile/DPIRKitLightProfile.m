//
//  DPIRKitLightProfile.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitLightProfile.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitManager.h"
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitRESTfulRequest.h"

@interface DPIRKitLightProfile()
@property (nonatomic, weak) DPIRKitDevicePlugin *plugin;


@end

@implementation DPIRKitLightProfile
// 初期化
- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin
{
    self = [super init];
    if (self) {
        self.plugin = plugin;
        self.delegate = self;
    }
    return self;
    
}


- (BOOL)              profile:(DConnectLightProfile *)profile
    didReceiveGetLightRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId
{
    DConnectArray *lights = [DConnectArray array];
    DConnectMessage *virtualLight = [DConnectMessage new];
    
    [response setResult:DConnectMessageResultTypeOk];
    
    //全体の色を変えるためのID
    [virtualLight setString:@"1" forKey:DConnectLightProfileParamLightId];
    [virtualLight setString:@"照明" forKey:DConnectLightProfileParamName];
    
    [virtualLight setBool:NO forKey:DConnectLightProfileParamOn];
    [virtualLight setString:@"" forKey:DConnectLightProfileParamConfig];
    [lights addMessage:virtualLight];
    
    [response setArray:lights forKey:DConnectLightProfileParamLights];
    return YES;
}



- (BOOL)            profile:(DConnectLightProfile *)profile
 didReceivePostLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    lightId:(NSString*)lightId
                 brightness:(NSNumber*)brightness
                      color:(NSString*)color
                   flashing:(NSArray*)flashing
{
    return [self sendLightIRRequestWithServiceId:serviceId
                                          method:@"POST"
                                         request:request
                                        response:response];

}


- (BOOL)                 profile:(DConnectLightProfile *)profile
    didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                         lightId:(NSString*)lightId
{
    return [self sendLightIRRequestWithServiceId:serviceId
                                          method:@"DELETE"
                                         request:request
                                        response:response];
}

#pragma mark - private method

- (BOOL)sendLightIRRequestWithServiceId:(NSString *)serviceId
                                 method:(NSString *)method
                                request:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
{
    BOOL send = YES;
    NSArray *requests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:serviceId];
    for (DPIRKitRESTfulRequest *req in requests) {
        NSString *uri = [NSString stringWithFormat:@"/%@",[request profile]];
        if ([req.uri isEqualToString:uri] && [req.method isEqualToString:method]
            && req.ir) {
            send = [_plugin sendIRWithServiceId:serviceId message:req.ir response:response];
        } else {
            [response setErrorToIllegalServerStateWithMessage:@"IR not registered"];
        }
    }
    return send;
}

@end
