//
//  DPHostCanvasProfile.m
//  dConnectDeviceHost
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



@interface DPHostCanvasProfile () {
DPHostCanvasUIViewController *_displayViewController;
}

@end

@implementation DPHostCanvasProfile

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        _displayViewController = nil;
    }
    return self;
}

#pragma mark - DConnect

- (BOOL) profile:(DConnectCanvasProfile *)profile didReceivePostDrawImageRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
        mimeType:(NSString *)mimeType
            data:(NSData *)data
          imageX:(double)imageX
          imageY:(double)imageY
            mode:(NSString *)mode
{
    if (data == nil || [data length] <= 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"data is not specied to update a file."];
        return YES;
    }
    if (serviceId == nil || [serviceId length] <= 0) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPHostCanvasDrawImage *drawImage = [[DPHostCanvasDrawImage alloc]
                                            initWithParameter:data
                                                       imageX:imageX
                                                       imageY:imageY
                                                         mode:mode];
    
    if (_displayViewController == nil) {
        /* start ViewController */
        dispatch_async(dispatch_get_main_queue(), ^{
            _displayViewController = [self presentCanvasProfileViewController: response drawObject: drawImage];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_displayViewController setDrawObject: drawImage];
        });
    }

    return NO;
}

- (void) disappearViewController {
    _displayViewController = nil;
}


- (DPHostCanvasUIViewController *)presentCanvasProfileViewController: (DConnectResponseMessage *)response
                                drawObject: (DPHostCanvasDrawObject *)drawObject
{
    NSString *storyBoardName = @"dConnectDeviceHost";
    UIStoryboard *storyBoard = [self storyboardWithName: storyBoardName];
    
    NSString *viewControllerId = @"Canvas";
    DPHostCanvasUIViewController *viewController
        = [storyBoard instantiateViewControllerWithIdentifier:viewControllerId];
    if (viewController != nil) {
        viewController.delegate = self;
        
        [viewController setDrawObject: drawObject];
        
        UIViewController *rootView;
        PutPresentedViewController(rootView);
        [rootView presentViewController:viewController animated:YES completion:nil];
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToNotSupportAttribute];
    }
    
    [[DConnectManager sharedManager] sendResponse:response];
    
    return viewController;
}

- (UIStoryboard *)storyboardWithName: (NSString *)storyBoardName {
    
    UIViewController *topViewController;
    PutPresentedViewController(topViewController);
    if (topViewController == nil) {
        return nil;
    }
    
    NSBundle *bundle = _Bundle();
    if (bundle == nil) {
        return nil;
    }
    
    return [UIStoryboard storyboardWithName:storyBoardName
                                                 bundle: bundle];
}



@end
