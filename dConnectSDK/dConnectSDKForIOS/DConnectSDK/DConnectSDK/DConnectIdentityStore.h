//
//  DConnectIdentityStore.h
//  DConnectSDK
//
//  Copyright (c) 2018 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DConnectIdentityStore : NSObject

+ (DConnectIdentityStore *) shared;

- (NSArray *) identity;

- (SecTrustRef) setupTrust:(SecTrustRef) trust;

@end
