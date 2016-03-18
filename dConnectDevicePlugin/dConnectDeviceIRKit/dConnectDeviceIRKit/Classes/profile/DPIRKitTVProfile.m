//
//  DPIRKitTVProfile.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitTVProfile.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitManager.h"
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitRESTfulRequest.h"


@interface DPIRKitTVProfile()
@property (nonatomic, weak) DPIRKitDevicePlugin *plugin;
@end

@implementation DPIRKitTVProfile
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


- (BOOL)                        profile:(DCMTVProfile *)profile
                 didReceivePutTVRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
{
    NSString *uri = [NSString stringWithFormat:@"/%@",[request profile]];

    return [self sendTVIRRequestWithServiceId:serviceId
                                       method:@"PUT"
                                          uri:uri
                                     response:response];
}

- (BOOL)                        profile:(DCMTVProfile *)profile
              didReceiveDeleteTVRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
{
    NSString *uri = [NSString stringWithFormat:@"/%@",[request profile]];
    
    return [self sendTVIRRequestWithServiceId:serviceId
                                       method:@"DELETE"
                                          uri:uri
                                     response:response];
}

- (BOOL)                        profile:(DCMTVProfile *)profile
          didReceivePutTVChannelRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                 tuning:(NSString *)tuning
                                 control:(NSString *)control
{
    NSString *uri = [NSString stringWithFormat:@"/%@/%@?%@=%@",
                                                 [request profile],
                                                 [request attribute],
                                                 DCMTVProfileParamControl,
                                                  control];
    if (tuning) {
        uri = [NSString stringWithFormat:@"/%@/%@?%@=%@",
                                                 [request profile],
                                                 [request attribute],
                                                 DCMTVProfileParamTuning,
                                                 tuning];
    } else if (tuning && control) {
        uri = [NSString stringWithFormat:@"/%@/%@?%@=%@&%@=%@",
               [request profile],
               [request attribute],
               DCMTVProfileParamTuning,
               tuning,
               DCMTVProfileParamControl,
               control];

        
    }

    return [self sendTVIRRequestWithServiceId:serviceId
                                       method:@"PUT"
                                          uri:uri
                                     response:response];

}


- (BOOL)                        profile:(DCMTVProfile *)profile
           didReceivePutTVVolumeRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                 control:(NSString *)control
{
    NSString *uri = [NSString stringWithFormat:@"/%@/%@?%@=%@",
                     [request profile],
                     [request attribute],
                     DCMTVProfileParamControl,
                     control];
    
    return [self sendTVIRRequestWithServiceId:serviceId
                                       method:@"PUT"
                                          uri:uri
                                     response:response];
    
}


- (BOOL)                        profile:(DCMTVProfile *)profile
    didReceivePutTVBroadcastWaveRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                 select:(NSString *)select
{
    NSString *uri = [NSString stringWithFormat:@"/%@/%@?%@=%@",
                     [request profile],
                     [request attribute],
                     DCMTVProfileParamSelect,
                     select];
    
    return [self sendTVIRRequestWithServiceId:serviceId
                                       method:@"PUT"
                                          uri:uri
                                     response:response];
    
}




#pragma mark - private method

- (BOOL)sendTVIRRequestWithServiceId:(NSString *)serviceId
                                 method:(NSString *)method
                                    uri:(NSString *)uri
                               response:(DConnectResponseMessage *)response
{
    BOOL send = YES;
    NSArray *requests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:serviceId
                                                                                  profile:@"/tv"];
    if (requests.count == 0) {
        [response setErrorToNotSupportProfile];
        return send;
    }
    for (DPIRKitRESTfulRequest *req in requests) {
        if ([req.uri isEqualToString:uri] && [req.method isEqualToString:method] && req.ir) {
            sleep(0.5);
            send = [_plugin sendIRWithServiceId:serviceId message:req.ir response:response];
        } else {
            [response setErrorToInvalidRequestParameterWithMessage:@"IR is not registered for that request"];
        }
    }
    return send;
}

@end
