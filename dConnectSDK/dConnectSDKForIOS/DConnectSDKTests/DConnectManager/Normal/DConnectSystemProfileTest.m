//
//  DConnectSystemProfileTest.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectNormalTestCase.h"
#import <DConnectSDK/DConnectSDK.h>

@interface DConnectSystemProfileTest : DConnectNormalTestCase

@end

@implementation DConnectSystemProfileTest

- (void) testSystemProfile {
    DConnectURIBuilder *builder = [DConnectURIBuilder new];
    [builder setHost:DConnectHost];
    [builder setPort:DConnectPort];
    [builder setProfile:DConnectSystemProfileName];
    [builder setAttribute:DConnectSystemProfileAttrDevice];
    [builder addParameter:self.serviceId forKey:DConnectMessageServiceId];
    
    NSString *uri = [builder build];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]];
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
        
        // パラメータのチェック
        NSString *version = [dic objectForKey:DConnectSystemProfileParamVersion];
        NSArray *support = [dic objectForKey:DConnectSystemProfileParamSupports];
        
        XCTAssertNotNil(version, @"version is nil. \"%s\"", __PRETTY_FUNCTION__);
        XCTAssertNotNil(support, @"support is nil. \"%s\"", __PRETTY_FUNCTION__);
        XCTAssert([version isEqualToString:TestDevicePluginSystemVersion], @"Failed to get version. \"%s\"", __PRETTY_FUNCTION__);
        XCTAssert([support count] > 0, @"supports is empty. \"%s\"", __PRETTY_FUNCTION__);
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));

}

@end
