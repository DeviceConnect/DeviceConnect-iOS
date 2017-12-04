//
//  DConnectFileProfileTest.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectNormalTestCase.h"
#import <DConnectSDK/DConnectSDK.h>

@interface DConnectFileProfileTest : DConnectNormalTestCase

@end

@implementation DConnectFileProfileTest

- (void) testList {
    DConnectURIBuilder *builder = [DConnectURIBuilder new];
    [builder setHost:DConnectHost];
    [builder setPort:DConnectPort];
    [builder setProfile:DConnectFileProfileName];
    [builder setAttribute:DConnectFileProfileAttrList];
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
        NSArray *files = [dic objectForKey:DConnectFileProfileParamFile];
        XCTAssertNotNil(files, @"Failed to get file list. \"%s\"", __PRETTY_FUNCTION__);
        XCTAssert([files count] > 0, @"Failed to get file list. \"%s\"", __PRETTY_FUNCTION__);
        for (int i = 0; i < [files count]; i++) {
            NSDictionary *file = [files objectAtIndex:i];
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));

}

- (void) testReceive {
    DConnectURIBuilder *builder = [DConnectURIBuilder new];
    [builder setHost:DConnectHost];
    [builder setPort:DConnectPort];
    [builder setProfile:DConnectFileProfileName];
    [builder setAttribute:DConnectFileProfileAttrReceive];
    [builder addParameter:self.serviceId forKey:DConnectMessageServiceId];
    [builder addParameter:@"fileid1" forKey:DConnectFileProfileParamMediaId];
    
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
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));

}

@end
