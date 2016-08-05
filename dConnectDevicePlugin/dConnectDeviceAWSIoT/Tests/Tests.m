//
//  Tests.m
//  Tests
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <XCTest/XCTest.h>
#import "DPAWSIoTManager.h"

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
	XCTestExpectation *okExpectation = [self expectationWithDescription:@"ok!"];
	// 接続
	[[DPAWSIoTManager sharedManager] connectWithAccessKey:@"AKIAJYDTLD4DPFGZ4PAQ" secretKey:@"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" region:AWSRegionAPNortheast1 completionHandler:^(NSError *error) {
		// Shadow取得
		[[DPAWSIoTManager sharedManager] fetchShadowWithName:@"dc01" completionHandler:^(NSString *result, NSError *error) {
			XCTAssertNil(error, @"error");
			[okExpectation fulfill];
		}];
//		// Shadow更新
//		[[DPAWSIoTManager sharedManager] updateShadowWithName:@"dc01" value:@"{\"state\": {\"reported\": {\"aaa\": \"bbb\"}}}" completionHandler:^(NSError *error) {
//			XCTAssertNil(error, @"error");
//			[okExpectation fulfill];
//		}];
//		// MQTT/Sub
//		[[DPAWSIoTManager sharedManager] subscribeWithTopic:@"tp" messageHandler:^(NSString *message) {
//			NSLog(@"%@", message);
//			[okExpectation fulfill];
//		}];
//		// MQTT/Pub
//		[[DPAWSIoTManager sharedManager] publishWithTopic:@"tp" message:@"test"];
//		[okExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
