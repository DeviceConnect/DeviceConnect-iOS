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
#import "DPHostServiceDiscoveryProfile.h"
#import "DPHostUtils.h"
#import "DPHostTouchUIViewController.h"

#define PutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
top = top.presentedViewController; \
}

#define _Bundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceHost_resources" ofType:@"bundle"]]

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        _displayViewController = nil;

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
        mTouchEventManageFlag = 0;
        
        // Get event manager.
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
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
    if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouch]) {
        if (CurrentTime - mOnTouchCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchCache;
        } else {
            return nil;
        }
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchStart]) {
        if (CurrentTime - mOnTouchStartCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchStartCache;
        } else {
            return nil;
        }
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchEnd]) {
        if (CurrentTime - mOnTouchEndCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchEndCache;
        } else {
            return nil;
        }
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnDoubleTap]) {
        if (CurrentTime - mOnDoubleTapCacheTime <= CACHE_RETENTION_TIME) {
            return mOnDoubleTapCache;
        } else {
            return nil;
        }
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchMove]) {
        if (CurrentTime - mOnTouchMoveCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchMoveCache;
        } else {
            return nil;
        }
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchCancel]) {
        if (CurrentTime - mOnTouchCancelCacheTime <= CACHE_RETENTION_TIME) {
            return mOnTouchCancelCache;
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
    if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouch]) {
        mOnTouchCache = touchData;
        mOnTouchCacheTime = CurrentTime;
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchStart]) {
        mOnTouchStartCache = touchData;
        mOnTouchStartCacheTime = CurrentTime;
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchEnd]) {
        mOnTouchEndCache = touchData;
        mOnTouchEndCacheTime = CurrentTime;
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnDoubleTap]) {
        mOnDoubleTapCache = touchData;
        mOnDoubleTapCacheTime = CurrentTime;
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchMove]) {
        mOnTouchMoveCache = touchData;
        mOnTouchMoveCacheTime = CurrentTime;
    } else if ([self isEqualToAttribute:attr cmp:DConnectTouchProfileAttrOnTouchCancel]) {
        mOnTouchCancelCache = touchData;
        mOnTouchCancelCacheTime = CurrentTime;
    }
}

/*!
 @brief Send touch event.
 @param eventMsg Touch data.
 */
- (void) sendTouchEvent:(DConnectMessage *)eventMsg {
    [SELF_PLUGIN sendEvent:eventMsg];
}

#pragma mark - Get Methods
// Receive get onTouch request.
- (BOOL)            profile:(DConnectTouchProfile *)profile
didReceiveGetOnTouchRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
{
    DConnectMessage *touch = [self getTouchCache:DConnectTouchProfileAttrOnTouch];
    [DConnectTouchProfile setTouch:touch target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

// Receive get onTouchStart request.
- (BOOL)                 profile:(DConnectTouchProfile *)profile
didReceiveGetOnTouchStartRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
{
    DConnectMessage *touch = [self getTouchCache:DConnectTouchProfileAttrOnTouchStart];
    [DConnectTouchProfile setTouch:touch target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

// Receive get onTouchEnd request.
- (BOOL)               profile:(DConnectTouchProfile *)profile
didReceiveGetOnTouchEndRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
{
    DConnectMessage *touch = [self getTouchCache:DConnectTouchProfileAttrOnTouchEnd];
    [DConnectTouchProfile setTouch:touch target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

// Receive get onDoubleTap request.
- (BOOL)                profile:(DConnectTouchProfile *)profile
didReceiveGetOnDoubleTapRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    DConnectMessage *touch = [self getTouchCache:DConnectTouchProfileAttrOnDoubleTap];
    [DConnectTouchProfile setTouch:touch target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

// Receive get onTouchMove request.
- (BOOL)                profile:(DConnectTouchProfile *)profile
didReceiveGetOnTouchMoveRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    DConnectMessage *touch = [self getTouchCache:DConnectTouchProfileAttrOnTouchMove];
    [DConnectTouchProfile setTouch:touch target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

// Receive get onTouchCancel request.
- (BOOL)                  profile:(DConnectTouchProfile *)profile
didReceiveGetOnTouchCancelRequest:(DConnectRequestMessage *)request
                         response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
{
    DConnectMessage *touch = [self getTouchCache:DConnectTouchProfileAttrOnTouchCancel];
    [DConnectTouchProfile setTouch:touch target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

#pragma mark - Put Methods
#pragma mark Event Registration

- (BOOL)            profile:(DConnectTouchProfile *)profile
didReceivePutOnTouchRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                 sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr addEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            [self startTouchView];
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
}

- (BOOL)                 profile:(DConnectTouchProfile *)profile
didReceivePutOnTouchStartRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                      sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr addEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            [self startTouchView];
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
}

- (BOOL)            profile:(DConnectTouchProfile *)profile
didReceivePutOnTouchEndRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                 sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr addEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            [self startTouchView];
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
}

- (BOOL)                profile:(DConnectTouchProfile *)profile
didReceivePutOnDoubleTapRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                     sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr addEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            [self startTouchView];
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
}

- (BOOL)                profile:(DConnectTouchProfile *)profile
didReceivePutOnTouchMoveRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                     sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr addEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            [self startTouchView];
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
}

- (BOOL)                  profile:(DConnectTouchProfile *)profile
didReceivePutOnTouchCancelRequest:(DConnectRequestMessage *)request
                         response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
                       sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr addEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            [self startTouchView];
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
}

#pragma mark - Delete Methods
#pragma mark Event Unregistration

- (BOOL)               profile:(DConnectTouchProfile *)profile
didReceiveDeleteOnTouchRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
                    sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            mTouchEventManageFlag &= ~(FLAG_ON_TOUCH);
            [self closeTouchView];
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
}

- (BOOL)                    profile:(DConnectTouchProfile *)profile
didReceiveDeleteOnTouchStartRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
                         sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_START);
            [self closeTouchView];
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
}

- (BOOL)                  profile:(DConnectTouchProfile *)profile
didReceiveDeleteOnTouchEndRequest:(DConnectRequestMessage *)request
                         response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
                       sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_END);
            [self closeTouchView];
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
}

- (BOOL)                   profile:(DConnectTouchProfile *)profile
didReceiveDeleteOnDoubleTapRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                         serviceId:(NSString *)serviceId
                        sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            mTouchEventManageFlag &= ~(FLAG_ON_DOUBLE_TAP);
            [self closeTouchView];
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
}

- (BOOL)                   profile:(DConnectTouchProfile *)profile
didReceiveDeleteOnTouchMoveRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                         serviceId:(NSString *)serviceId
                        sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_MOVE);
            [self closeTouchView];
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
}

- (BOOL)                     profile:(DConnectTouchProfile *)profile
didReceiveDeleteOnTouchCancelRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                          sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
        case DConnectEventErrorNone:             // No error.
            [response setResult:DConnectMessageResultTypeOk];
            mTouchEventManageFlag &= ~(FLAG_ON_TOUCH_CANCEL);
            [self closeTouchView];
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
}

@end
