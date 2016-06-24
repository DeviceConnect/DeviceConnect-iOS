//
//  WebViewController.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@interface WebViewController : UIViewController<WKNavigationDelegate>
- (instancetype)initWithURL:(NSString*)urlString;
@end
