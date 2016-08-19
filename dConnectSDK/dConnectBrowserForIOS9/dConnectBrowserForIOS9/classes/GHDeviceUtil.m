//
//  GHDeviceUtil.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
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
    [manager startByHttpServer];
    q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self updateDiveceList];
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
- (void)updateDiveceList
{
    __weak GHDeviceUtil *_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self discoverDevices:^(DConnectArray *result) {
                _self.currentDevices = result;
                _self.recieveDeviceList(result);
            }];
        });
    });
}

- (void)discoverDevices:(DiscoverDeviceCompletion)completion
{
    @synchronized(self) {
        dispatch_semaphore_wait(_semaphore,
                                dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * DPSemaphoreTimeout));
        
        BOOL isLocalOAuth = manager.settings.useLocalOAuth;
        if (isLocalOAuth) {
            manager.settings.useLocalOAuth = NO;
        }
        DConnectRequestMessage *request = [DConnectRequestMessage new];
        [request setAction: DConnectMessageActionTypeGet];
        [request setApi: DConnectMessageDefaultAPI];
        [request setProfile: DConnectServiceDiscoveryProfileName];
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
                    if (completion) {
                        completion(nil);
                    }
                }
            } else {
                if (completion) {
                    completion(nil);
                }
            }
            if (isLocalOAuth) {
                manager.settings.useLocalOAuth = YES;
            }
            dispatch_semaphore_signal(_semaphore);
        }];
    }
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
