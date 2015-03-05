//
//  DConnectManagerAuthorizationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectManagerAuthorizationProfile.h"
#import "LocalOAuth2Main.h"

@implementation DConnectManagerAuthorizationProfile

- (BOOL) didReceiveGetCreateClientRequest:(DConnectRequestMessage *)request
                                 response:(DConnectResponseMessage *)response
                                serviceId:(NSString *)serviceId
{
    NSString *origin = nil;
    if ([request hasKey:DConnectMessageOrigin]) {
        origin = [request objectForKey:DConnectMessageOrigin];
    }
    if (origin == nil || origin.length <= 0) {
        [response setErrorToInvalidRequestParameter];
    } else {
        LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass:[self.object class]];
        LocalOAuthPackageInfo *packageInfo
        = [[LocalOAuthPackageInfo alloc] initWithPackageNameServiceId:origin
                                                            serviceId:serviceId];
        LocalOAuthClientData *clientData = [oauth createClientWithPackageInfo:packageInfo];
        if (clientData) {
            [response setResult:DConnectMessageResultTypeOk];
            [DConnectAuthorizationProfile setClientId:clientData.clientId target:response];
            [DConnectAuthorizationProfile setClientSceret:clientData.clientSecret target:response];
        } else {
            [response setErrorToUnknown];
        }
    }
    return YES;
}

@end