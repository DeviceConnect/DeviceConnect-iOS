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

@interface DPHostCanvasProfile ()

@property(nonatomic, weak) DPHostCanvasUIViewController * displayViewController;

@end

@implementation DPHostCanvasProfile

- (id)init
{
    self = [super init];
    if (self) {
        [self setDisplayViewController: nil];
        __weak DPHostCanvasProfile *weakSelf = self;
        
        // API登録(didReceivePostDrawImageRequest相当)
        NSString *postDrawImageRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectCanvasProfileAttrDrawImage];
        [self addPostPath: postDrawImageRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         BOOL send = YES;
                         
                         NSData *data = [DConnectCanvasProfile dataFromRequest:request];
                         NSString *uri = [DConnectCanvasProfile uriFromRequest:request];
                         NSString *serviceId = [request serviceId];
                         NSString *mimeType = [DConnectCanvasProfile mimeTypeFromRequest:request];
                         NSString *strX = [DConnectCanvasProfile xFromRequest: request];
                         NSString *strY = [DConnectCanvasProfile yFromRequest: request];
                         
                         if (mimeType != nil && ![weakSelf isMimeTypeWithString: mimeType]) {
                             [response setErrorToInvalidRequestParameterWithMessage: @"mimeType format is incorrect."];
                             return send;
                         }
                         if (strX != nil && ![weakSelf isFloatWithString: strX]) {
                             [response setErrorToInvalidRequestParameterWithMessage: @"x is different type."];
                             return send;
                         }
                         if (strY != nil && ![weakSelf isFloatWithString: strY]) {
                             [response setErrorToInvalidRequestParameterWithMessage: @"y is different type."];
                             return send;
                         }
                         double imageX = strX.doubleValue;
                         double imageY = strY.doubleValue;
                         NSString *mode = [DConnectCanvasProfile modeFromRequest: request];
                         
                         
                         if (serviceId == nil || [serviceId length] <= 0) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }
                         
                         NSData *canvas = data;
                         if (uri || [uri length] > 0) {
                             canvas = [NSData dataWithContentsOfURL:[NSURL URLWithString:uri]];
                             if (!canvas) {
                                 canvas = data;
                             }
                         }
                         if (canvas == nil || [canvas length] <= 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"data is not specied to update a file."];
                             return YES;
                         }
                         
                         DPHostCanvasDrawImage *drawImage = [[DPHostCanvasDrawImage alloc]
                                                             initWithParameter:canvas
                                                             imageX:imageX
                                                             imageY:imageY
                                                             mode:mode];
                         if ([weakSelf displayViewController] == nil) {
                             /* start ViewController */
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 DPHostCanvasUIViewController * displayViewController = [weakSelf presentCanvasProfileViewController: response drawObject: drawImage];
                                 [weakSelf setDisplayViewController: displayViewController];
                             });
                         } else {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [[weakSelf displayViewController] setDrawObject: drawImage];
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             });
                         }
                         
                         return NO;
                     }];
        
        // API登録(didReceiveDeleteDrawImageRequest相当)
        NSString *deleteDrawImageRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectCanvasProfileAttrDrawImage];
        [self addDeletePath: deleteDrawImageRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          if ([weakSelf displayViewController]) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [[weakSelf displayViewController] dismissViewControllerAnimated:YES completion:nil];
                              });
                              [response setResult:DConnectMessageResultTypeOk];
                          } else {
                              [response setErrorToIllegalDeviceStateWithMessage:@"the canvas is not displayed."];
                          }
                          return YES;
                      }];
    }
    return self;
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
        [rootView presentViewController:viewController animated:YES completion:^() {
        }];
        [response setResult:DConnectMessageResultTypeOk];
        [[DConnectManager sharedManager] sendResponse:response];
    } else {
        [response setErrorToNotSupportAttribute];
        [[DConnectManager sharedManager] sendResponse:response];
    }
    
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
