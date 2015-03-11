//
//  LocalOAuthAccessTokenData.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LocalOAuthAccessTokenData.h"

@implementation LocalOAuthAccessTokenData

+ (LocalOAuthAccessTokenData *)accessTokenDataWithAccessToken: (NSString *)accessToken
                                                       scopes:(NSArray *)scopes
                                                    timestamp:(long long)timestamp
{

    LocalOAuthAccessTokenData *accessTokenData = [[LocalOAuthAccessTokenData alloc]init];
    
    if (accessTokenData) {
        accessTokenData._accessToken = accessToken;
        accessTokenData._scopes = scopes;
        accessTokenData._timestamp = timestamp;
    }
    
    return accessTokenData;
}


@end
