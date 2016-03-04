//
//  DPAllJoynServiceDiscoveryProfile.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynServiceDiscoveryProfile.h"

#import "DPAllJoynServiceEntity.h"


@interface DPAllJoynServiceDiscoveryProfile ()
<DConnectServiceDiscoveryProfileDelegate> {
@private
    DPAllJoynHandler *_handler;
}
@end


@implementation DPAllJoynServiceDiscoveryProfile

- (instancetype)initWithHandler:(DPAllJoynHandler *)handler
{
    if (!handler) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.delegate = self;
        _handler = handler;
    }
    return self;
}


// =============================================================================
#pragma mark - DConnectServiceDiscoveryProfileDelegate


- (BOOL)             profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                    response:(DConnectResponseMessage *)response
{
    DConnectArray *services = [DConnectArray array];

    for (DPAllJoynServiceEntity *serviceEntity in
         _handler.discoveredAllJoynServices.allValues) {
        
        // Luminaireのグループを管理しているデバイスは除外する
        if (([serviceEntity.serviceName rangeOfString:@"LuminaireC"
                                options:NSCaseInsensitiveSearch].location != NSNotFound)) {
            continue;
        }
        DConnectMessage *service = [DConnectMessage message];
        [DConnectServiceDiscoveryProfile setId:serviceEntity.appId
                                        target:service];
        [DConnectServiceDiscoveryProfile setName:serviceEntity.serviceName
                                          target:service];
        [DConnectServiceDiscoveryProfile setType:@"wifi" target:service];
        [DConnectServiceDiscoveryProfile setOnline:YES target:service];
        [services addMessage:service];
    }
    
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

@end
