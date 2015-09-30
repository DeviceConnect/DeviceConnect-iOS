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
        self.delegate = self;
    }
    return self;
    
}

- (void)dealloc {
    [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
}
#pragma mark - light
//Light GET ライトのリスト取得
- (BOOL) profile:(DConnectLightProfile *)profile didReceiveGetLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
{
    //Bridge Status Update
    [self initHueSdk:serviceId];
    __weak typeof(self) _self = self;
    
    _hueStatusBlock = ^(BridgeConnectState state){
        if (state != STATE_CONNECT) {
            [_self setErrRespose:response];
            [[DConnectManager sharedManager] sendResponse:response];
            return;
        }
        NSDictionary *lightList = [[DPHueManager sharedManager] getLightStatus];
        DConnectArray *lights = [DConnectArray array];
        
        for (PHLight *light in lightList.allValues) {
            
            //ライトの状態をメッセージにセットする（LightID,名前,点灯状態）
            DConnectMessage *led = [DConnectMessage new];
            [led setString:light.identifier forKey:DConnectLightProfileParamLightId];
            [led setString:light.name forKey:DConnectLightProfileParamName];
            
            [led setBool:[light.lightState.on boolValue] forKey:DConnectLightProfileParamOn];
            [lights addMessage:led];
        }
        [response setResult:DConnectMessageResultTypeOk];
        [response setArray:lights forKey:DConnectLightProfileParamLights];
        [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:_self];
        [[DPHueManager sharedManager] deallocHueSDK];
        [[DConnectManager sharedManager] sendResponse:response];
    };
    return NO;
}

//Light Post 点灯
- (BOOL) profile:(DConnectLightProfile *)profile
    didReceivePostLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
         lightId:(NSString*) lightId
      brightness:(NSNumber*)brightness
           color:(NSString*) color
        flashing:(NSArray*) flashing
{
    NSString* brightnessString = [request stringForKey:DConnectLightProfileParamBrightness];
    if (brightnessString
        && ![[DPHueManager sharedManager] isDigitWithString:brightnessString]) {
        [self setErrRespose:response];
        return YES;
    }
    return [self turnOnOffHueLightWithResponse:response
                                       lightId:lightId
                                          isOn:YES
                                    brightness:[brightness doubleValue]
                                         color:color];
}

//Light Delete 消灯
- (BOOL) profile:(DConnectLightProfile *)profile
didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         lightId:(NSString*) lightId
{
    return [self turnOnOffHueLightWithResponse:response lightId:lightId isOn:NO brightness:0 color:nil];
}





//Light Put 名前変更
- (BOOL) profile:(DConnectLightProfile *)profile didReceivePutLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         lightId:(NSString*) lightId
            name:(NSString *)name
      brightness:(NSNumber*)brightness
           color:(NSString*)color
        flashing:(NSArray*) flashing
{
    //nameが指定されてない場合はエラーで返す
    if (![[DPHueManager sharedManager] checkParamRequiredStringItemWithParam:name errorState:STATE_ERROR_NO_NAME]) {
        [self setErrRespose:response];
        return YES;
    }

    if (![[DPHueManager sharedManager] checkParamLightId:lightId]) {
        [self setErrRespose:response];
        return YES;
    }
    return [[DPHueManager sharedManager] changeLightNameWithLightId:lightId
                                                                  name:name
                                                                color:color
                                                         brightness:[brightness doubleValue]
                                                         completion:^{
                                                             [self setErrRespose:response];
                                                             [[DConnectManager sharedManager] sendResponse:response];
                                                         }];
    
}


#pragma mark - light group
//Light Group GET グループ一覧取得
- (BOOL)                   profile:(DConnectLightProfile *)profile
    didReceiveGetLightGroupRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
{
    [self initHueSdk:serviceId];
    __weak typeof(self) _self = self;
    _hueStatusBlock = ^(BridgeConnectState state){
        if (state != STATE_CONNECT) {
            [_self setErrRespose:response];
            [[DConnectManager sharedManager] sendResponse:response];
            return;
        }
        NSDictionary* groupList = [[DPHueManager sharedManager] getLightGroupStatus];
        NSDictionary* lightList = [[DPHueManager sharedManager] getLightStatus];

        DConnectArray *groups = [DConnectArray array];
        
        for (PHGroup *group in groupList.allValues) {
            
            DConnectMessage *groupResponse = [DConnectMessage new];
            [groupResponse setString:group.identifier forKey:DConnectLightProfileParamGroupId];
            if (group.name) {
                [groupResponse setString:group.name forKey:DConnectLightProfileParamName];
            } else {
                [groupResponse setString:@"" forKey:DConnectLightProfileParamName];
            }
            //キャッシュにあるライトの一覧からライトを取り出す
            NSArray *lightIds = group.lightIdentifiers;
            DConnectArray *lights = [DConnectArray array];
            for (PHLight *light in lightList.allValues) {
                for (NSString *lightId in lightIds) {
                    
                    if ([lightId isEqualToString:light.identifier]) {
                        
                        DConnectMessage *led = [DConnectMessage new];
                        [led setString:light.identifier forKey:DConnectLightProfileParamLightId];
                        [led setString:light.name forKey:DConnectLightProfileParamName];
                        
                        [led setBool:[light.lightState.on boolValue] forKey:DConnectLightProfileParamOn];
                        [lights addMessage:led];
                        
                    }
                }
            }
            
            [groupResponse setArray:lights forKey:DConnectLightProfileParamLights];
            [groups addMessage:groupResponse];
        }
        [response setResult:DConnectMessageResultTypeOk];
        [response setArray:groups forKey:DConnectLightProfileParamLightGroups];
        [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:_self];
        [[DPHueManager sharedManager] deallocHueSDK];
        [[DConnectManager sharedManager] sendResponse:response];
    };
    return NO;
}

//Light Group Post ライトグループ点灯
- (BOOL) profile:(DConnectLightProfile *)profile didReceivePostLightGroupRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         groupId:(NSString*)groupId
      brightness:(NSNumber*)brightness
           color:(NSString*)color
        flashing:(NSArray*)flashing
{
    NSString* brightnessString = [request stringForKey:DConnectLightProfileParamBrightness];
    if (brightnessString
        && ![[DPHueManager sharedManager] isDigitWithString:brightnessString]) {
        [self setErrRespose:response];
        return YES;
    }

    return [self turnOnOffHueLightGroupWithResponse:response
                                            groupId:groupId
                                               isOn:YES
                                         brightness:[brightness doubleValue]
                                              color:color];
}


//Light Group Delete ライトグループ消灯
- (BOOL) profile:(DConnectLightProfile *)profile didReceiveDeleteLightGroupRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         groupId:(NSString*)groupId
{
    return [self turnOnOffHueLightGroupWithResponse:response groupId:groupId isOn:NO brightness:0 color:nil];
}

//Light Group Put ライトグループ名称変更
- (BOOL) profile:(DConnectLightProfile *)profile didReceivePutLightGroupRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         groupId:(NSString*) groupId
            name:(NSString *)name
      brightness:(NSNumber*)brightness
           color:(NSString*)color
        flashing:(NSArray*)flashing
{
    
    //nameが指定されてない場合はエラーで返す
    if (![[DPHueManager sharedManager] checkParamRequiredStringItemWithParam:name errorState:STATE_ERROR_NO_NAME]) {
        [self setErrRespose:response];
        return YES;
    }
    
    //groupIdチェック
    if (![[DPHueManager sharedManager] checkParamGroupId:groupId]) {
        [self setErrRespose:response];
        return YES;
    }
    
    return [[DPHueManager sharedManager] changeGroupNameWithGroupId:groupId name:name completion:^{
        [self setErrRespose:response];
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    
}

//Light Group Post ライトグループ作成
- (BOOL) profile:(DConnectLightProfile *)profile didReceivePostLightGroupCreateRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
        lightIds:(NSArray*)lightIds
       groupName:(NSString*)groupName {
    BOOL result = [[DPHueManager sharedManager] createLightGroupWithLightIds:lightIds
                                                                   groupName:groupName
                                                                  completion:^(NSString* groupId) {
        if (groupId) {
            [response setString:groupId forKey:DConnectLightProfileParamGroupId];
            [DPHueManager sharedManager].bridgeConnectState = STATE_CONNECT;
        } else {
            [DPHueManager sharedManager].bridgeConnectState = STATE_ERROR_CREATE_FAIL_GROUP;
        }
        [self setErrRespose:response];
        [[DConnectManager sharedManager] sendResponse:response];

    }];
    [response setResult:DConnectMessageResultTypeError];
    [self setErrRespose:response];
    return result;
}



//Light Group Delete ライトグループ削除
- (BOOL) profile:(DConnectLightProfile *)profile didReceiveDeleteLightGroupClearRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         groupId:(NSString*)groupId
{
    BOOL result = [[DPHueManager sharedManager] removeLightGroupWithWithGroupId:groupId completion:^{
        [self setErrRespose:response];
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    [response setResult:DConnectMessageResultTypeError];
    [self setErrRespose:response];
    return result;    
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
                                                                    macAddress:macAdr
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
                          brightness:(double)brightness
                               color:(NSString*)color
{
    if (![[DPHueManager sharedManager] checkParamLightId:lightId]) {
        [self setErrRespose:response];
        return YES;
    }
    if (brightness < 0 || brightness > 1) {
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
                                                           completion:^ {
                                                               [self setErrRespose:response];
                                                               [[DConnectManager sharedManager] sendResponse:response];
                                                           }];
}

//ライトグループのON/OFF
-(BOOL)turnOnOffHueLightGroupWithResponse:(DConnectResponseMessage*)response
                                  groupId:(NSString*)groupId
                                     isOn:(BOOL)isOn
                               brightness:(double)brightness
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
