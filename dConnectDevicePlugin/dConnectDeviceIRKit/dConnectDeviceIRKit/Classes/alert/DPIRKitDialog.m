//
//  DPIRKitDialog.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPIRKitDialog.h"
#import "DPIRKitConst.h"
#import <objc/runtime.h>

static const char kAssocKey_Window;

NSString *const DPIRKitCategoryLight = @"ライト";
NSString *const DPIRKitCategoryTV = @"テレビ";


@implementation DPIRKitDialog

- (void)viewDidLoad {
    [super viewDidLoad];
}

+ (void)doShowForWindow:(UIWindow *)w
         storyboardName:(NSString*)storyboardName{
    UIWindow *window = w;
    window.alpha = 0.;
    window.transform = CGAffineTransformMakeScale(1.0, 1.0);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:DPIRBundle()];
    window.rootViewController = [storyboard instantiateInitialViewController];
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:0.];
    window.windowLevel = UIWindowLevelNormal + 5;
    
    [window makeKeyAndVisible];
    
    objc_setAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [UIView transitionWithView:window duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut animations:^{
        window.alpha = 1.;
        window.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];

}

+ (void)doClose
{
    UIWindow *window = objc_getAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window);
    
    [UIView transitionWithView:window
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        UIView *view = window.rootViewController.view;
                        
                        for (UIView *v in view.subviews) {
                            v.transform = CGAffineTransformMakeScale(.8, .8);
                        }
                        
                        window.alpha = 0;
                    }
                    completion:^(BOOL finished) {
                        
                        [window.rootViewController.view removeFromSuperview];
                        window.rootViewController = nil;
                        
                        // 上乗せしたウィンドウを破棄
                        objc_setAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        
                        // メインウィンドウをキーウィンドウにする
                        UIWindow *nextWindow = [[UIApplication sharedApplication].delegate window];
                        [nextWindow makeKeyAndVisible];
                    }];
}

@end
