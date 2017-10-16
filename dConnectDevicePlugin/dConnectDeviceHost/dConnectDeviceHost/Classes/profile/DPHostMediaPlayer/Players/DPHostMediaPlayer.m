//
//  DPHostMediaPlayer.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHostMediaPlayer.h"


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


@end
