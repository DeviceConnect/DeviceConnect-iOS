//
//  DConnectTestCase.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DConnectNormalTestCase.h"
#import "TestDevicePlugin.h"

NSString *const DConnectHost = @"localhost";
int DConnectPort = 8080;

@implementation DConnectNormalTestCase

- (void)setUp
{
    [super setUp];
    // dConnectManagerのインスタンスを作成
    [DConnectManager sharedManager];
    
    // serviceIdを検索しておく
    if (!self.serviceId) {
        [self searchTestDevicePlugin];
    }
}

- (void)tearDown
{
    [super tearDown];
}

- (void) searchTestDevicePlugin {
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/servicediscovery"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[session dataTaskWithRequest:request  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                // 通信チェック
        XCTAssertNotNil(data, @"Failed to connect dConnectManager. \"%s\"", __PRETTY_FUNCTION__);
        XCTAssertNil(error, @"Failed to connect dConnectManager. \"%s\"", __PRETTY_FUNCTION__);
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
        
        // resultのチェック
        NSNumber *result = [dic objectForKey:DConnectMessageResult];
        XCTAssert([result intValue] == DConnectMessageResultTypeOk);
        
        // デバイスのチェック
        NSArray *services = [dic objectForKey:DConnectServiceDiscoveryProfileParamServices];
        for (int i = 0; i < [services count]; i++) {
            NSDictionary *s = (NSDictionary *)[services objectAtIndex:i];
            NSString *name = [s objectForKey:DConnectServiceDiscoveryProfileParamName];
            NSString *serviceId = [s objectForKey:DConnectServiceDiscoveryProfileParamId];
            if ([TestDevicePluginName isEqualToString:name]) {
                self.serviceId = serviceId;
            }
        }
        XCTAssertNotNil(self.serviceId, @"Can't found serviceId.");
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));

}

@end
