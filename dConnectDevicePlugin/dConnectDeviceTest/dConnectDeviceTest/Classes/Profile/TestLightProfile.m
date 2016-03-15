//
//  TestLightProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestLightProfile.h"
#import "DeviceTestPlugin.h"


static NSString* TestLightId = @"1";
static NSString* TestLightName = @"照明";
static NSString* TestLightGroupId = @"2";
static NSString* TestLightGroupName = @"リビング";
static const BOOL TestLightStatus = NO;


@implementation TestLightProfile
- (id) initWithDevicePlugin:(DeviceTestPlugin *)plugin {
    self = [super init];
    
    if (self) {
        self.delegate = self;
        _plugin = plugin;
    }
    
    return self;
}

- (BOOL) profile:(DConnectLightProfile *)profile
didReceiveGetLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        DConnectArray *lights = [DConnectArray array];
        //ライトの状態をメッセージにセットする（LightID,名前,点灯状態）
        DConnectMessage *led = [DConnectMessage new];
        [DConnectLightProfile setLightId:TestLightId target:led];
        [DConnectLightProfile setLightName:TestLightName target:led];
        [DConnectLightProfile setLightOn:NO target:led];
        [DConnectLightProfile setLightConfig:@"" target:led];
        [lights addMessage:led];
        [DConnectLightProfile setLights:lights target:response];
    }
    return YES;
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
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
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
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
    
}

//Light Delete 消灯
- (BOOL) profile:(DConnectLightProfile *)profile
didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         lightId:(NSString*) lightId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}


#pragma mark - light group

//Light Group GET グループ一覧取得
- (BOOL)                   profile:(DConnectLightProfile *)profile
    didReceiveGetLightGroupRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;

        DConnectArray *groups = [DConnectArray array];
        DConnectMessage *groupResponse = [DConnectMessage new];
        [DConnectLightProfile setLightGroupId:TestLightGroupId target:groupResponse];
        [DConnectLightProfile setLightGroupName:TestLightGroupName target:groupResponse];
        DConnectArray *lights = [DConnectArray array];
        DConnectMessage *led = [DConnectMessage new];
        [DConnectLightProfile setLightId:TestLightId target:led];
        [DConnectLightProfile setLightName:TestLightName target:led];
        [DConnectLightProfile setLightOn:NO target:led];
        [DConnectLightProfile setLightConfig:@"" target:led];
        [lights addMessage:led];
        [DConnectLightProfile setLights:lights target:groupResponse];
        [groups addMessage:groupResponse];
        [DConnectLightProfile setLightGroups:groups target:response];
    };
    return YES;
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
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}


//Light Group Delete ライトグループ消灯
- (BOOL) profile:(DConnectLightProfile *)profile didReceiveDeleteLightGroupRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         groupId:(NSString*)groupId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
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
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}

//Light Group Post ライトグループ作成
- (BOOL) profile:(DConnectLightProfile *)profile didReceivePostLightGroupCreateRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
        lightIds:(NSArray*)lightIds
       groupName:(NSString*)groupName {
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectLightProfile setLightGroupId:TestLightGroupId target:response];
    }
    return YES;
}



//Light Group Delete ライトグループ削除
- (BOOL) profile:(DConnectLightProfile *)profile didReceiveDeleteLightGroupClearRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
         groupId:(NSString*)groupId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}

@end
