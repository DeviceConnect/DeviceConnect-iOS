//
//  DPAllJoynServiceInformationProfile.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynServiceInformationProfile.h"

#import "DPAllJoynServiceEntity.h"
#import "DPAllJoynSupportCheck.h"


@interface DPAllJoynServiceInformationProfile ()
<DConnectServiceInformationProfileDelegate> {
@private
    id<DConnectProfileProvider> _provider;
    DPAllJoynHandler *_handler;
    NSString *_version;
}
@end


@implementation DPAllJoynServiceInformationProfile

- (instancetype)initWithProvider:(id<DConnectProfileProvider>)provider
                         handler:(DPAllJoynHandler *)handler
                         version:(NSString *)version
{
    if (!provider) {
        return nil;
    }
    if (!handler) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.delegate = self;
        _provider = provider;
        _handler = handler;
        _version = version;
    }
    return self;
}


// =============================================================================
#pragma mark DConnectServiceInformationProfileDelegate


- (BOOL)                profile:(DConnectServiceInformationProfile *)profile
didReceiveGetInformationRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return true;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    if (!service) {
        [response setErrorToNotFoundService];
        return true;
    }
    
    DConnectMessage *connect = [DConnectMessage message];
    DConnectServiceInformationProfileConnectState const stateNone =
    DConnectServiceInformationProfileConnectStateNone;
    [DPAllJoynServiceInformationProfile setWiFiState:stateNone target:connect];
    [DPAllJoynServiceInformationProfile setNFCState:stateNone target:connect];
    [DPAllJoynServiceInformationProfile setBLEState:stateNone target:connect];
    [DPAllJoynServiceInformationProfile setConnect:connect target:response];
    [response setVersion:_version];
    
    DConnectArray *profiles =
    [DConnectArray initWithArray:
     [DPAllJoynSupportCheck supportedProfileNamesWithProvider:_provider
                                                      service:service]];
    
    [DPAllJoynServiceInformationProfile setSupports:profiles target:response];
    
    [response setResult:DConnectMessageResultTypeOk];
    return true;
}

@end
