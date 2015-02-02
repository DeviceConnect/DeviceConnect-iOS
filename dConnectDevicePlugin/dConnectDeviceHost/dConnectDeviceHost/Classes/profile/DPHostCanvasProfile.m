//
//  DPHostCanvasProfile.m
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostCanvasProfile.h"
#import "DPHostCanvasUIViewController.h"
#import "DPHostCanvasDrawImage.h"


#define PutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
top = top.presentedViewController; \
}

#define _Bundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceHost_resources" ofType:@"bundle"]]



@interface DPHostCanvasProfile ()

- (void)presentCanvasProfileViewController: (DConnectResponseMessage *)response
                                      data: (NSData *)data
                                         x: (double)x
                                         y: (double)y
                                      mode: (NSString *)mode;


@end

@implementation DPHostCanvasProfile

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
- (BOOL) profile:(DConnectCanvasProfile *)profile didReceivePostDrawImageRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        deviceId:(NSString *)deviceId
        mimeType:(NSString *)mimeType
            data:(NSData *)data
               x:(double)x
               y:(double)y
            mode:(NSString *)mode
{
    if (data == nil) {
        [response setErrorToInvalidRequestParameterWithMessage:@"data is not specied to update a file."];
        return YES;
    }
    
    /* start ViewController */
    dispatch_async(dispatch_get_main_queue(), ^{
NSLog(data == nil ? @"didReceivePostDrawImageRequest() - data: nil" : @"didReceivePostDrawImageRequest() - data: not nil");
        [self presentCanvasProfileViewController: response data: data x: x y: y mode: mode];
    });

    return NO;
}

- (void) disappearViewController {
    NSLog(@"disappearViewController");
    
    
}


- (void)presentCanvasProfileViewController: (DConnectResponseMessage *)response
                                      data: (NSData *)data
                                         x: (double)x
                                         y: (double)y
                                      mode: (NSString *)mode
{
NSLog(data == nil ? @"presentCanvasProfileViewController() - data: nil" : @"presentCanvasProfileViewController() - data: not nil");
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
        viewController.delegate = self;
        
        [viewController setDrawImage: data x: x y: y mode: mode];
        
        UIViewController *rootView;
        PutPresentedViewController(rootView);
        [rootView presentViewController:viewController animated:YES completion:nil];
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToNotSupportAttribute];
    }
    
    [[DConnectManager sharedManager] sendResponse:response];
}


@end
