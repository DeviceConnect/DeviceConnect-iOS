//
//  DConnectHttpConnection.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectHttpConnection.h"
#import "DConnectWebSocket.h"

@implementation DConnectHttpConnection {
    NSArray *_sslIdentityAndCertificates;
}

#pragma mark - Override Method

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig {
    if (self = [super initWithAsyncSocket:newSocket configuration:aConfig]) {
        NSMutableArray *certificates = [NSMutableArray array];
        
        NSURL *path = [DCBundle() URLForResource:@"certificate" withExtension:@"p12"];
        NSLog(@"Certificate Path: %@", path);
        NSData *data = [NSData dataWithContentsOfURL:path];
        NSLog(@"Certificate Data Size: %lu", data.length);
        
        NSString* password = @"password";
        NSDictionary* options = @{
                                  (id)kSecImportExportPassphrase : password
                                  };
        
        CFArrayRef rawItems = NULL;
        OSStatus status = SecPKCS12Import((__bridge CFDataRef)data,
                                          (__bridge CFDictionaryRef)options,
                                          &rawItems);
        NSLog(@"Status: %d", status);
        NSArray* items = (NSArray*)CFBridgingRelease(rawItems); // Transfer to ARC
        NSLog(@"Item count: %lu", [items count]);
        
        NSDictionary* firstItem = nil;
        if ((status == errSecSuccess) && ([items count] > 0)) {
            firstItem = items[0];
            SecIdentityRef identity =
            (SecIdentityRef)CFBridgingRetain(firstItem[(id)kSecImportItemIdentity]);
            NSLog(@"SecIdentityRef: %@", identity);
            [certificates addObject:(__bridge id)identity];
        }
        
        _sslIdentityAndCertificates = certificates;
    }
    return self;
}

- (WebSocket *)webSocketForURI:(NSString *)path
{
    DConnectWebSocket *websocket = [[DConnectWebSocket alloc] initWithRequest:request socket:asyncSocket];
    websocket.delegate = config.server;
    websocket.connectTime = [NSDate date].timeIntervalSince1970;
    return websocket;
}

- (BOOL)isSecureServer
{
    // TODO: 設定画面でYES/NOを切り替えられるようにする
    return YES;
}

/**
 * This method is expected to returns an array appropriate for use in kCFStreamSSLCertificates SSL Settings.
 * It should be an array of SecCertificateRefs except for the first element in the array, which is a SecIdentityRef.
 **/
- (NSArray *)sslIdentityAndCertificates
{
    NSLog(@"_sslIdentityAndCertificates: %d", _sslIdentityAndCertificates.count);
    return _sslIdentityAndCertificates;
}

@end
