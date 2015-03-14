//
//  LocalOAuthClientData.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LocalOAuthClientData.h"

@implementation LocalOAuthClientData

/*!
    デフォルトのinitは使用しない
*/
+ (id)init {
    @throw @"Can't use ClientData default constructor.";
}

+ (LocalOAuthClientData *) clientDataWithClientId:(NSString *)clientId
{
    
    LocalOAuthClientData *clientData = [[LocalOAuthClientData alloc]init];
    
    if (clientData) {
        clientData.clientId = clientId;
    }
    
    return clientData;
}

@end
