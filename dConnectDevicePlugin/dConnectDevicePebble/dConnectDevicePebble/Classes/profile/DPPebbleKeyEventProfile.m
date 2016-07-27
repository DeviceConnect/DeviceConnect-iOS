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
    DConnectMessage *mOnDownCache;
    UInt64 mOnDownCacheTime;
    DConnectMessage *mOnUpCache;
    UInt64 mOnUpCacheTime;
}

@end

@implementation DPPebbleKeyEventProfile

// Touch profile cache retention time (mSec).
static const UInt64 CACHE_RETENTION_TIME = 10000;

// initialize.
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        __weak DPPebbleKeyEventProfile *weakSelf = self;
        mOnDownCache = nil;
        mOnDownCacheTime = 0;
        mOnUpCache = nil;
        mOnUpCacheTime = 0;
        
        // API登録(didReceiveGetOnDownRequest相当)
        NSString *getOnDownRequestApiPath = [self apiPathWithProfile: self.profileName
                                                       interfaceName: nil
                                                       attributeName: DConnectKeyEventProfileAttrOnDown];
        [self addGetPath: getOnDownRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         [response setResult:DConnectMessageResultTypeOk];
                         DConnectMessage *keyevent = [weakSelf getKeyEventCache:DConnectKeyEventProfileAttrOnDown];
                         [DConnectKeyEventProfile setKeyEvent:keyevent target:response];
                         return YES;
                     }];
        
        // API登録(didReceiveGetOnUpRequest相当)
        NSString *getOnUpRequestApiPath = [self apiPathWithProfile: self.profileName
                                                     interfaceName: nil
                                                     attributeName: DConnectKeyEventProfileAttrOnUp];
        [self addGetPath: getOnUpRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         [response setResult:DConnectMessageResultTypeOk];
                         DConnectMessage *keyevent = [weakSelf getKeyEventCache:DConnectKeyEventProfileAttrOnUp];
                         [DConnectKeyEventProfile setKeyEvent:keyevent target:response];
                         return YES;
                     }];
        
        // API登録(didReceivePutOnDownRequest相当)
        NSString *putOnDownRequestApiPath = [self apiPathWithProfile: self.profileName
                                                       interfaceName: nil
                                                       attributeName: DConnectKeyEventProfileAttrOnDown];
        [self addPutPath: putOnDownRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         __block BOOL responseFlg = YES;
                         // Event registration.
                         [DPPebbleProfileUtil handleRequest:request response:response isRemove:NO callback:^{
                             NSString *serviceId = [request serviceId];
                             
                             // Register to Pebble.
                             [[DPPebbleManager sharedManager] registOnDownEvent:serviceId callback:^(NSError *error) {
                                 // Registration success.
                                 // Error check.
                                 [DPPebbleProfileUtil handleErrorNormal:error response:response];
                                 
                             } eventCallback:^(long attr, int keyId, int keyType) {
                                 // Create DConnect message
                                 DConnectMessage *message = [DConnectMessage message];
                                 [DConnectKeyEventProfile setId:keyId + [weakSelf getKeyTypeFlagValue:keyType] target:message];
                                 [DConnectKeyEventProfile setConfig:[weakSelf getConfig:keyType KeyCode:keyId] target:message];
                                 
                                 [weakSelf setKeyEventCache:(NSString *)DConnectKeyEventProfileAttrOnDown
                                               keyeventData:(DConnectMessage *)message];
                                 
                                 // Send event to DConnect.
                                 [DPPebbleProfileUtil sendMessageWithProvider:weakSelf.provider
                                                                      profile:DConnectKeyEventProfileName
                                                                    attribute:DConnectKeyEventProfileAttrOnDown
                                                                    serviceID:serviceId
                                                              messageCallback:^(DConnectMessage *eventMsg) {
                                                                  // Add message to event.
                                                                  [DConnectKeyEventProfile setKeyEvent:message target:eventMsg];
                                                              } deleteCallback:^ {
                                                                  // Remove Pebble of events.
                                                                  [[DPPebbleManager sharedManager] deleteOnDownEvent:serviceId callback:^(NSError *error) {
                                                                      if (error) NSLog(@"Error:%@", error);
                                                                  }];
                                                              }];
                             }];
                             
                             responseFlg = NO;
                         }];
                         
                         return responseFlg;
                     }];
        
        // API登録(didReceivePutOnUpRequest相当)
        NSString *putOnOnUpRequestApiPath = [self apiPathWithProfile: self.profileName
                                                       interfaceName: nil
                                                       attributeName: DConnectKeyEventProfileAttrOnUp];
        [self addPutPath: putOnOnUpRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         __block BOOL responseFlg = YES;
                         // Event registration.
                         [DPPebbleProfileUtil handleRequest:request response:response isRemove:NO callback:^{
                             NSString *serviceId = [request serviceId];
                             
                             // Register to Pebble.
                             [[DPPebbleManager sharedManager] registOnUpEvent:serviceId callback:^(NSError *error) {
                                 // Registration success.
                                 // Error check.
                                 [DPPebbleProfileUtil handleErrorNormal:error response:response];
                                 
                             } eventCallback:^(long attr, int keyId, int keyType) {
                                 // Create DConnect message
                                 DConnectMessage *message = [DConnectMessage message];
                                 [DConnectKeyEventProfile setId:keyId + [weakSelf getKeyTypeFlagValue:keyType] target:message];
                                 [DConnectKeyEventProfile setConfig:[weakSelf getConfig:keyType KeyCode:keyId] target:message];
                                 
                                 [weakSelf setKeyEventCache:(NSString *)DConnectKeyEventProfileAttrOnUp
                                               keyeventData:(DConnectMessage *)message];
                                 
                                 // Send event to DConnect.
                                 [DPPebbleProfileUtil sendMessageWithProvider:weakSelf.provider
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
                     }];
        
        // API登録(didReceiveDeleteOnDownRequest相当)
        NSString *deleteOnDownRequestApiPath = [self apiPathWithProfile: self.profileName
                                                          interfaceName: nil
                                                          attributeName: DConnectKeyEventProfileAttrOnDown];
        [self addPutPath: deleteOnDownRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // Remove event of DConnect.
                         [DPPebbleProfileUtil handleRequest:request response:response isRemove:YES callback:^{
                             // Remove event of Pebble.
                             [[DPPebbleManager sharedManager] deleteOnDownEvent:serviceId callback:^(NSError *error) {
                                 if (error) NSLog(@"Error:%@", error);
                             }];
                         }];
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnUpRequest相当)
        NSString *deleteOnOnUpRequestApiPath = [self apiPathWithProfile: self.profileName
                                                          interfaceName: nil
                                                          attributeName: DConnectKeyEventProfileAttrOnUp];
        [self addPutPath: deleteOnOnUpRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         // Remove event of DConnect.
                         [DPPebbleProfileUtil handleRequest:request response:response isRemove:YES callback:^{
                             NSString *serviceId = [request serviceId];
                             // Remove event of Pebble.
                             [[DPPebbleManager sharedManager] deleteOnUpEvent:serviceId callback:^(NSError *error) {
                                 if (error) NSLog(@"Error:%@", error);
                             }];
                         }];
                         return YES;
                     }];
        
    }
    return self;
    
}

/*!
 @brief Get KeyEvent cache data.
 @param attr Attribute.
 @return KeyEvent cache data.
 */
- (DConnectMessage *) getKeyEventCache:(NSString *)attr {
    UInt64 CurrentTime = (UInt64)floor((CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000.0);
    if ([attr isEqualToString:DConnectKeyEventProfileAttrOnDown]) {
        if (CurrentTime - mOnDownCacheTime <= CACHE_RETENTION_TIME) {
            return mOnDownCache;
        }
    } else if ([attr isEqualToString:DConnectKeyEventProfileAttrOnUp]
               && (CurrentTime - mOnUpCacheTime <= CACHE_RETENTION_TIME)) {
        return mOnUpCache;
    }
    return nil;
}

/*!
 @brief Set KeyEvent data to cache.
 @param attr Attribute.
 @param keyeventData Touch data.
 */
- (void) setKeyEventCache:(NSString *)attr
             keyeventData:(DConnectMessage *)keyeventData {
    UInt64 CurrentTime = (UInt64)floor((CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000.0);
    if ([attr isEqualToString:DConnectKeyEventProfileAttrOnDown]) {
        mOnDownCache = keyeventData;
        mOnDownCacheTime = CurrentTime;
    } else if ([attr isEqualToString:DConnectKeyEventProfileAttrOnUp]) {
        mOnUpCache = keyeventData;
        mOnUpCacheTime = CurrentTime;
    }
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

@end