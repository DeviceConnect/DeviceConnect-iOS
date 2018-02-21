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
#import "DConnectManager.h"

@implementation DConnectHttpConnection {
    NSArray *_sslIdentityAndCertificates;
}

#pragma mark - Override Method

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig {
    if (self = [super initWithAsyncSocket:newSocket configuration:aConfig]) {
        NSMutableArray *certificates = [NSMutableArray array];
        
        // 証明書 (PKCS#12形式) へのパス
        NSURL *p12URL = [DCBundle() URLForResource:@"certificate" withExtension:@"p12"];
        NSLog(@"Certificate URL: %@", p12URL);

        SecIdentityRef identity = [self importPKCS12:p12URL];
        NSLog(@"Identity: %@", identity);
        [certificates addObject:(__bridge id)identity];
        
        _sslIdentityAndCertificates = certificates;
    }
    return self;
}

- (SecIdentityRef) importPKCS12:(NSURL *)p12URL
{
    // 証明書のRawデータをリソースバンドルから読み込む
    NSData *data = [NSData dataWithContentsOfURL:p12URL];
    
    // 証明書をiOSのSecurity Frameworkにインポート
    NSString* password = @"password";
    NSDictionary* options = @{
                              (id)kSecImportExportPassphrase : password
                              };
    CFArrayRef rawItems = NULL;
    OSStatus status = SecPKCS12Import((__bridge CFDataRef)data,
                                      (__bridge CFDictionaryRef)options,
                                      &rawItems);
    NSArray* items = (NSArray*) CFBridgingRelease(rawItems); // Transfer to ARC
    
    // インポート処理の結果から SecIdentityRef を取得
    NSDictionary* firstItem = nil;
    if ((status == errSecSuccess) && ([items count] > 0)) {
        firstItem = items[0];
        SecIdentityRef identity =
        (SecIdentityRef) CFBridgingRetain(firstItem[(id)kSecImportItemIdentity]);
        return identity;
    }
    return nil;
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
    return [DConnectManager sharedManager].settings.useSSL;
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
