//
//  AppDelegate.h
//  dConnectBrowserForIOS9
//
//  Created by 星　貴之 on 2016/02/15.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property NSURL *redirectURL;
@property (copy) void(^URLLoadingCallback)(NSURL *);


@end

