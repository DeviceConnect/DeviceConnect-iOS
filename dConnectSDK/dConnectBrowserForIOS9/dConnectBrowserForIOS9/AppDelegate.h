//
//  AppDelegate.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSURL *redirectURL;
@property (strong, nonatomic) NSURL* latestURL;
@property (copy) void(^URLLoadingCallback)(NSURL *);
@property (copy) void(^requestToCloseSafariView)(void);

@end

