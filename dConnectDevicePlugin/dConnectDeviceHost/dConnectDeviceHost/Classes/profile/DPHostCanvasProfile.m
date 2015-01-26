//
//  DPHostCanvasProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostCanvasProfile.h"
#import "DPHostCanvasUIViewController.h"


#define PutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
top = top.presentedViewController; \
}

#define _Bundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceHost_resources" ofType:@"bundle"]]



@interface DPHostCanvasProfile ()
@end

@implementation DPHostCanvasProfile

// 初期化
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}


#pragma mark - DConnect

// 画像描画リクエストを受け取った
- (BOOL) profile:(DConnectFileProfile *)profile didReceivePostDrawImageRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        deviceId:(NSString *)deviceId
        mimeType:(NSString *)mimeType
            data:(NSData *)data
               x:(double)x
               y:(double)y
            mode:(NSString *)mode
{
    // パラメータチェック
    if (data == nil) {
        [response setErrorToInvalidRequestParameterWithMessage:@"data is not specied to update a file."];
        return YES;
    }
    
    /* debug */

//    UIApplication *application = [UIApplication sharedApplication];
//    if (application != nil) {
//        UIWindow *keyWindow = application.keyWindow;
//        if (keyWindow != nil) {
//            UIViewController *topViewController = keyWindow.rootViewController;
//            if (topViewController != nil) {
//                NSLog(@"topViewController != nil");
//            } else {
//                NSLog(@"topViewController == nil");
//            }
//        } else {
//            NSLog(@"keyWindow == nil");
//        }
//    } else {
//        NSLog(@"application == nil");
//    }
    
    
    /* debug */
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIViewController *topViewController;
        PutPresentedViewController(topViewController);
        if (topViewController != nil) {
            NSLog(@"topViewController != nil");
        } else {
            NSLog(@"topViewController == nil");
        }


//        NSBundle *bundle = DCBundle();
        NSBundle *bundle = _Bundle();
        if (bundle != nil) {
            NSLog(@"bundle != nil");
        } else {
            NSLog(@"bundle == nil");
        }
        
        
        NSString *storyBoardName = @"dConnectDeviceHost";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:storyBoardName
                                       bundle: bundle];
        if (sb != nil) {
            NSLog(@"sb != nil");
        } else {
            NSLog(@"sb == nil");
        }
        
        NSString *viewControllerId = @"Canvas";
        DPHostCanvasUIViewController *viewController = [sb instantiateViewControllerWithIdentifier: viewControllerId];
        if (viewController != nil) {
            NSLog(@"viewController != nil");
        } else {
            NSLog(@"viewController == nil");
        }

        if (viewController != nil) {
            UIViewController *rootView;
            PutPresentedViewController(rootView);
            [rootView presentViewController:viewController animated:YES completion:nil];
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setErrorToNotSupportAttribute];
        }
        
//        DPHostCanvasUIViewController *canvasViewController
//        = (DPHostCanvasUIViewController *)[((UINavigationController *)viewController) viewControllers][0];
//        if (canvasViewController) {
//            UIViewController *rootView;
//            PutPresentedViewController(rootView);
//
//            [rootView presentViewController:canvasViewController animated:YES completion:nil];
//            [response setResult:DConnectMessageResultTypeOk];
//        } else {
//            [response setErrorToNotSupportAttribute];
//        }
        
        [[DConnectManager sharedManager] sendResponse:response];
            
        
        /***/
        
//        UIViewController *viewController = [_dataSource profile:self settingPageForRequest:request];
//        if (viewController) {
//            UIViewController *rootView;
//            DCPutPresentedViewController(rootView);
//            
//            [rootView presentViewController:viewController animated:YES completion:nil];
//            [response setResult:DConnectMessageResultTypeOk];
//        } else {
//            [response setErrorToNotSupportAttribute];
//        }
//        
//        [[DConnectManager sharedManager] sendResponse:response];
    });
    
    
//    // 画像変換
//    NSData *imgdata = [DPHostImage convertImage:data x:x y:y mode:mode];
//    if (!imgdata) {
//        [response setErrorToUnknown];
//        return YES;
//    }
//    
//    [[DPHostManager sharedManager] sendImage:deviceId data:imgdata callback:^(NSError *error) {
//        // エラーチェック
//        [DPHostProfileUtil handleErrorNormal:error response:response];
//    }];
    return NO;
}

@end
