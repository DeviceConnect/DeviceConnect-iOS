//
//  GHDeviceUtil.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHDeviceUtil.h"
static const NSTimeInterval DPSemaphoreTimeout = 20.0;

@interface GHDeviceUtil()
{
    DConnectManager *manager;
    dispatch_queue_t q_global;
    dispatch_semaphore_t _semaphore;
}
@end

@implementation GHDeviceUtil


static GHDeviceUtil* mgr = nil;

+(GHDeviceUtil*)shareManager
{
    if (!mgr) {
        mgr = [[GHDeviceUtil alloc]init];
    }

    return mgr;
}

- (instancetype)init
{
    self = [super init];
    if(self){
        _semaphore = dispatch_semaphore_create(1);
        [self setup];
    }
    return self;
}

- (void)setup
{
    manager = [DConnectManager sharedManager];
    [manager start];
    q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    [self updateDeviceList];
}

- (void)debug:(DConnectArray*)array
{
    for (int s = 0; s < [array count]; s++) {
        DConnectMessage *service = [array messageAtIndex: s];
        LOG(@" - response - service[%d] -----", s);

        LOG(@" --- id:%@", [service stringForKey: DConnectServiceDiscoveryProfileParamId]);
        LOG(@" --- name:%@", [service stringForKey: DConnectServiceDiscoveryProfileParamName]);
        LOG(@" --- type:%@", [service stringForKey: DConnectServiceDiscoveryProfileParamType]);
        LOG(@" --- online:%@", [service stringForKey: DConnectServiceDiscoveryProfileParamOnline]);
        LOG(@" --- config:%@", [service stringForKey: DConnectServiceDiscoveryProfileParamConfig]);
    }
}

//--------------------------------------------------------------//
#pragma mark - デバイス一覧取得
//--------------------------------------------------------------//
- (void)updateDeviceList
{
    __weak GHDeviceUtil *_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callRequestAccessTokenAPI];

            [self discoverDevices:^(DConnectArray *result) {
                _self.currentDevices = result;
                _self.recieveDeviceList(result);
            }];
        });
    });
}

- (void)discoverDevices:(DiscoverDeviceCompletion)completion
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [def stringForKey:ACCESS_TOKEN];
    if (!accessToken) {
        completion(nil);
        return;
    }
    DConnectRequestMessage *request = [DConnectRequestMessage new];
    [request setAction: DConnectMessageActionTypeGet];
    [request setApi: DConnectMessageDefaultAPI];
    [request setProfile: DConnectServiceDiscoveryProfileName];
    [request setAccessToken:accessToken];
    [request setString:[self packageName] forKey:DConnectMessageOrigin];
    [manager sendRequest: request callback:^(DConnectResponseMessage *response) {
        if (response != nil) {
            if ([response result] == DConnectMessageResultTypeOk) {
                DConnectArray *services = [response arrayForKey: DConnectServiceDiscoveryProfileParamServices];
                if (completion) {
                    completion(services);
                }
            } else {
                LOG(@" - response - errorCode: %d", [response errorCode]);
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                [def removeObjectForKey:ACCESS_TOKEN];
                [def synchronize];

                if (completion) {
                    completion(nil);
                }
            }
        } else {
            NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            [def removeObjectForKey:ACCESS_TOKEN];
            [def synchronize];
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)callRequestAccessTokenAPI {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [def stringForKey:ACCESS_TOKEN];
    if (accessToken) {
        return;
    }    
    NSArray *scopes = [@[DConnectServiceDiscoveryProfileName]
                       sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];;
    
    
    /* セマフォ準備 */
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * DPSemaphoreTimeout);
    
    /* 応答が返るまでWait */
    dispatch_semaphore_wait(semaphore, timeout);

    [DConnectUtil asyncAuthorizeWithOrigin: [self packageName]
                                   appName: @"Browser"
                                    scopes: scopes
                                   success: ^(NSString *clientId, NSString *accessToken) {
                                       NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                                       [def setObject:accessToken forKey:ACCESS_TOKEN];
                                       [def synchronize];
                                       NSLog(@" - response - accessToken: %@", accessToken);
                                       /* Wait解除 */
                                       dispatch_semaphore_signal(semaphore);
                                       
                                   }
                                     error:^(DConnectMessageErrorCodeType errorCode){
                                         NSLog(@" - response - errorCode: %d", errorCode);
                                         /* Wait解除 */
                                         dispatch_semaphore_signal(semaphore);
                                         
                                     }];
}


- (NSString *)packageName {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *package = [bundle bundleIdentifier];
    return package;
}

- (void)dealloc
{
    _recieveDeviceList = nil;
}

@end
