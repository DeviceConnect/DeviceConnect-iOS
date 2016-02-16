//
//  AppDelegate.m
//  dConnectBrowser
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppDelegate.h"
#import "GHDataManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.redirectURL = nil;
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //DBの初期値を設定
    //起動時にキャッシュ画像も一旦削除
    [[GHDataManager shareManager]initPrefs];
    
    //Cookieの初期設定を更新
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:@([GHUtils isCookieAccept]) forKey:IS_COOKIE_ACCEPT];
    
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (osVersion > 8.0) {
        UIUserNotificationType types =  UIUserNotificationTypeBadge|
        UIUserNotificationTypeSound|
        UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types
                                                                                   categories:nil];
        
        [application registerUserNotificationSettings:mySettings];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[GHDataManager shareManager]save];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (![url.scheme isEqualToString:@"dconnect"] && ![url.scheme isEqualToString:@"gotapi"]) {
        return NO;
    }
    
    NSString *directURLStr = [url.resourceSpecifier stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *redirectURL = [NSURL URLWithString:directURLStr];
    if (_URLLoadingCallback && redirectURL) {
        // UIApplicationWillEnterForegroundNotification通知オブザベーションによりコールバックが呼ばれた場合、
        // NSURLを引数に取るコールバックが保持される。その上で「dconnect」または「gotapi」URLスキーム経由でリダイレクト先URLが飛んできたのなら、
        // このコールバックにコールバックURLを渡す。
        
        _URLLoadingCallback(redirectURL);
        _URLLoadingCallback = nil;
        return YES;
    } else {
        return (_redirectURL = redirectURL) != nil;
    }
}

// HostデバイスプラグインのNotificationProfileのイベントは、各アプリでこのような処理を追加しなければイベントの通知が正常に行われない
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)localNotification
{
    if(application.applicationState == UIApplicationStateInactive) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"UIApplicationDidReceiveLocalNotification"
                                                                                             object:nil
                                                                                           userInfo:localNotification.userInfo]];
    }
}

@end
