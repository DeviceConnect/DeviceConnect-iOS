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


@implementation DPIRKitTVProfile
// 初期化
- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin
{
    self = [super init];
    if (self) {
        self.plugin = plugin;
        __weak DPIRKitTVProfile *weakSelf = self;
        
        // API登録(didReceivePutTVRequest相当)
        NSString *putTVRequestApiPath = [self apiPath: nil
                                        attributeName: nil];
        [self addPutPath: putTVRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSString *serviceId = [request serviceId];
                         NSString *uri = [NSString stringWithFormat:@"/%@",[request profile]];
                         
                         return [weakSelf sendTVIRRequestWithServiceId:serviceId
                                                                method:@"PUT"
                                                                   uri:uri
                                                              response:response];
                     }];
        
        // API登録(didReceiveDeleteTVRequest相当)
        NSString *deleteTVRequestApiPath = [self apiPath: nil
                                           attributeName: nil];
        [self addDeletePath: deleteTVRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                            NSString *serviceId = [request serviceId];
                            NSString *uri = [NSString stringWithFormat:@"/%@",[request profile]];
                            
                            return [weakSelf sendTVIRRequestWithServiceId:serviceId
                                                                   method:@"DELETE"
                                                                      uri:uri
                                                                 response:response];
                        }];
        
        // API登録(didReceivePutTVChannelRequest相当)
        NSString *putTVChannelRequestApiPath = [self apiPath: nil
                                               attributeName: DCMTVProfileAttrChannel];
        [self addPutPath: putTVChannelRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSString *serviceId = [request serviceId];
                         NSString *tuning = [request stringForKey:DCMTVProfileParamTuning];
                         NSString *control = [request stringForKey:DCMTVProfileParamControl];
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
                         
                         return [weakSelf sendTVIRRequestWithServiceId:serviceId
                                                                method:@"PUT"
                                                                   uri:uri
                                                              response:response];
                         
                     }];
        
        // API登録(didReceivePutTVVolumeRequest相当)
        NSString *putTVVolumeRequestApiPath = [self apiPath: nil
                                              attributeName: DCMTVProfileAttrVolume];
        [self addPutPath: putTVVolumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *control = [request stringForKey:DCMTVProfileParamControl];

                         NSString *uri = [NSString stringWithFormat:@"/%@/%@?%@=%@",
                                          [request profile],
                                          [request attribute],
                                          DCMTVProfileParamControl,
                                          control];
                         
                         return [weakSelf sendTVIRRequestWithServiceId:serviceId
                                                                method:@"PUT"
                                                                   uri:uri
                                                              response:response];
                         
                     }];
        
        // API登録(didReceivePutTVBroadcastWaveRequest相当)
        NSString *putTVBroadcastWaveRequestApiPath = [self apiPath: nil
                                                     attributeName: DCMTVProfileAttrVolume];
        [self addPutPath: putTVBroadcastWaveRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *select = [request stringForKey:DCMTVProfileParamSelect];
                         NSString *uri = [NSString stringWithFormat:@"/%@/%@?%@=%@",
                                          [request profile],
                                          [request attribute],
                                          DCMTVProfileParamSelect,
                                          select];
                         
                         return [weakSelf sendTVIRRequestWithServiceId:serviceId
                                                                method:@"PUT"
                                                                   uri:uri
                                                              response:response];
                         
                     }];
    }
    return self;
    
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
    DPIRKitRESTfulRequest *sendReq = nil;
    for (DPIRKitRESTfulRequest *req in requests) {
        if ([req.uri isEqualToString:uri] && [req.method isEqualToString:method] && req.ir) {
            sendReq = req;
            break;
        }
    }
    if (sendReq) {
        send = [self.plugin sendIRWithServiceId:serviceId message:sendReq.ir response:response];
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:@"IR is not registered for that request"];
    }

    return send;
}

@end
