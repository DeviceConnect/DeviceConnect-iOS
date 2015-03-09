//
//  DPPebbleKeyEventProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleKeyEventProfile.h"
#import "DPPebbleDevicePlugin.h"
#import "DPPebbleManager.h"
#import "DPPebbleProfileUtil.h"
#import "pebble_device_plugin_defines.h"

@interface DPPebbleKeyEventProfile ()
{
    DConnectMessage *mKeyEventOnDownCache;
    DConnectMessage *mKeyEventOnUpCache;
}

@end

@implementation DPPebbleKeyEventProfile


// initialize.
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self->mKeyEventOnDownCache = nil;
        self->mKeyEventOnUpCache = nil;
    }
    return self;
    
}

/**
 * Get configuration string.
 *
 * @param nType Key Type.
 * @param nCode Key Code.
 * @return Configure string.
 */
- (NSString *) getConfig:(int)nType
                 KeyCode:(int)nCode
{
    switch (nType) {
    case KEY_EVENT_KEY_TYPE_MEDIA:
        switch (nCode) {
        case KEY_EVENT_KEY_ID_UP:
            return @"MEDIA_NEXT";
        case KEY_EVENT_KEY_ID_SELECT:
            return @"MEDIA_PLAY";
        case KEY_EVENT_KEY_ID_DOWN:
            return @"MEDIA_PREVIOUS";
        case KEY_EVENT_KEY_ID_BACK:
            return @"MEDIA_BACK";
        default:
            return @"";
        }
    case KEY_EVENT_KEY_TYPE_DPAD_BUTTON:
        switch (nCode) {
        case KEY_EVENT_KEY_ID_UP:
            return @"DPAD_UP";
        case KEY_EVENT_KEY_ID_SELECT:
            return @"DPAD_CENTER";
        case KEY_EVENT_KEY_ID_DOWN:
            return @"DPAD_DOWN";
        case KEY_EVENT_KEY_ID_BACK:
            return @"DPAD_BACK";
        default:
            return @"";
        }
    case KEY_EVENT_KEY_TYPE_USER:
        switch (nCode) {
        case KEY_EVENT_KEY_ID_UP:
            return @"USER_CANCEL";
        case KEY_EVENT_KEY_ID_SELECT:
            return @"USER_SELECT";
        case KEY_EVENT_KEY_ID_DOWN:
            return @"USER_OK";
        case KEY_EVENT_KEY_ID_BACK:
            return @"USER_BACK";
        default:
            return @"";
        }
    case KEY_EVENT_KEY_TYPE_STD_KEY:
    default:
        switch (nCode) {
        case KEY_EVENT_KEY_ID_UP:
            return @"UP";
        case KEY_EVENT_KEY_ID_SELECT:
            return @"SELECT";
        case KEY_EVENT_KEY_ID_DOWN:
            return @"DOWN";
        case KEY_EVENT_KEY_ID_BACK:
            return @"BACK";
        default:
            return @"";
        }
    }
}

/**
 * Get key type flag value.
 *
 * @param nType Key Type.
 * @return Key Type Flag Value.
 */
- (int) getKeyTypeFlagValue:(int)nType
{
    switch (nType) {
    case KEY_EVENT_KEY_TYPE_MEDIA:
        return DConnectKeyEventProfileKeyTypeMediaCtrl;
    case KEY_EVENT_KEY_TYPE_DPAD_BUTTON:
        return DConnectKeyEventProfileKeyTypeDpadButton;
    case KEY_EVENT_KEY_TYPE_USER:
        return DConnectKeyEventProfileKeyTypeUser;
    case KEY_EVENT_KEY_TYPE_STD_KEY:
    default:
        return DConnectKeyEventProfileKeyTypeStdKey;
    }
}

#pragma mark - DConnectKeyEventProfileDelegate

// Receive get onDown request.
- (BOOL)           profile:(DConnectKeyEventProfile *)profile
didReceiveGetOnDownRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
{
    [DConnectKeyEventProfile setKeyEvent:self->mKeyEventOnDownCache target:response];
    return YES;
}

// Receive get onUp request.
- (BOOL)         profile:(DConnectKeyEventProfile *)profile
didReceiveGetOnUpRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
               serviceId:(NSString *)serviceId
{
    [DConnectKeyEventProfile setKeyEvent:self->mKeyEventOnUpCache target:response];
    return YES;
}

// Receive onDown event regustration request.
- (BOOL)           profile:(DConnectKeyEventProfile *)profile
didReceivePutOnDownRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                sessionKey:(NSString *)sessionKey
{
    __block BOOL responseFlg = YES;
    // Event registration.
    [DPPebbleProfileUtil handleRequest:request response:response isRemove:NO callback:^{
        
        // Register to Pebble.
        [[DPPebbleManager sharedManager] registOnDownEvent:serviceId callback:^(NSError *error) {
            // Registration success.
            // Error check.
            [DPPebbleProfileUtil handleErrorNormal:error response:response];
            
        } eventCallback:^(long attr, int keyId, int keyType) {
            // Create DConnect message
            DConnectMessage *message = [DConnectMessage message];
            [DConnectKeyEventProfile setId:keyId + [self getKeyTypeFlagValue:keyId] target:message];
            [DConnectKeyEventProfile setConfig:[self getConfig:keyType KeyCode:keyId] target:message];
            
            // Send event to DConnect.
            [DPPebbleProfileUtil sendMessageWithProvider:self.provider
                                                 profile:DConnectKeyEventProfileName
                                               attribute:DConnectKeyEventProfileAttrOnDown
                                               serviceID:serviceId
                                         messageCallback:^(DConnectMessage *eventMsg)
             {
                 // Add message to event.
                 [DConnectKeyEventProfile setKeyEvent:message target:eventMsg];
             } deleteCallback:^
             {
                 // Remove Pebble of events.
                 [[DPPebbleManager sharedManager] deleteOnDownEvent:serviceId callback:^(NSError *error) {
                     if (error) NSLog(@"Error:%@", error);
                 }];
             }];
        }];
        
        responseFlg = NO;
    }];
    
    return responseFlg;
}

// Receive onUp event regustration request.
- (BOOL)         profile:(DConnectKeyEventProfile *)profile
didReceivePutOnUpRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
               serviceId:(NSString *)serviceId
              sessionKey:(NSString *)sessionKey
{
    __block BOOL responseFlg = YES;
    // Event registration.
    [DPPebbleProfileUtil handleRequest:request response:response isRemove:NO callback:^{
        
        // Register to Pebble.
        [[DPPebbleManager sharedManager] registOnUpEvent:serviceId callback:^(NSError *error) {
            // Registration success.
            // Error check.
            [DPPebbleProfileUtil handleErrorNormal:error response:response];
            
        } eventCallback:^(long attr, int keyId, int keyType) {
            // Create DConnect message
            DConnectMessage *message = [DConnectMessage message];
            [DConnectKeyEventProfile setId:keyId + [self getKeyTypeFlagValue:keyId] target:message];
            [DConnectKeyEventProfile setConfig:[self getConfig:keyType KeyCode:keyId] target:message];
            
            // Send event to DConnect.
            [DPPebbleProfileUtil sendMessageWithProvider:self.provider
                                                 profile:DConnectKeyEventProfileName
                                               attribute:DConnectKeyEventProfileAttrOnUp
                                               serviceID:serviceId
                                         messageCallback:^(DConnectMessage *eventMsg)
             {
                 // Add message to event.
                 [DConnectKeyEventProfile setKeyEvent:message target:eventMsg];
             } deleteCallback:^
             {
                 // Remove Pebble of events.
                 [[DPPebbleManager sharedManager] deleteOnUpEvent:serviceId callback:^(NSError *error) {
                     if (error) NSLog(@"Error:%@", error);
                 }];
             }];
        }];
        
        responseFlg = NO;
    }];
    
    return responseFlg;
}

// Receive onDown event unregustration request.
- (BOOL)              profile:(DConnectKeyEventProfile *)profile
didReceiveDeleteOnDownRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId
                   sessionKey:(NSString *)sessionKey
{
    // Remove event of DConnect.
    [DPPebbleProfileUtil handleRequest:request response:response isRemove:YES callback:^{
        // Remove event of Pebble.
        [[DPPebbleManager sharedManager] deleteOnDownEvent:serviceId callback:^(NSError *error) {
            if (error) NSLog(@"Error:%@", error);
        }];
    }];
    return YES;
}

// Receive onUp event unregustration request.
- (BOOL)            profile:(DConnectKeyEventProfile *)profile
didReceiveDeleteOnUpRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                 sessionKey:(NSString *)sessionKey
{
    // Remove event of DConnect.
    [DPPebbleProfileUtil handleRequest:request response:response isRemove:YES callback:^{
        // Remove event of Pebble.
        [[DPPebbleManager sharedManager] deleteOnUpEvent:serviceId callback:^(NSError *error) {
            if (error) NSLog(@"Error:%@", error);
        }];
    }];
    return YES;
}

@end