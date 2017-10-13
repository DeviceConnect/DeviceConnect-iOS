//
//  DPHostMediaPlayer.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHostMediaPlayer.h"

// Error Domain
static NSString *const kDPHostMediaPlayerErrorDomain = @"org.deviceconnect.ios.deviceplugin.host.mediaplayer.error";

@implementation DPHostMediaPlayer

- (instancetype)initWithMediaContext:(DPHostMediaContext *)ctx
                              plugin:(DPHostDevicePlugin *)plugin
                               error:(NSError **)error
{
    self = [super init];
    if (self) {
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        self.plugin = plugin;
    }
    return self;
}

- (NSString*)playStatus
{
    // override subclass
    return nil;
}

- (DPHostPlayerBlock)playWithError:(NSError **)error
{
    // override subclass
    return nil;
}

- (DPHostPlayerBlock)stopWithError:(NSError **)error
{
    // override subclass
    return nil;
}

- (DPHostPlayerBlock)pauseWithError:(NSError **)error
{
    // override subclass
    return nil;
}

- (DPHostPlayerBlock)resumeWithError:(NSError **)error
{
    // override subclass
    return nil;
}

- (NSTimeInterval)seekStatusWithError:(NSError **)error
{
    // override subclass
    return 0.0f;
}

- (DPHostPlayerBlock)seekPosition:(NSNumber *)position error:(NSError **)error
{
    //override subclass
    return nil;
}

#pragma mark - Utils method
+ (NSError*)throwsErrorCode:(NSInteger)code message:(NSString *)message
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    errorDetail[NSLocalizedDescriptionKey] = message;
    return [NSError errorWithDomain:kDPHostMediaPlayerErrorDomain code:code userInfo:errorDetail.mutableCopy].copy;
}

+ (UIViewController*)topViewController
{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewController:(UIViewController *)rootViewController
{
    if (!rootViewController.presentedViewController) {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController*) rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController*) rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}
@end
