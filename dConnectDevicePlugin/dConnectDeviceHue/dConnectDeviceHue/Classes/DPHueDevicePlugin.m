//
//  dConnectDeviceHue.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueDevicePlugin.h"
#import "DPHueSystemProfile.h"
#import "DPHueManager.h"
#import "DPHueConst.h"

NSString *const DPHueBundleName = @"dConnectDeviceHue_resources";


@interface DPHueDevicePlugin()

@property (nonatomic, strong) NSMutableDictionary *hueBridgeListTemp;
@end
@implementation DPHueDevicePlugin

- (id) init {
    
    self = [super initWithObject: self];
    
    if (self) {
        
        [[DPHueManager sharedManager] setServiceProvider: self.serviceProvider];
        [[DPHueManager sharedManager] setPlugin: self];
        
        self.pluginName = @"hue (Device Connect Device Plug-in)";
        
        [self addProfile:[DPHueSystemProfile new]];
        
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            
            [notificationCenter addObserver:_self selector:@selector(enterForeground)
                       name:UIApplicationWillEnterForegroundNotification
                     object:application];
            
            [notificationCenter addObserver:_self selector:@selector(enterBackground)
                       name:UIApplicationDidEnterBackgroundNotification
                     object:application];
        });
    }
    
    return self;
}

- (void) dealloc {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];
}
/*!
 @brief バックグラウンドに回ったときの処理
 */
- (void) enterBackground {
    [[DPHueManager sharedManager] saveBridgeList];
}
/*!
 @brief フォアグラウンドに戻ったときの処理
 */
- (void) enterForeground {
    [[DPHueManager sharedManager] readBridgeList];
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceHue_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}
#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceHue_resources" ofType:@"bundle"]];
}
@end
