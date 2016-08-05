//
//  DPAWSIoTManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AWSIoT.h>
#import <Foundation/Foundation.h>

@interface DPAWSIoTManager : NSObject

// 共有インスタンス
+ (instancetype)sharedManager;

// 接続
- (void)connectWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey region:(AWSRegionType)region
		   completionHandler:(void (^)(NSError *error))handler;
// 切断
- (void)disconnect;
// Shadow取得
- (void)fetchShadowWithName:(NSString*)name
		  completionHandler:(void (^)(NSString *result, NSError *error))handler;
// Shadow更新
- (void)updateShadowWithName:(NSString*)name value:(NSString*)str
		   completionHandler:(void (^)(NSError *error))handler;
// MQTTのTopicを購読
- (BOOL)subscribeWithTopic:(NSString*)topic messageHandler:(void (^)(NSString *message))handler;
// MQTTのTopicにメッセージを配信
- (BOOL)publishWithTopic:(NSString*)topic message:(NSString*)message;

@end
