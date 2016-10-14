//
//  WebViewController.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface WebViewController : UIViewController<WKNavigationDelegate, WKUIDelegate>
- (instancetype)initWithURL:(NSString*)urlString;
- (instancetype)initWithPath:(NSString*)path;

- (void)presentationDeviceView:(UIViewController*)viewController;
@end
