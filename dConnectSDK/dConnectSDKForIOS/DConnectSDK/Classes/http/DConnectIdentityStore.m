//
//  DConnectIdentityStore.m
//  DConnectSDK
//
//  Copyright (c) 2018 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectIdentityStore.h"


@implementation DConnectIdentityStore {
    SecIdentityRef _identity;
}

+ (DConnectIdentityStore *) shared {
    static DConnectIdentityStore *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DConnectIdentityStore new];
    });
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        // 証明書 (PKCS#12形式) へのパス
        NSURL *p12URL = [DCBundle() URLForResource:@"dconnect-ios" withExtension:@"p12"];
        NSLog(@"Certificate URL: %@", p12URL);
        
        _identity = [self importPKCS12:p12URL];
        NSLog(@"Identity: %@", _identity);
    }
    return self;
}

- (NSArray *) identity
{
    NSMutableArray *certificates = [NSMutableArray array];
    [certificates addObject:(__bridge id)_identity];
    return certificates;
}

- (void) findIdentity
{
    NSDictionary *query = @{
                            (__bridge id)kSecClass: (__bridge id) kSecClassIdentity
                            };
    CFTypeRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &resultRef);
    NSLog(@"findIdentity: status = %d", status);
    if (status == errSecSuccess) {
        NSDictionary *result = (__bridge_transfer NSDictionary *)resultRef;
        NSLog(@"findIdentity: count = %d", [result count]);
    }
}

- (SecIdentityRef) importPKCS12:(NSURL *)p12URL
{
    // 証明書のRawデータをリソースバンドルから読み込む
    NSData *data = [NSData dataWithContentsOfURL:p12URL];
    
    // 証明書をiOSのSecurity Frameworkにインポート
    NSString* password = @"0000";
    NSDictionary* options = @{
                              (id)kSecImportExportPassphrase : password
                              };
    CFArrayRef rawItems = NULL;
    OSStatus status = SecPKCS12Import((__bridge CFDataRef)data,
                                      (__bridge CFDictionaryRef)options,
                                      &rawItems);
    NSLog(@"SecPKCS12Import: status = %d", status);
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

- (SecTrustRef) setupTrust:(SecTrustRef)trust
{
    CFMutableArrayRef newAnchorArray = CFArrayCreateMutable (kCFAllocatorDefault,
                                                             0,
                                                             &kCFTypeArrayCallBacks);
    SecCertificateRef cert = NULL;
    SecIdentityCopyCertificate(_identity, &cert);
    CFArrayAppendValue(newAnchorArray, cert);
    SecTrustSetAnchorCertificates(trust, newAnchorArray);
    SecTrustSetAnchorCertificatesOnly(trust, false);
    if (cert) {
        CFRelease(cert);
    }
    return trust;
}

@end
