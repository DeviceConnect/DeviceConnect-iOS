//
//  DPHueConst.h
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueManager.h"
#import "DPHueService.h"
#import "DPHueReachability.h"

@interface DPHueManager()

@property (nonatomic, strong) DPHueReachability *reachability;

@end


@implementation DPHueManager
//見つけたブリッジのリスト
NSString *const DPHueBridgeListName = @"org.deviceconnect.ios.DPHue.ip";

// 共有インスタンス
+ (instancetype)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceHueToken;
    dispatch_once(&onceHueToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// 初期化
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initHue];
    }
    return self;
}

//HueSDKの初期化
-(void)initHue
{
    if (!phHueSDK) {
        phHueSDK = [[PHHueSDK alloc] init];
        [phHueSDK startUpSDK];
        [phHueSDK enableLogging:NO];
        bridgeSearching = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:NO];
    }
    
    // Reachabilityの初期処理
    self.reachability = [DPHueReachability reachabilityWithHostName: @"www.google.com"];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notifiedNetworkStatus:)
     name:DPHueReachabilityChangedNotification
     object:nil];
    [self.reachability startNotifier];
}

// ServiceProviderを登録
- (void)setServiceProvider: (DConnectServiceProvider *) serviceProvider {
    self.mServiceProvider = serviceProvider;
}

//ブリッジ検索
-(void)searchBridgeWithCompletion:(PHBridgeSearchCompletionHandler)completion
{
    [bridgeSearching startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        _hueBridgeList = bridgesFound;
        if (completion) {
            completion(bridgesFound);
        }
        [self updateManageServices: YES];
    }];
}

//ブリッジへの認証依頼
-(void)startAuthenticateBridgeWithIpAddress:(NSString*)ipAddress
                                        macAddress:(NSString*)macAddress
                                          receiver:(id)receiver
                    localConnectionSuccessSelector:(SEL)localConnectionSuccessSelector
                                 noLocalConnection:(SEL)noLocalConnection
                                  notAuthenticated:(SEL)notAuthenticated
{
    id registerReceiver = receiver;
    if (!registerReceiver) {
        registerReceiver = self;
    }
    // Register for notifications about pushlinking
    notificationManager = [PHNotificationManager defaultManager];
    if (localConnectionSuccessSelector) {
        //接続成功
        [notificationManager registerObject:registerReceiver
                               withSelector:localConnectionSuccessSelector
                            forNotification:LOCAL_CONNECTION_NOTIFICATION];
    }
    if (noLocalConnection) {
        //ブリッジに接続できません
        [notificationManager registerObject:registerReceiver withSelector:noLocalConnection forNotification:
         NO_LOCAL_CONNECTION_NOTIFICATION];
    }
    if (notAuthenticated) {
        //未認証
        [notificationManager registerObject:registerReceiver withSelector:notAuthenticated forNotification:
         NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    }
    if ((ipAddress != nil) && (macAddress != nil)) {
        [phHueSDK setBridgeToUseWithIpAddress:ipAddress macAddress:macAddress];
    }
    [self enableHeartbeat];
}

//Pushlinkの確認開始
-(void)     startPushlinkWithReceiver:(id)receiver
pushlinkAuthenticationSuccessSelector:(SEL)pushlinkAuthenticationSuccessSelector
 pushlinkAuthenticationFailedSelector:(SEL)pushlinkAuthenticationFailedSelector
    pushlinkNoLocalConnectionSelector:(SEL)pushlinkNoLocalConnectionSelector
        pushlinkNoLocalBridgeSelector:(SEL)pushlinkNoLocalBridgeSelector
     pushlinkButtonNotPressedSelector:(SEL)pushlinkButtonNotPressedSelector
{
    
    id registerReceiver = receiver;
    if (!registerReceiver) {
        registerReceiver = self;
    }

    notificationManager = [PHNotificationManager defaultManager];
    if (pushlinkAuthenticationSuccessSelector) {
        //PUSHLINK認証成功
        [notificationManager registerObject:registerReceiver
                               withSelector:pushlinkAuthenticationSuccessSelector
                            forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    }
    if (pushlinkAuthenticationFailedSelector) {
        //PUSHLINK認証失敗
        [notificationManager registerObject:registerReceiver
                               withSelector:pushlinkAuthenticationFailedSelector
                            forNotification:PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION];
    }
    if (pushlinkNoLocalConnectionSelector) {
        //PUSHLINKブリッジに接続できない
        [notificationManager registerObject:registerReceiver
                               withSelector:pushlinkNoLocalConnectionSelector
                            forNotification:PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION];
    }
    if (pushlinkNoLocalBridgeSelector) {
        //PUSHLINKブリッジが見つからない
        [notificationManager registerObject:registerReceiver
                               withSelector:pushlinkNoLocalBridgeSelector
                            forNotification:PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION];
    }
    if (pushlinkButtonNotPressedSelector) {
        //PUSHLINKブリッジのボタンが押されていない
        [notificationManager registerObject:registerReceiver
                               withSelector:pushlinkButtonNotPressedSelector
                            forNotification:PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION];
    }
    [phHueSDK startPushlinkAuthentication];
}

//ライトステータスの取得
-(NSDictionary *)getLightStatus
{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    return cache.lights;
}

//ライトの点灯
-(BOOL)setLightOnWithResponse:(DConnectResponseMessage*)response
                      lightId:(NSString*)lightId
                   brightness:(double)brightness
                        color:(NSString*)color
{
    
    return YES;
}

//ライトの消灯
-(BOOL)setLightOffWithResponse:(DConnectResponseMessage*)response
                       lightId:(NSString*)lightId
{
    [self getLightStateIsOn:NO brightness:0 color:nil];
    return YES;
}

//ライトの名前変更
-(BOOL)changeLightNamewithResponse:(DConnectResponseMessage*)response
                           lightId:(NSString*)lightId
                              name:(NSString*)name
{
    //nameが指定されてない場合はエラーで返す
    if (![self checkParamRequiredStringItemWithParam:name errorState:STATE_ERROR_NO_NAME]) {
        return YES;
    }
    //LightIdチェック
    if (![self checkParamLightId:lightId]) {
        return YES;
    }
    
    return YES;//[self changeLightName:response lightId:lightId name:name];
   
}


//ライトグループステータスの取得
-(NSDictionary*)getLightGroupStatus
{
    //キャッシュにあるグループの一覧からグループを取り出す
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    return cache.groups;
}

//ライトグループの点灯
-(BOOL)setLightGroupOnWithResponse:(DConnectResponseMessage*)response
                           groupId:(NSString*)groupId
                        brightness:(NSNumber *)brightness
                             color:(NSString*)color
{
    //groupIdチェック
    if (![self checkParamGroupId:groupId]) {
        return YES;
    }
    
    PHLightState *lightState = [self getLightStateIsOn:YES brightness:brightness color:color];
    if (lightState == nil) {
        return YES;
    }

    return YES;//[self changeGroupStatus:response groupId:groupId lightState:lightState];
}

//ライトグループの消灯
-(BOOL)setLightGroupOffWithResponse:(DConnectResponseMessage*)response
                            groupId:(NSString*)groupId
{
    //groupIdチェック
    if (![self checkParamGroupId:groupId]) {
        return YES;
    }
    
    //lightState取得
    PHLightState *lightState = [self getLightStateIsOn:NO brightness:0 color:nil];
    
    //lightStateがnilならエラーなので終了
    if (lightState == nil) {
        return YES;
    }
    
    return YES;//[self changeGroupStatus:response groupId:groupId lightState:lightState];
}

//ライトグループ名の変更
-(BOOL)changeLightGroupNameWithResponse:(DConnectResponseMessage*)response
                                groupId:(NSString*)groupId
                                   name:(NSString*)name
{
    //nameが指定されてない場合はエラーで返す
    if (![self checkParamRequiredStringItemWithParam:name errorState:STATE_ERROR_NO_NAME]) {
        return YES;
    }
    
    //groupIdチェック
    if (![self checkParamGroupId:groupId]) {
        return YES;
    }
    
    return YES;//[self changeGroupName:response groupId:groupId name:name];
    
}

//ライトグループの作成
-(BOOL)createLightGroupWithLightIds:(NSArray*)lightIds
                          groupName:(NSString*)groupName
                         completion:(void(^)(NSString* groupId))completion
{
    if (!groupName) {
        _bridgeConnectState = STATE_ERROR_NO_NAME;
        return YES;
    }
    
    if (lightIds.count <= 0) {
        _bridgeConnectState = STATE_ERROR_NO_LIGHTID;
        return YES;
    }
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    //lightIdでArrayを作る
    NSMutableDictionary *lightArray = [NSMutableDictionary dictionary];
    
    for (PHLight *light in cache.lights.allValues) {
        for (NSString *lightId in lightIds) {
            if ([lightId isEqualToString:light.identifier]) {
                lightArray[light.identifier] = light;
            }
        }
    }
    
    //ID Listエラーチェック
    if (lightArray.count <= 0) {
        _bridgeConnectState = STATE_ERROR_INVALID_LIGHTID;
        return YES;
    }
    
    //限界チェック
    if (cache.groups.count >= 16) {
        _bridgeConnectState = STATE_ERROR_LIMIT_GROUP;
        return YES;
    }
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    //メインスレッドで動作させる
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [bridgeSendAPI createGroupWithName:groupName
                                  lightIds:[lightArray allKeys]
                         completionHandler:^(NSString *groupIdentifier, NSArray *errors) {
            if (errors != nil) {
                _bridgeConnectState = STATE_ERROR_CREATE_FAIL_GROUP;
            } else {
                _bridgeConnectState = STATE_CONNECT;
            }
            if (completion) {
                completion(groupIdentifier);
            }
        }];
    });
    return NO;
    
}

//ライトグループの削除
-(BOOL)removeLightGroupWithWithGroupId:(NSString*)groupId
                            completion:(void(^)())completion
{
    //groupIdチェック
    if (![self checkParamGroupId:groupId]) {
        return YES;
    }
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [bridgeSendAPI removeGroupWithId:groupId completionHandler:^(NSArray *errors) {
            [self setCompletionWithResponseCompletion:completion errors:errors
                           errorState:STATE_ERROR_DELETE_FAIL_GROUP];
            
        }];
    });
    return NO;
}



//使用できるライトの検索
-(void)searchLightWithCompletion:(PHBridgeSendErrorArrayCompletionHandler)completion {
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI searchForNewLights:completion];
}


//Serialを指定してライトを登録する
-(void)registerLightForSerialNo:(NSArray*)serialNos
                     completion:
(PHBridgeSendErrorArrayCompletionHandler)completion
{
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI searchForNewLightsWithSerials:serialNos completionHandler:completion];
    
}


//ハートビートの有効化
-(void)enableHeartbeat {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        [phHueSDK enableLocalConnection];
    } else {
        [phHueSDK disableLocalConnection];
        [self searchBridgeWithCompletion:nil];
    }
}

//ハートビートの無効化
-(void)disableHeartbeat {
    [phHueSDK disableLocalConnection];
}

//PHNotificationManagerの解放
-(void)deallocPHNotificationManagerWithReceiver:(id)receiver {
    id registerReceiver = receiver;
    if (!registerReceiver) {
        registerReceiver = self;
    }

    if (notificationManager) {
        [notificationManager deregisterObjectForAllNotifications:registerReceiver];
        [notificationManager deregisterObject:registerReceiver forNotification:LOCAL_CONNECTION_NOTIFICATION];
        [notificationManager deregisterObject:registerReceiver forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
        [notificationManager deregisterObject:registerReceiver forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
        notificationManager = nil;
    }
}

//HueSDKの解放
-(void)deallocHueSDK {
    if (phHueSDK != nil) {
        [phHueSDK disableLocalConnection];
        [phHueSDK stopSDK];
        phHueSDK = nil;
    }
}

#pragma mark - private method

//completionHandlerの共通処理
- (void) setCompletionWithResponseCompletion:(void(^)())completion
                        errors:(NSArray*)errors
                  errorState:(BridgeConnectState)errorState
{
    if (errors != nil) {
        _bridgeConnectState = errorState;
    } else {
        _bridgeConnectState = STATE_CONNECT;
    }
    if (completion) {
        completion();
    }
}


//パラメータチェック LightId
- (BOOL)checkParamLightId:(NSString*)lightId
{
    //LightIdが指定されてない場合はエラーで返す
    if (!lightId) {
        _bridgeConnectState = STATE_ERROR_NO_LIGHTID;
        return NO;
    }
    
    //キャッシュにあるライトの一覧からライトを取り出す
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    for (PHLight *light in cache.lights.allValues) {
        if ([lightId isEqualToString:light.identifier]) {
            return YES;
        }
    }
    _bridgeConnectState = STATE_ERROR_NOT_FOUND_LIGHT;
    return NO;
}

//パラメータチェック groupId
- (BOOL)checkParamGroupId:(NSString*)groupId
{
    //groupIdが指定されてない場合はエラーで返す
    if (!groupId) {
        _bridgeConnectState = STATE_ERROR_NO_GROUPID;
        return NO;
    }
    if ([groupId isEqualToString:@"0"]) {
        _bridgeConnectState = STATE_ERROR_NO_GROUPID;
        
        return YES;
    }
    
    //キャッシュにあるグループの一覧からグループを取り出す
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    for (PHGroup *group in cache.groups.allValues) {
        if ([groupId isEqualToString:group.identifier]) {
            return YES;
        }
    }
    
    _bridgeConnectState = STATE_ERROR_NOT_FOUND_GROUP;
    return NO;
}

//パラメータチェック 必須文字チェック
- (BOOL)checkParamRequiredStringItemWithParam:(NSString*)param
                        errorState:(BridgeConnectState)errorState
{
    
    //valueが指定されてない場合はエラーで返す
    if (param == nil) {
        _bridgeConnectState = errorState;
        return NO;
    }
    if (param.length == 0) {
        _bridgeConnectState = errorState;
        return NO;
    }
    
    return YES;
}


- (void)checkColor:(double)dBlightness blueValue:(unsigned int)blueValue greenValue:(unsigned int)greenValue redValue:(unsigned int)redValue color:(NSString *)color myBlightnessPointer:(int *)myBlightnessPointer uicolorPointer:(NSString **)uicolorPointer
{
    NSScanner *scan;
    NSString *blueString;
    NSString *greenString;
    NSString *redString;
    if (color) {
        if (color.length != 6) {
            _bridgeConnectState = STATE_ERROR_INVALID_COLOR;
            return;
        }
        
        redString = [color substringWithRange:NSMakeRange(0, 2)];
        greenString = [color substringWithRange:NSMakeRange(2, 2)];
        blueString = [color substringWithRange:NSMakeRange(4, 2)];
        scan = [NSScanner scannerWithString:redString];
        if (![scan scanHexInt:&redValue]) {
            _bridgeConnectState = STATE_ERROR_INVALID_COLOR;
            return;
        }
        scan = [NSScanner scannerWithString:greenString];
        if (![scan scanHexInt:&greenValue]) {
            _bridgeConnectState = STATE_ERROR_INVALID_COLOR;
            return;
        }
        scan = [NSScanner scannerWithString:blueString];
        if (![scan scanHexInt:&blueValue]) {
            _bridgeConnectState = STATE_ERROR_INVALID_COLOR;
            return;
        }
        
        redValue = (unsigned int)round(redValue * dBlightness);
        greenValue = (unsigned int)round(greenValue * dBlightness);
        blueValue = (unsigned int)round(blueValue * dBlightness);
    }else{
        redValue = (unsigned int)round(255 * dBlightness);
        greenValue = (unsigned int)round(255 * dBlightness);
        blueValue = (unsigned int)round(255 * dBlightness);
    }
    
    *myBlightnessPointer = MAX(redValue, greenValue);
    *myBlightnessPointer = MAX(*myBlightnessPointer, blueValue);
    *uicolorPointer = [NSString stringWithFormat:@"%02X%02X%02X",redValue, greenValue, blueValue];
}

//エラーの場合、エラー情報をresponseに設定しnilをreturn
- (PHLightState*) getLightStateIsOn:(BOOL)isOn
                     brightness:(NSNumber *)brightness
                          color:(NSString *)color
{
    PHLightState *lightState = [[PHLightState alloc] init];

    [lightState setOnBool:isOn];

    if (isOn) {
        double dBlightness = 0;

        if (!brightness ||
            [brightness doubleValue] == DBL_MIN ||
            ([brightness doubleValue] != DBL_MIN && [brightness doubleValue] > 1.0) ||
            ([brightness doubleValue] != DBL_MIN && [brightness doubleValue] < 0.0) ) {
            dBlightness = 1.0;
        } else {
            dBlightness = [brightness doubleValue];
        }
        unsigned int redValue, greenValue, blueValue;

        int myBlightness;
        NSString *uicolor;
        [self checkColor:dBlightness blueValue:blueValue greenValue:greenValue redValue:redValue color:color myBlightnessPointer:&myBlightness uicolorPointer:&uicolor];

        CGPoint xyPoint = [self convRgbToXy:uicolor];
        if (xyPoint.x != FLT_MIN && xyPoint.y != FLT_MIN) {
            [lightState setX:[NSNumber numberWithFloat:xyPoint.x]];
            [lightState setY:[NSNumber numberWithFloat:xyPoint.y]];
        } else {
            _bridgeConnectState = STATE_ERROR_INVALID_COLOR;
            return nil;
        }

        if (myBlightness < 1) {
            myBlightness = 1;
        }
        if (myBlightness > 254) {
            myBlightness = 254;
        }
        [lightState setBrightness:[NSNumber numberWithInt:(int)myBlightness]];
    }

    return lightState;
}

/*!
 Lightのステータスチェンジ
 */
- (BOOL) changeLightStatusWithLightId:(NSString *)lightId
                           lightState:(PHLightState*)lightState
                             flashing:(NSArray*)flashing
                           completion:(void(^)())completion
{
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    //メインスレッドで動作させる
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (flashing && flashing.count > 0) {
            PHLightState* offState = [self getLightStateIsOn:NO brightness:0 color:nil];
            [self setCompletionWithResponseCompletion:completion
                                               errors:nil
                                           errorState:STATE_ERROR_UPDATE_FAIL_LIGHT_STATE];

            for (int i = 0; i < flashing.count; i++) {
                int delay = [flashing[i] intValue];
                if (i % 2 == 0) {
                    [bridgeSendAPI updateLightStateForId:lightId withLightState:lightState completionHandler:^(NSArray *errors) {
                        
                        
                    }];
                    sleep(delay / 1000);
                } else {
                    [bridgeSendAPI updateLightStateForId:lightId withLightState:offState completionHandler:^(NSArray *errors) {
                        
                        
                    }];
                    sleep(delay / 1000);
                }
            }
        } else {
            [bridgeSendAPI updateLightStateForId:lightId withLightState:lightState completionHandler:^(NSArray *errors) {
                
                [self setCompletionWithResponseCompletion:completion
                                                   errors:errors
                                               errorState:STATE_ERROR_UPDATE_FAIL_LIGHT_STATE];
                
            }];

        }
    });
    
    return NO;
}

/*
 Lightの名前チェンジ
 */
-(BOOL)changeLightNameWithLightId:(NSString *)lightId
                             name:(NSString *)name
                            color:(NSString *)color
                       brightness:(NSNumber *)brightness
                         flashing:(NSArray*)flashing
                       completion:(void(^)())completion
{
    unsigned int redValue, greenValue, blueValue;

    // 省略時はMax値(1.0)を設定する
    double brightness_ = 1;
    if (brightness) {
        brightness_ = [brightness doubleValue];
    }
    
    int myBlightness;
    NSString *uicolor;
    [self checkColor:brightness_ blueValue:blueValue greenValue:greenValue
            redValue:redValue color:color myBlightnessPointer:&myBlightness uicolorPointer:&uicolor];

    if (!uicolor) {
        [self setCompletionWithResponseCompletion:completion
                                           errors:[NSArray array]
                                       errorState:STATE_ERROR_INVALID_COLOR];
        return NO;
    }
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    //メインスレッドで動作させる
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 500);
    PHLightState* onState = [self getLightStateIsOn:YES brightness:brightness color:color];
    [self changeLightStatusWithLightId:lightId
                            lightState:onState flashing:flashing completion:^(NSArray *errors) {
                                
//                                [self setCompletionWithResponseCompletion:completion
//                                                                   errors:errors
//                                                               errorState:STATE_ERROR_CHANGE_FAIL_LIGHT_NAME];
                                                    dispatch_semaphore_signal(semaphore);
                            }];
    dispatch_semaphore_wait(semaphore, timeout);

    dispatch_sync(dispatch_get_main_queue(), ^{
        
        for (PHLight *light in cache.lights.allValues) {
            if ([light.identifier isEqualToString:lightId]) {
                
                [light setName:name];
                
                [bridgeSendAPI updateLightWithLight:light completionHandler:^(NSArray *errors) {
                    
                    [self setCompletionWithResponseCompletion:completion
                                         errors:errors
                                   errorState:STATE_ERROR_CHANGE_FAIL_LIGHT_NAME];
                }];
                
                break;
            }
        }
    });
    return NO;
}

/*!
 LightGroupのステータスチェンジ
 */
- (BOOL)changeGroupStatusWithGroupId:(NSString *)groupId
                          lightState:(PHLightState*)lightState
                          completion:(void(^)())completion
{
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    //メインスレッドで動作させる
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        // Send lightstate to light
        [bridgeSendAPI setLightStateForGroupWithId:groupId lightState:lightState completionHandler:^(NSArray *errors) {
            
            [self setCompletionWithResponseCompletion:completion
                                 errors:errors
                           errorState:STATE_ERROR_UPDATE_FAIL_GROUP_STATE];
            
        }];
    });
    
    return NO;
}

/*!
 LightGroupのnameチェンジ
 */
- (BOOL) changeGroupNameWithGroupId:(NSString *)groupId
                               name:(NSString *)name
                         completion:(void(^)())completion
{
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    //メインスレッドで動作させる
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        for (PHGroup *group in cache.groups.allValues) {
            if ([group.identifier isEqualToString:groupId]) {
                [group setName:name];
                [bridgeSendAPI updateGroupWithGroup:group completionHandler:^(NSArray *errors) {
                    
                    [self setCompletionWithResponseCompletion:completion
                                         errors:errors
                                   errorState:STATE_ERROR_CHANGE_FAIL_GROUP_NAME];
                    
                }];
                break;
            }
        }
    });
    return NO;
    
}

/*
 数値判定。
 */
- (BOOL)isDigitWithString:(NSString *)numberString {
    NSRange match = [numberString rangeOfString:@"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$" options:NSRegularExpressionSearch];
    //数値の場合
    if(match.location != NSNotFound) {
        return YES;
    }
    _bridgeConnectState = STATE_ERROR_INVALID_BRIGHTNESS;
    return NO;
}


#pragma mark - private method

/*
 Hue方式の色を取得する。
 エラーの場合は、xとyにFLT_MINを返す。
 */
- (CGPoint) convRgbToXy:(NSString *)color
{
    
    NSString *redString = [color substringWithRange:NSMakeRange(0, 2)];
    NSString *greenString = [color substringWithRange:NSMakeRange(2, 2)];
    NSString *blueString = [color substringWithRange:NSMakeRange(4, 2)];
    
    NSScanner *scan = [NSScanner scannerWithString:redString];
    
    unsigned int redValue, greenValue, blueValue;
    
    if (![scan scanHexInt:&redValue]) {
        return CGPointMake(FLT_MIN, FLT_MIN);
    }
    scan = [NSScanner scannerWithString:greenString];
    if (![scan scanHexInt:&greenValue]) {
        return CGPointMake(FLT_MIN, FLT_MIN);
    }
    scan = [NSScanner scannerWithString:blueString];
    if (![scan scanHexInt:&blueValue]) {
        return CGPointMake(FLT_MIN, FLT_MIN);
    }
    float fRR = (float)(redValue/255.0);
    float fGG = (float)(greenValue/255.0);
    float fBB = (float)(blueValue/255.0);
    UIColor *uicolor = [UIColor colorWithRed:fRR green:fGG blue:fBB alpha:1.0f];
    
    return [PHUtilities calculateXY:uicolor forModel:@"LCT001"];
}


-(void)saveBridgeList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_hueBridgeList forKey:DPHueBridgeListName];
    [userDefaults synchronize];
}


-(void)readBridgeList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _hueBridgeList = [userDefaults dictionaryForKey:DPHueBridgeListName].mutableCopy;
}

// 通知を受け取るメソッド
-(void)notifiedNetworkStatus:(NSNotification *)notification {
    NetworkStatus networkStatus = [self.reachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self updateManageServices: NO];
    } else {
        [self updateManageServices: YES];
    }
}

- (void)updateManageServices : (BOOL) onlineForSet {
    @synchronized(self) {

        // ServiceProvider未登録なら処理しない
        if (!self.mServiceProvider) {
            return;
        }
        
        // オフラインにする場合は、全サービスをオフラインにする(Wifi Offにされたことを想定)
        if (!onlineForSet) {
            for (DConnectService *service in [self.mServiceProvider services]) {
                [service setOnline: NO];
            }
            return;
        }
        
        NSDictionary *bridgesFound = self.hueBridgeList;

        // ServiceProviderに存在するデバイスが最新のリストに存在しなかったらそのサービスをオフラインにする
        for (DPHueService *service in [self.mServiceProvider services]) {
            NSString *serviceId = [service serviceId];
            if (!bridgesFound[serviceId]) {
                [service setOnline: NO];
            }
        }
        
        // ServiceProviderに未登録のデバイスが見つかったら追加登録する。登録済ならそのサービスをオンラインにする
        if (bridgesFound.count > 0) {
            for (id key in [bridgesFound keyEnumerator]) {
                NSString *serviceId = [NSString stringWithFormat:@"%@_%@",[bridgesFound valueForKey:key],key];
                DConnectService *service = [self.mServiceProvider service: serviceId];
                if (service) {
                    [service setOnline: YES];
                } else {
                    service = [[DPHueService alloc] initWithBridgeKey:key bridgeValue:[bridgesFound valueForKey:key] plugin: [self plugin]];
                    [self.mServiceProvider addService: service];
                    [service setOnline:YES];
                }
            }
            
        }
    }
}



@end
