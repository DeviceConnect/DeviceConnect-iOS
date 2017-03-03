//
//  DPHostTouchProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostDevicePlugin.h"
#import "DPHostTouchProfile.h"
#import "DPHostService.h"
#import "DPHostUtils.h"
#import "DPHostTouchUIViewController.h"

#define PutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
top = top.presentedViewController; \
}

#define _Bundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceHost_resources" ofType:@"bundle"]]
NSString *const DPHostTouchProfileEnumStart = @"start";
NSString *const DPHostTouchProfileEnumEnd = @"end";
NSString *const DPHostTouchProfileEnumDoubleTap = @"doubletap";
NSString *const DPHosttTouchProfileEnumMove = @"move";
NSString *const DPHostTouchProfileEnumCancel = @"cancel";

NSString *const DPHostTouchProfileAttrOnTouchChange = @"ontouchchange";
@interface DPHostTouchProfile ()
{
    // Touch profile OnTouch cache.
    DConnectMessage *mOnTouchCache;
    // Touch profile OnTouch cache time.
    UInt64 mOnTouchCacheTime;
    // Touch profile OnTouchStart cache.
    DConnectMessage *mOnTouchStartCache;
    // Touch profile OnTouchStart cache time.
    UInt64 mOnTouchStartCacheTime;
    // Touch profile OnTouchEnd cache.
    DConnectMessage *mOnTouchEndCache;
    // Touch profile OnTouchEnd cache time.
    UInt64 mOnTouchEndCacheTime;
    // Touch profile OnDoubleTap cache.
    DConnectMessage *mOnDoubleTapCache;
    // Touch profile OnDoubleTap cache time.
    UInt64 mOnDoubleTapCacheTime;
    // Touch profile OnTouchMove cache.
    DConnectMessage *mOnTouchMoveCache;
    // Touch profile OnTouchMove cache time.
    UInt64 mOnTouchMoveCacheTime;
    // Touch profile OnTouchCancel cache.
    DConnectMessage *mOnTouchCancelCache;
    // Touch profile OnTouchCancel cache time.
    UInt64 mOnTouchCancelCacheTime;
    // Touch profile OnTouchChange cache.
    DConnectMessage *mOnTouchChangeCache;
    // Touch profile OnTouchChange cache time.
    UInt64 mOnTouchChangeCacheTime;
    // Touch event management flag.
    long mTouchEventManageFlag;


    DPHostTouchUIViewController *_displayViewController;
}

@property DConnectEventManager *eventMgr;

@end

@implementation DPHostTouchProfile

// Touch profile cache retention time (mSec).
static const UInt64 CACHE_RETENTION_TIME = 10000;
// Touch event management flag.
static const long FLAG_ON_TOUCH = 0x00000001;
static const long FLAG_ON_TOUCH_START = 0x00000002;
static const long FLAG_ON_TOUCH_END = 0x00000004;
static const long FLAG_ON_DOUBLE_TAP = 0x00000008;
static const long FLAG_ON_TOUCH_MOVE = 0x00000010;
static const long FLAG_ON_TOUCH_CANCEL = 0x00000020;
static const long FLAG_ON_TOUCH_CHANGE = 0x00000040;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _displayViewController = nil;
        __weak DPHostTouchProfile *weakSelf = self;
 
        mOnTouchCache = nil;
        mOnTouchCacheTime = 0;
        mOnTouchStartCache = nil;
        mOnTouchStartCacheTime = 0;
        mOnTouchEndCache = nil;
        mOnTouchEndCacheTime = 0;
        mOnDoubleTapCache = nil;
        mOnDoubleTapCacheTime = 0;
        mOnTouchMoveCache = nil;
        mOnTouchMoveCacheTime = 0;
        mOnTouchCancelCache = nil;
        mOnTouchCancelCacheTime = 0;
        mOnTouchChangeCache = nil;
        mOnTouchChangeCacheTime = 0;
        mTouchEventManageFlag = 0;
        
        // Get event manager.
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        __weak DConnectEventManager *weakEventMgr = self.eventMgr;
        
        // API登録(didReceiveGetOnTouchChangeRequest相当)
        NSString *getOnTouchChangeRequestApiPath = [self apiPath: nil
                                             attributeName: DPHostTouchProfileAttrOnTouchChange];
        [self addGetPath: getOnTouchChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectMessage *touch = [weakSelf getTouchCache:DPHostTouchProfileAttrOnTouchChange];
                         [DConnectTouchProfile setTouch:touch target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        // API登録(didReceiveGetOnTouchRequest相当)
        NSString *getOnTouchRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectTouchProfileAttrOnTouch];
        [self addGetPath: getOnTouchRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectMessage *touch = [weakSelf getTouchCache:DConnectTouchProfileAttrOnTouch];
                         [DConnectTouchProfile setTouch:touch target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];

        // API登録(didReceiveGetOnTouchStartRequest相当)
        NSString *getOnTouchStartRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectTouchProfileAttrOnTouchStart];
        [self addGetPath: getOnTouchStartRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectMessage *touch = [weakSelf getTouchCache:DConnectTouchProfileAttrOnTouchStart];
                         [DConnectTouchProfile setTouch:touch target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];

        // API登録(didReceiveGetOnTouchEndRequest相当)
        NSString *getOnTouchEndRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectTouchProfileAttrOnTouchEnd];
        [self addGetPath: getOnTouchEndRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectMessage *touch = [weakSelf getTouchCache:DConnectTouchProfileAttrOnTouchEnd];
                         [DConnectTouchProfile setTouch:touch target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        
        // API登録(didReceiveGetOnDoubleTapRequest相当)
        NSString *getOnDoubleTapRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectTouchProfileAttrOnDoubleTap];
        [self addGetPath: getOnDoubleTapRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectMessage *touch = [weakSelf getTouchCache:DConnectTouchProfileAttrOnDoubleTap];
                         [DConnectTouchProfile setTouch:touch target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        
        // API登録(didReceiveGetOnTouchMoveRequest相当)
        NSString *getOnTouchMoveRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectTouchProfileAttrOnTouchMove];
        [self addGetPath: getOnTouchMoveRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectMessage *touch = [weakSelf getTouchCache:DConnectTouchProfileAttrOnTouchMove];
                         [DConnectTouchProfile setTouch:touch target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        
        // API登録(didReceiveGetOnTouchCancelRequest相当)
        NSString *getOnTouchCancelRequestApiPath = [self apiPath: nil
                                                   attributeName: DConnectTouchProfileAttrOnTouchCancel];
        [self addGetPath: getOnTouchCancelRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectMessage *touch = [weakSelf getTouchCache:DConnectTouchProfileAttrOnTouchCancel];
                         [DConnectTouchProfile setTouch:touch target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        // API登録(didReceivePutOnTouchChangeRequest相当)
        NSString *putOnTouchChangeRequestApiPath = [self apiPath: nil
                                             attributeName: DPHostTouchProfileAttrOnTouchChange];
        [self addPutPath: putOnTouchChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [weakSelf startTouchView];
                                 mTouchEventManageFlag |= FLAG_ON_TOUCH_CHANGE;
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        // API登録(didReceivePutOnTouchRequest相当)
        NSString *putOnTouchRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectTouchProfileAttrOnTouch];
        [self addPutPath: putOnTouchRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [weakSelf startTouchView];
                                 mTouchEventManageFlag |= FLAG_ON_TOUCH;
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnTouchStartRequest相当)
        NSString *putOnTouchStartRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectTouchProfileAttrOnTouchStart];
        [self addPutPath: putOnTouchStartRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [weakSelf startTouchView];
                                 mTouchEventManageFlag |= FLAG_ON_TOUCH_START;
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnTouchEndRequest相当)
        NSString *putOnTouchEndRequestApiPath = [self apiPath: nil
                                                           attributeName: DConnectTouchProfileAttrOnTouchEnd];
        [self addPutPath: putOnTouchEndRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [weakSelf startTouchView];
                                 mTouchEventManageFlag |= FLAG_ON_TOUCH_END;
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnDoubleTapRequest相当)
        NSString *putOnDoubleTapRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectTouchProfileAttrOnDoubleTap];
        [self addPutPath: putOnDoubleTapRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [weakSelf startTouchView];
                                 mTouchEventManageFlag |= FLAG_ON_DOUBLE_TAP;
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnTouchMoveRequest相当)
        NSString *putOnTouchMoveRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectTouchProfileAttrOnTouchMove];
        [self addPutPath: putOnTouchMoveRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [weakSelf startTouchView];
                                 mTouchEventManageFlag |= FLAG_ON_TOUCH_MOVE;
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnTouchCancelRequest相当)
        NSString *putOnTouchCancelRequestApiPath = [self apiPath: nil
                                                   attributeName: DConnectTouchProfileAttrOnTouchCancel];
        [self addPutPath: putOnTouchCancelRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [weakSelf startTouchView];
                                 mTouchEventManageFlag |= FLAG_ON_TOUCH_CANCEL;
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];

        // API登録(didReceiveDeleteOnTouchChangeRequest相当)
        NSString *deleteOnTouchChangeRequestApiPath = [self apiPath: nil
                                                attributeName: DPHostTouchProfileAttrOnTouchChange];
        [self addDeletePath: deleteOnTouchChangeRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakEventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // No error.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_CHANGE);
                                    [weakSelf closeTouchView];
                                    break;
                                case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // Event not found.
                                case DConnectEventErrorFailed:           // Failed process.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        // API登録(didReceiveDeleteOnTouchRequest相当)
        NSString *deleteOnTouchRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectTouchProfileAttrOnTouch];
        [self addDeletePath: deleteOnTouchRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakEventMgr removeEventForRequest:request]) {
                             case DConnectEventErrorNone:             // No error.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 mTouchEventManageFlag &= ~(FLAG_ON_TOUCH);
                                 [weakSelf closeTouchView];
                                 break;
                             case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // Event not found.
                             case DConnectEventErrorFailed:           // Failed process.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnTouchStartRequest相当)
        NSString *deleteOnTouchStartRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectTouchProfileAttrOnTouchStart];
        [self addDeletePath: deleteOnTouchStartRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakEventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // No error.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_START);
                                    [weakSelf closeTouchView];
                                    break;
                                case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // Event not found.
                                case DConnectEventErrorFailed:           // Failed process.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnTouchEndRequest相当)
        NSString *deleteOnTouchEndRequestApiPath = [self apiPath: nil
                                                   attributeName: DConnectTouchProfileAttrOnTouchEnd];
        [self addDeletePath: deleteOnTouchEndRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakEventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // No error.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_END);
                                    [weakSelf closeTouchView];
                                    break;
                                case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // Event not found.
                                case DConnectEventErrorFailed:           // Failed process.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnDoubleTapRequest相当)
        NSString *deleteOnDoubleTapRequestApiPath = [self apiPath: nil
                                                    attributeName: DConnectTouchProfileAttrOnDoubleTap];
        [self addDeletePath: deleteOnDoubleTapRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakEventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // No error.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    mTouchEventManageFlag &= ~(FLAG_ON_DOUBLE_TAP);
                                    [weakSelf closeTouchView];
                                    break;
                                case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // Event not found.
                                case DConnectEventErrorFailed:           // Failed process.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnTouchMoveRequest相当)
        NSString *deleteOnTouchMoveRequestApiPath = [self apiPath: nil
                                                    attributeName: DConnectTouchProfileAttrOnTouchMove];
        [self addDeletePath: deleteOnTouchMoveRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakEventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // No error.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_MOVE);
                                    [weakSelf closeTouchView];
                                    break;
                                case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // Event not found.
                                case DConnectEventErrorFailed:           // Failed process.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnTouchCancelRequest相当)
        NSString *deleteOnTouchCancelRequestApiPath = [self apiPath: nil
                                                      attributeName: DConnectTouchProfileAttrOnTouchCancel];
        [self addDeletePath: deleteOnTouchCancelRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakEventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // No error.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_CANCEL);
                                    [weakSelf closeTouchView];
                                    break;
                                case DConnectEventErrorInvalidParameter: // Invalid Parameter.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // Event not found.
                                case DConnectEventErrorFailed:           // Failed process.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
    }
    return self;
}

- (void)dealloc
{
    // Remove notification receive.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (DPHostTouchUIViewController *)presentTouchProfileViewController {
    NSString *storyBoardName = @"dConnectDeviceHost";
    UIStoryboard *storyBoard = [self storyboardWithName: storyBoardName];
    
    NSString *viewControllerId = @"Touch";
    DPHostTouchUIViewController *viewController
    = [storyBoard instantiateViewControllerWithIdentifier:viewControllerId];
    if (viewController != nil) {
        UIViewController *rootView;
        PutPresentedViewController(rootView);
        if (![rootView isKindOfClass:[DPHostTouchUIViewController class]]) {
            [rootView presentViewController:viewController animated:YES completion:nil];
            viewController.hostTouchView.delegate = self;
        }
    }
    return viewController;
}

- (void)showTouchView {
    if (_displayViewController) {
        UIViewController *rootView;
        PutPresentedViewController(rootView);
        if (![rootView isKindOfClass:[DPHostTouchUIViewController class]]) {
            [rootView presentViewController:_displayViewController animated:YES completion:nil];
        }
    }
}

- (void)startTouchView {
    if (mTouchEventManageFlag == 0) {
        if (_displayViewController == nil) {
            /* start ViewController */
            dispatch_async(dispatch_get_main_queue(), ^{
                _displayViewController = [self presentTouchProfileViewController];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showTouchView];
            });
        }
    }
}

- (void)closeTouchView {
    if (mTouchEventManageFlag == 0) {
        if (_displayViewController) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_displayViewController dismissViewControllerAnimated:YES completion:nil];
            });
        }
    }
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

/*!
 @brief Get Touch cache data.
 @param attr Attribute.
 @return Touch cache data.
 */
- (DConnectMessage *) getTouchCache:(NSString *)attr {
    UInt64 CurrentTime = (UInt64)floor((CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000.0);
    if (!attr) {
        return nil;
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouch] == NSOrderedSame) {
        if (CurrentTime - mOnTouchCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchCache;
        } else {
            return nil;
        }
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchStart] == NSOrderedSame) {
        if (CurrentTime - mOnTouchStartCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchStartCache;
        } else {
            return nil;
        }
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchEnd] == NSOrderedSame) {
        if (CurrentTime - mOnTouchEndCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchEndCache;
        } else {
            return nil;
        }
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnDoubleTap] == NSOrderedSame) {
        if (CurrentTime - mOnDoubleTapCacheTime <= CACHE_RETENTION_TIME) {
            return mOnDoubleTapCache;
        } else {
            return nil;
        }
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchMove] == NSOrderedSame) {
        if (CurrentTime - mOnTouchMoveCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchMoveCache;
        } else {
            return nil;
        }
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchCancel] == NSOrderedSame) {
        if (CurrentTime - mOnTouchCancelCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchCancelCache;
        } else {
            return nil;
        }
    } else if ([attr localizedCaseInsensitiveCompare: DPHostTouchProfileAttrOnTouchChange] == NSOrderedSame) {
        if (CurrentTime - mOnTouchChangeCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchChangeCache;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

/*!
 @brief Set Touch data to cache.
 @param attr Attribute.
 @param touchData Touch data.
 */
- (void) setTouchCache:(NSString *)attr
             touchData:(DConnectMessage *)touchData {
    UInt64 CurrentTime = (UInt64)floor((CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000.0);
    if (!attr) {
        return;
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouch] == NSOrderedSame) {
        mOnTouchCache = touchData;
        mOnTouchCacheTime = CurrentTime;
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchStart] == NSOrderedSame) {
        mOnTouchStartCache = touchData;
        mOnTouchStartCacheTime = CurrentTime;
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchEnd] == NSOrderedSame) {
        mOnTouchEndCache = touchData;
        mOnTouchEndCacheTime = CurrentTime;
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnDoubleTap] == NSOrderedSame) {
        mOnDoubleTapCache = touchData;
        mOnDoubleTapCacheTime = CurrentTime;
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchMove] == NSOrderedSame) {
        mOnTouchMoveCache = touchData;
        mOnTouchMoveCacheTime = CurrentTime;
    } else if ([attr localizedCaseInsensitiveCompare: DConnectTouchProfileAttrOnTouchCancel] == NSOrderedSame) {
        mOnTouchCancelCache = touchData;
        mOnTouchCancelCacheTime = CurrentTime;
    } else if ([attr localizedCaseInsensitiveCompare: DPHostTouchProfileAttrOnTouchChange] == NSOrderedSame) {
        mOnTouchChangeCache = touchData;
        mOnTouchChangeCacheTime = CurrentTime;
    }
}

/*!
 @brief Send touch event.
 @param eventMsg Touch data.
 */
- (void) sendTouchEvent:(DConnectMessage *)eventMsg {
    [SELF_PLUGIN sendEvent:eventMsg];
}

@end
