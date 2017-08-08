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
#import "DPAWSIoTNetworkManager.h"

#define kShadowName @"dc01"

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
	[[DPAWSIoTManager sharedManager] connectWithAccessKey:@"Your Access Key" secretKey:@"Your Secret Key" region:AWSRegionAPNortheast1 completionHandler:^(NSError *error) {
		int test = 5;
		
		switch (test) {
			case 1:
				[self fetchShadow:okExpectation];
				break;
			case 2:
				[self updateShadow:okExpectation];
				break;
			case 3:
				[self subscribeMQTT:okExpectation];
				break;
			case 4:
				[self publishMQTT:okExpectation];
				break;
			case 5:
				[self http:okExpectation];
				break;
				
			default:
				break;
		}
	}];
	[self waitForExpectationsWithTimeout:5 handler:nil];
}

// Shadow取得
- (void)fetchShadow:(XCTestExpectation*)expectation {
	[[DPAWSIoTManager sharedManager] fetchShadowWithName:kShadowName completionHandler:^(id json, NSError *error) {
		XCTAssertNil(error, @"error");
		[expectation fulfill];
	}];
}

// Shadow更新
- (void)updateShadow:(XCTestExpectation*)expectation {
	[[DPAWSIoTManager sharedManager] updateShadowWithName:kShadowName value:@"{\"state\": {\"reported\": {\"test\": \"ok!\"}}}" completionHandler:^(NSError *error) {
		XCTAssertNil(error, @"error");
		[expectation fulfill];
	}];
}

// MQTT/Sub
- (void)subscribeMQTT:(XCTestExpectation*)expectation {
	[[DPAWSIoTManager sharedManager] subscribeWithTopic:@"tp" messageHandler:^(id json, NSError *error) {
		XCTAssertNil(error, @"error");
		[expectation fulfill];
	}];
}

// MQTT/Pub
- (void)publishMQTT:(XCTestExpectation*)expectation {
	[[DPAWSIoTManager sharedManager] publishWithTopic:@"tp" message:@"test"];
	[expectation fulfill];
}

// HTTP
- (void)http:(XCTestExpectation*)expectation {
	[DPAWSIoTNetworkManager sendRequestWithPath:@"http://gclue.com" method:@"get" params:@{@"test": @"param"} handler:^(NSData *data, NSURLResponse *response, NSError *error) {
		XCTAssertNil(error, @"error");
		[expectation fulfill];
	}];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
