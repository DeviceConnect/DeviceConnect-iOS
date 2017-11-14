//
//  DConnectSDKSuccessTestCase.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <XCTest/XCTest.h>
#import "DConnectManager.h"
#import "Multipart.h"

/**
 * @deprecated DConnectManagerディレクトリ以下の単体テストに漸次統合する事
 */
@interface WebAPISuccessTestCase : XCTestCase

@end

@implementation WebAPISuccessTestCase

- (void)setUp
{
    [super setUp];
    [DConnectManager sharedManager];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testWebAPIMultipart
{
    // Multipartを用意
    Multipart* multi = [Multipart new];
    [multi addString:@"hahaha_i_" forKey:@"test1_string_key"];
    [multi addString:@"am_an_utterly_" forKey:@"test2_string_key"];
    const char data[] = "string!!!!\0";
    size_t len = strlen(data);
    [multi addData:[NSMutableData dataWithBytes:data length:len]
            forKey:@"test3_data_key"];
    //    NSLog(@"body: %@", [[NSString alloc] initWithData:multi.body
    //                                             encoding:NSUTF8StringEncoding]);
    
    // dConnectManagerへHTTPリクエストを投げる。
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/system"]];
    [request setValue:multi.contentType forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:multi.body];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[session dataTaskWithRequest:request  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {

        NSLog(@"response: %@\n\nerror: %@", [response description], [error description]);
        
        XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));

}

@end
