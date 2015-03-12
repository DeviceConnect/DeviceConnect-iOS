//
//  TestUniqueEventProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestUniqueEventProfile.h"
#import "DeviceTestPlugin.h"

NSString *const UniqueEventProfileProfileName = @"event";
NSString *const UniqueEventProfileProfileAttributeUnique = @"unique";

@implementation TestUniqueEventProfile

#pragma mark - init

- (id) initWithDevicePlugin:(DeviceTestPlugin *)plugin {
    self = [super init];
    
    if (self) {
        _plugin = plugin;
    }
    
    return self;
}

#pragma mark - DConnectProfile

- (NSString *) profileName {
    return UniqueEventProfileProfileName;
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
{
    response.result = DConnectMessageResultTypeOk;
    
    NSNumber *count = [request objectForKey:@"count"];
    if (!count) {
        count = @1;
    }
    [NSThread sleepForTimeInterval:1.0];
    for (int i = 0; i < [count intValue]; i++) {
        DConnectMessage *event = [DConnectMessage message];
        [event setString:[request sessionKey] forKey:DConnectMessageSessionKey];
        [event setString:[request serviceId] forKey:DConnectMessageServiceId];
        
        NSString *attribute = [request attribute];
        if ([attribute isEqualToString:UniqueEventProfileProfileAttributeUnique]) {
            [event setString:UniqueEventProfileProfileName forKey:DConnectMessageProfile];
            [event setString:UniqueEventProfileProfileAttributeUnique forKey:DConnectMessageAttribute];
        } else {
            [event setString:DConnectServiceDiscoveryProfileName forKey:DConnectMessageProfile];
            [event setString:DConnectServiceDiscoveryProfileAttrOnServiceChange forKey:DConnectMessageAttribute];
            
            DConnectMessage *networkService = [DConnectMessage message];
            [DConnectServiceDiscoveryProfile setId:TDPServiceId target:networkService];
            [DConnectServiceDiscoveryProfile setName:@"Test Success Device" target:networkService];
            [DConnectServiceDiscoveryProfile setType:@"TEST" target:networkService];
            [DConnectServiceDiscoveryProfile setState:YES target:networkService];
            [DConnectServiceDiscoveryProfile setOnline:YES target:networkService];
            [DConnectServiceDiscoveryProfile setConfig:@"test config" target:networkService];
            [DConnectServiceDiscoveryProfile setScopesWithProvider:self.provider
                                                            target:networkService];
            [DConnectServiceDiscoveryProfile setNetworkService:networkService target:event];
        }
        
        [_plugin asyncSendEvent:event];
    }
    
    return YES;
}

@end
