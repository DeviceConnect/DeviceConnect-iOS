//
//  RESTfulTestCase.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulTestCase ()
{
    @private
    NSDictionary *event;
    SRWebSocket *socket;
    dispatch_semaphore_t _semaphore;
}
@end

@implementation RESTfulTestCase

- (void)setUp
{
    [super setUp];
    
    // serviceIdを検索しておく
    if (!self.serviceId) {
        [self searchTestDevicePlugin];
    }
}

- (void)tearDown
{
    @synchronized(self) {
        if (socket) {
            [socket close];
            socket = nil;
        }
    }
    [super tearDown];
}

- (NSArray*) createClient
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/authorization/grant"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request addValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    XCTAssertNotNil(data);
    XCTAssertNil(error);
    NSDictionary *actualResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
    NSNumber *result = [actualResponse objectForKey:@"result"];
    XCTAssertNotNil(result);
    XCTAssertEqual(0, [result intValue]);
    NSLog(@"********** actualResponse: %@", actualResponse);
    NSMutableArray *client = [NSMutableArray array];
    [client addObject:[actualResponse objectForKey:@"clientId"]];
    return client;
}

- (AccessToken*) requestAccessTokenWithClientId:(NSString*)clientId
                                   clientSecret:(NSString*)clientSecret
                                         scopes:(NSArray*)scopes
                                applicationName:(NSString*)applicationName
{
    NSMutableString *scopeParam = nil;
    if (scopes) {
        scopeParam = [NSMutableString string];
        for (int i = 0; i < scopes.count; i++) {
            if (i > 0) {
                [scopeParam appendString:@","];
            }
            [scopeParam appendString:scopes[i]];
        }
    }

    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/authorization/accesstoken?clientId=%@&scope=%@&applicationName=%@", clientId, scopeParam, applicationName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    XCTAssertNotNil(data);
    XCTAssertNil(error);
    NSDictionary *actualResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
    NSNumber *result = [actualResponse objectForKey:@"result"];
    XCTAssertNotNil(result);
    XCTAssertEqual(0, [result intValue]);
    return [[AccessToken alloc] initWithResponse:actualResponse];
}

- (void) searchTestDevicePlugin {
    NSURL *url = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    // 通信チェック
    XCTAssertNotNil(data, @"Failed to connect dConnectManager. \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertNil(error, @"Failed to connect dConnectManager. \"%s\"", __PRETTY_FUNCTION__);
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    
    // resultのチェック
    NSNumber *result = [dic objectForKey:DConnectMessageResult];
    XCTAssert([result intValue] == DConnectMessageResultTypeOk);
    if ([result intValue] == DConnectMessageResultTypeError) {
        NSLog(@"errorMessage: %@", [dic objectForKey:DConnectMessageErrorMessage]);
    }
    
    // デバイスのチェック
    NSArray *services = [dic objectForKey:DConnectServiceDiscoveryProfileParamServices];
    for (int i = 0; i < [services count]; i++) {
        NSDictionary *s = (NSDictionary *)[services objectAtIndex:i];
        NSString *name = [s objectForKey:DConnectServiceDiscoveryProfileParamName];
        NSString *serviceId = [s objectForKey:DConnectServiceDiscoveryProfileParamId];
        if ([@"Test Success Device" isEqualToString:name]) {
            self.serviceId = serviceId;
        }
    }
    XCTAssertNotNil(self.serviceId, @"Can't found serviceId.");
}

- (NSDictionary *) waitForEvent {
    @synchronized(self) {
        event = nil;
        _semaphore = dispatch_semaphore_create(0);
        if (!socket) {
            socket = [[SRWebSocket new] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://localhost:4035/websocket"]]];
            [socket setDelegateOperationQueue:[NSOperationQueue new]];
            [socket setDelegate:self];
            [socket open];
        }
        // イベントの受信を待機する
        dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
    }
    return event;
}

- (BOOL) assertDictionary: (NSDictionary *)expected actual:(NSDictionary *) actual {
    for (id key in [expected keyEnumerator]) {
        id expectedObj = [expected objectForKey:key];
        id actualObj = [actual objectForKey:key];
        if (![self assertObject:expectedObj actual:actualObj]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) assertObject:(id) expectedObj actual:(id) actualObj {
    if ([expectedObj isKindOfClass:[NSDictionary class]] && [actualObj isKindOfClass:[NSDictionary class]]) {
        if (![self assertDictionary:expectedObj actual:actualObj]) {
            NSLog(@"***** Difference NSDictionary: expected=%@, actual=%@", expectedObj, actualObj);
            return NO;
        }
        return YES;
    } else if ([expectedObj isKindOfClass:[NSArray class]] && [actualObj isKindOfClass:[NSArray class]]) {
        NSArray *expectedArray = (NSArray *) expectedObj;
        NSArray *actualArray = (NSArray *) actualObj;
        if ([expectedArray count] != [actualArray count]) {
            NSLog(@"***** Difference length of NSArray: expected=%@, actual=%@", expectedObj, actualObj);
            return NO;
        }
        for (int i = 0; i < [expectedArray count]; i++) {
            if (![self assertObject:expectedArray[i] actual:actualArray[i]]) {
                NSLog(@"***** Difference NSArray: expected=%@, actual=%@", expectedObj, actualObj);
                return NO;
            }
        }
        return YES;
    } else if ([expectedObj isKindOfClass:[NSString class]] && [actualObj isKindOfClass:[NSString class]]) {
        if (![expectedObj isEqualToString:actualObj]) {
            NSLog(@"***** Difference NSString: expected=%@, actual=%@", expectedObj, actualObj);
            return NO;
        }
        return YES;
    } else if ([expectedObj isKindOfClass:[NSNumber class]] && [actualObj isKindOfClass:[NSNumber class]]) {
        if (![expectedObj isEqualToNumber:actualObj]) {
            NSLog(@"***** Difference NSNumber: expected=%@, actual=%@", expectedObj, actualObj);
            return NO;
        }
        return YES;
    } else {
        NSLog(@"***** Invalid class: expected=%@, actual=%@", expectedObj, actualObj);
        return NO;
    }
}

#pragma mark - SRWebSocketDelegate

- (void) webSocketDidOpen:(SRWebSocket *)webSocket {
    [webSocket send:[NSString stringWithFormat:@"{\"sessionKey\":\"%@\"}", self.clientId]];
}

- (void) webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
}

- (void) webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}

- (void) webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if(!message) {
        return;
    }
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if(!data) {
        return;
    }
    event = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    dispatch_semaphore_signal(_semaphore);
}

@end
