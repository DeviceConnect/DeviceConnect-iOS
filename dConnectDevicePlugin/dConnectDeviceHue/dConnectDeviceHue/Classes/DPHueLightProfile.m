//
//  DPHueLightProfile.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueLightProfile.h"
#import <HueSDK_iOS/HueSDK.h>

@interface DPHueLightProfile()
@property (nonatomic) id hueStatusBlock;

@end
@implementation DPHueLightProfile



- (id)init
{
    self = [super init];
    if (self) {
        
        __weak DPHueLightProfile *weakSelf = self;
        
        // API登録(didReceiveGetLightRequest相当)
        NSString *getLightRequestApiPath = [self apiPath: nil
                                           attributeName: nil];
        [self addGetPath: getLightRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         if (!serviceId) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }

                         //Bridge Status Update
                         [weakSelf initHueSdk:serviceId];
                         
                         _hueStatusBlock = ^(BridgeConnectState state){
                             if (state != STATE_CONNECT) {
                                 [weakSelf setErrRespose:response];
                                 [[DConnectManager sharedManager] sendResponse:response];
                                 return;
                             }
                             NSDictionary *lightList = [[DPHueManager sharedManager] getLightStatus];
                             DConnectArray *lights = [DConnectArray array];
                             
                             for (PHLight *light in lightList.allValues) {
                                 
                                 //ライトの状態をメッセージにセットする（LightID,名前,点灯状態）
                                 DConnectMessage *led = [DConnectMessage new];
                                 [DConnectLightProfile setLightId:light.identifier target:led];
                                 [DConnectLightProfile setLightName:light.name target:led];
                                 [DConnectLightProfile setLightOn:[light.lightState.on boolValue] target:led];
                                 [DConnectLightProfile setLightConfig:@"" target:led];
                                 
                                 [lights addMessage:led];
                             }
                             [response setResult:DConnectMessageResultTypeOk];
                             [DConnectLightProfile setLights:lights target:response];
                             [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:weakSelf];
                             [[DPHueManager sharedManager] deallocHueSDK];
                             [[DConnectManager sharedManager] sendResponse:response];
                         };
                         return NO;
                     }];
        
        // API登録(didReceivePostLightRequest相当)
        NSString *postLightRequestApiPath = [self apiPath: nil
                                            attributeName: nil];
        [self addPostPath: postLightRequestApiPath
                      api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *serviceId = [request serviceId];
                          NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                          NSNumber *brightness = [DConnectLightProfile brightnessFromRequest: request];
                          NSString *color = [DConnectLightProfile colorFromRequest: request];
                          NSArray *flashing = [DConnectLightProfile parsePattern: [DConnectLightProfile flashingFromRequest: request] isId:NO];
                          
                          if (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0)) {
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"Parameter 'brightness' must be a value between 0 and 1.0."];
                              return YES;
                          }
                          
                          if (!flashing) {
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"Parameter 'flashing' invalid."];
                              return YES;
                          }
                          if (![weakSelf checkFlash:response flashing:flashing]) {
                              return YES;
                          }
                          
                          if (!serviceId) {
                              [response setErrorToEmptyServiceId];
                              return YES;
                          }
                          
                          NSString* brightnessString = [request stringForKey:DConnectLightProfileParamBrightness];
                          if (brightnessString
                              && ![[DPHueManager sharedManager] isDigitWithString:brightnessString]) {
                              [weakSelf setErrRespose:response];
                              return YES;
                          }
                          return [weakSelf turnOnOffHueLightWithResponse:response
                                                             lightId:lightId
                                                                isOn:YES
                                                          brightness:brightness
                                                            flashing:flashing
                                                               color:color];
                      }];
        
        // API登録(didReceivePutLightRequest相当)
        NSString *putLightRequestApiPath = [self apiPath: nil
                                           attributeName: nil];
        [self addPutPath: putLightRequestApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                         NSNumber *brightness = [DConnectLightProfile brightnessFromRequest: request];
                         if (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0)) {
                             [response setErrorToInvalidRequestParameterWithMessage:
                              @"Parameter 'brightness' must be a value between 0 and 1.0."];
                             return YES;
                         }
                         NSString *name = [request stringForKey:DConnectLightProfileParamName];
                         NSString *color = [request stringForKey:DConnectLightProfileParamColor];
                         NSArray *flashing = [DConnectLightProfile parsePattern: [DConnectLightProfile flashingFromRequest: request] isId:NO];
                         if (!flashing) {
                             [response setErrorToInvalidRequestParameterWithMessage:
                              @"Parameter 'flashing' invalid."];
                             return YES;
                         }
                         if (![weakSelf checkFlash:response flashing:flashing]) {
                             return YES;
                         }
                         
                         if (!serviceId) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }
                         
                         //nameが指定されてない場合はエラーで返す
                         if (![[DPHueManager sharedManager] checkParamRequiredStringItemWithParam:name errorState:STATE_ERROR_NO_NAME]) {
                             [weakSelf setErrRespose:response];
                             return YES;
                         }
                         
                         if (![[DPHueManager sharedManager] checkParamLightId:lightId]) {
                             [weakSelf setErrRespose:response];
                             return YES;
                         }
                         return [[DPHueManager sharedManager] changeLightNameWithLightId:lightId
                                                                                    name:name
                                                                                   color:color
                                                                              brightness:brightness
                                                                                flashing:flashing
                                                                              completion:^{
                                                                                  [weakSelf setErrRespose:response];
                                                                                  [[DConnectManager sharedManager] sendResponse:response];
                                                                              }];
                     }];
        
        // API登録(didReceiveDeleteLightRequest相当)
        NSString *deleteLightRequestApiPath = [self apiPath: nil
                                              attributeName: nil];
        [self addDeletePath: deleteLightRequestApiPath
                        api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                            
                            if (!serviceId) {
                                [response setErrorToEmptyServiceId];
                                return YES;
                            }
                            return [weakSelf turnOnOffHueLightWithResponse:response lightId:lightId isOn:NO brightness:[NSNumber numberWithDouble:0]  flashing:nil color:nil];
                        }];
    }
    return self;
    
}

- (void)dealloc {
    [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
}







#pragma mark - private method

//Hue SDKの初期化
- (void)initHueSdk:(NSString*)serviceId
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSArray *arr = [serviceId componentsSeparatedByString:@"_"];
        if(arr.count > 1) {
            NSString * ipAdr =  arr[0];
            NSString * macAdr = arr[1];
            [[DPHueManager sharedManager] initHue];
            [[DPHueManager sharedManager] startAuthenticateBridgeWithIpAddress:ipAdr
                                                                    bridgeId:macAdr
                                                                      receiver:self
                                                localConnectionSuccessSelector:@selector(willLocalConnectionSuccess)
                                                             noLocalConnection:@selector(willNoLocalConnection)
                                                              notAuthenticated:@selector(willNotAuthenticated)];
        }
        [DPHueManager sharedManager].bridgeConnectState = STATE_INIT;
    });
}
//接続した時のイベント
- (void)willLocalConnectionSuccess {
    [DPHueManager sharedManager].bridgeConnectState = STATE_CONNECT;
    DPHueLightStatusBlock block = _hueStatusBlock;
    if (block) {
        block(STATE_CONNECT);
        _hueStatusBlock = nil;
    }
}

//接続が切れた場合のイベント
- (void)willNoLocalConnection {
    [DPHueManager sharedManager].bridgeConnectState = STATE_NON_CONNECT;
    DPHueLightStatusBlock block = _hueStatusBlock;
    if (block) {
        block(STATE_NON_CONNECT);
        _hueStatusBlock = nil;
    }
}

//アプリ登録がHueのブリッジに行われていない場合のイベント
- (void)willNotAuthenticated {
    [DPHueManager sharedManager].bridgeConnectState = STATE_NOT_AUTHENTICATED;
    DPHueLightStatusBlock block = _hueStatusBlock;
    if (block) {
        block(STATE_NOT_AUTHENTICATED);
        _hueStatusBlock = nil;
    }
}

//ライトのON/OFF
- (BOOL)turnOnOffHueLightWithResponse:(DConnectResponseMessage*)response
                              lightId:(NSString*)lightId
                                isOn:(BOOL)isOn
                          brightness:(NSNumber *)brightness
                             flashing:(NSArray*)flashing
                               color:(NSString*)color
{
    if (![[DPHueManager sharedManager] checkParamLightId:lightId]) {
        [self setErrRespose:response];
        return YES;
    }
    if (brightness && ([brightness doubleValue] < 0 || [brightness doubleValue] > 1)) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid brightness value."];
        return YES;
    }
    PHLightState *lightState = [[DPHueManager sharedManager] getLightStateIsOn:isOn brightness:brightness color:color];
    if (lightState == nil) {
        [self setErrRespose:response];
        return YES;
    }
    return [[DPHueManager sharedManager] changeLightStatusWithLightId:lightId
                                                           lightState:lightState
                                                             flashing:flashing
                                                           completion:^ {
                                                               [self setErrRespose:response];
                                                               [[DConnectManager sharedManager] sendResponse:response];
                                                           }];
}

//ライトグループのON/OFF
-(BOOL)turnOnOffHueLightGroupWithResponse:(DConnectResponseMessage*)response
                                  groupId:(NSString*)groupId
                                     isOn:(BOOL)isOn
                               brightness:(NSNumber *)brightness
                                    color:(NSString*)color
{
    //groupIdチェック
    if (![[DPHueManager sharedManager] checkParamGroupId:groupId]) {
        [self setErrRespose:response];
        return YES;
    }
    PHLightState *lightState = [[DPHueManager sharedManager] getLightStateIsOn:isOn brightness:brightness color:color];
    if (lightState == nil) {
        [self setErrRespose:response];
        return YES;
    }
    return [[DPHueManager sharedManager] changeGroupStatusWithGroupId:groupId lightState:lightState completion:^{
        [self setErrRespose:response];
        [[DConnectManager sharedManager] sendResponse:response];
        
    }];
}

//エラーの振り分け
- (void) setErrRespose:(DConnectResponseMessage *)response {
    
    switch ([DPHueManager sharedManager].bridgeConnectState) {
        case STATE_INIT:
            [response setErrorToNotFoundServiceWithMessage:@"Not the response from the hue"];
            break;
        case STATE_NON_CONNECT:
            [response setErrorToNotFoundServiceWithMessage:@"Bridge not found"];
            break;
        case STATE_NOT_AUTHENTICATED:
            [response setErrorToNotFoundServiceWithMessage:
                @"It is not application registration, please register from the app settings screen"];
            break;
        case STATE_ERROR_NO_NAME:
            [response setErrorToInvalidRequestParameterWithMessage:@"Name after the change has not been specified"];
            break;
        case STATE_ERROR_NO_LIGHTID:
             [response setErrorToInvalidRequestParameterWithMessage:@"lightIds must be specified"];
            break;
        case STATE_ERROR_INVALID_LIGHTID:
            [response setErrorToInvalidRequestParameterWithMessage:@"lightIds is invalid"];
            break;
        case STATE_ERROR_INVALID_BRIGHTNESS:
            [response setErrorToInvalidRequestParameterWithMessage:@"brightness is invalid"];
            break;
        case STATE_ERROR_LIMIT_GROUP:
            [response setErrorToNotSupportProfileWithMessage:
                @"Hue has reached the upper limit to which the group can create"];
            break;
        case STATE_ERROR_CREATE_FAIL_GROUP:
            [response setErrorToUnknownWithMessage:@"Failed to create a group"];
            break;
        case STATE_ERROR_DELETE_FAIL_GROUP:
            [response setErrorToUnknownWithMessage:@"Failed to delete the group"];
            break;
        case STATE_ERROR_NOT_FOUND_LIGHT:
            [response setErrorToInvalidRequestParameterWithMessage:@"light not found"];
            break;
        case STATE_ERROR_NO_GROUPID:
            [response setErrorToInvalidRequestParameterWithMessage:@"groupId must be specified"];
            break;
        case STATE_ERROR_NOT_FOUND_GROUP:
            [response setErrorToInvalidRequestParameterWithMessage:@"group not found"];
            break;
        case STATE_ERROR_INVALID_COLOR:
            [response setErrorToInvalidRequestParameterWithMessage:@"color is invalid"];
            break;
        case STATE_ERROR_UPDATE_FAIL_LIGHT_STATE:
             [response setErrorToUnknownWithMessage:@"Failed to update the state of the light"];
            break;
        case STATE_ERROR_CHANGE_FAIL_LIGHT_NAME:
            [response setErrorToUnknownWithMessage:@"Failed to change the name of the light"];
            break;
        case STATE_ERROR_UPDATE_FAIL_GROUP_STATE:
            [response setErrorToUnknownWithMessage:@"Failed to update the state of the light group"];
            break;
        case STATE_ERROR_CHANGE_FAIL_GROUP_NAME:
            [response setErrorToUnknownWithMessage:@"Failed to change the name of the light group"];
            break;
        case STATE_CONNECT:
            [response setResult:DConnectMessageResultTypeOk];
            break;
        default:
            [response setErrorToUnknown];
            break;
    }
}

@end
