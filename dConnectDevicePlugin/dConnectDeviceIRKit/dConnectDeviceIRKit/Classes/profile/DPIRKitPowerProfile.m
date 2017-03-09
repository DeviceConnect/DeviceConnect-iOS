#import "DPIRKitPowerProfile.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitManager.h"
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitRESTfulRequest.h"

@implementation DPIRKitPowerProfile

- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin
{
    self = [super init];
    if (self) {
        self.plugin = plugin;
        __weak DPIRKitPowerProfile *weakSelf = self;
        
        // 内部ではTVの処理を使用する
        // PUT /gotapi/power/
        [self addPutPath:@"/" api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            NSString *serviceId = [request serviceId];
            return [weakSelf.plugin sendTVIRRequestWithServiceId:serviceId
                                                   method:@"PUT"
                                                      uri:@"/tv"
                                                 response:response];
        }];

        // GET /gotapi/power/ Unsupported

        // DELETE /gotapi/power/
        [self addDeletePath:@"/" api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            NSString *serviceId = [request serviceId];
            return [weakSelf.plugin sendTVIRRequestWithServiceId:serviceId
                                                   method:@"DELETE"
                                                      uri:@"/tv"
                                                 response:response];
        }];
    }
    return self;
}

#pragma mark - DConnectProfile Delegate

- (NSString *) profileName {
    return @"power";
}

@end
