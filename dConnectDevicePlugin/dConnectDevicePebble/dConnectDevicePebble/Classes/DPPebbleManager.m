//
//  DPPebbleManager.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleManager.h"
#import <PebbleKit/PebbleKit.h>
#import "pebble_device_plugin_defines.h"
#import <DConnectSDK/DConnectService.h>
#import "DPPebbleService.h"

/** milli G を m/s^2 の値にする係数. */
#define G_TO_MS2_COEFFICIENT 9.81/1000.0

// PebbleWatchAppのUUID
static NSString *const DPPebbleUUID = @"ecfbe3b5-65f4-4532-be4e-3d013058d1f5";

// コマンド送信最大リトライ回数
static const NSInteger DPMaxRetryCount = 3;
// リトライインターバル（秒）
static const NSTimeInterval DPRetryInterval = 1.0;
// セマフォのタイムアウト
static const NSTimeInterval DPSemaphoreTimeout = 10.0;

static NSString * const kDPPebbleRegexDecimalPoint = @"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$";
static NSString * const kDPPebbleRegexDigit = @"^([0-9]*)?$";
static NSString * const kDPPebbleRegexCSV = @"^([^,]*,)+";


@interface DPPebbleManager () <PBPebbleCentralDelegate> {
	NSMutableDictionary *_updateHandlerDict;
	NSMutableDictionary *_callbackDict;
	NSMutableDictionary *_eventCallbackDict;
	dispatch_semaphore_t _semaphore;
}

@end

@implementation DPPebbleManager

// 共有インスタンス
+ (instancetype)sharedManager
{
	static id sharedInstance;
	static dispatch_once_t onceSpheroToken;
	dispatch_once(&onceSpheroToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

// 初期化
- (instancetype)init
{
	self = [super init];
	if (self) {
		_updateHandlerDict = [NSMutableDictionary dictionary];
		_callbackDict = [NSMutableDictionary dictionary];
		_eventCallbackDict = [NSMutableDictionary dictionary];
		_semaphore = dispatch_semaphore_create(1);
		
		[[PBPebbleCentral defaultCentral] setDelegate:self];
		uuid_t myAppUUIDbytes;
		NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:DPPebbleUUID];
		[myAppUUID getUUIDBytes:myAppUUIDbytes];
		[[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];

	}
	return self;
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    // デバイス管理情報更新
    [self updateManageServices];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    // デバイス管理情報更新
    [self updateManageServices];
}

// アプリがバックグラウンドに入った時に呼ぶ
- (void)applicationDidEnterBackground
{
}

// アプリがフォアグラウンドに入った時に呼ぶ
- (void)applicationWillEnterForeground
{
	// すぐは復帰できないので。
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		// イベントハンドラの復帰
		for (NSString *serviceID in _updateHandlerDict) {
			PBWatch *watch = [self watchWithServiceID:serviceID];
			if (watch) {
				[self addHandler:watch serviceID:serviceID];
			}
		}
	});
}


// 接続可能なデバイスリスト取得
- (NSArray*)deviceList
{
	NSMutableArray *array = [NSMutableArray array];
	for (PBWatch *watch in [[PBPebbleCentral defaultCentral] connectedWatches]) {
		//NSLog(@"%@", watch);
		//NSLog(@"%@", watch.name);
		//NSLog(@"%@", watch.serialNumber);
		[array addObject:@{@"name": watch.name, @"id": watch.serialNumber}];
	}
	return array;
}

// サービスIDからPBWatchを取得
- (PBWatch*)watchWithServiceID:(NSString*)serviceID
{
	for (PBWatch *watch in [[PBPebbleCentral defaultCentral] connectedWatches]) {
		if ([watch.serialNumber isEqualToString:serviceID]) {
			// 接続済みのもののみ
			if (watch.isConnected) {
				return watch;
			}
			break;
		}
	}
	return nil;
}

// デバイス管理情報更新
- (void) updateManageServices {
    @synchronized(self) {
        
        // ServiceProvider未登録なら処理しない
        if (!self.serviceProvider) {
            return;
        }
        
        NSArray *deviceList = [self deviceList];
        
        // ServiceProviderに存在するサービスが検出されなかったならオフラインにする
        for (DConnectService *service in [self.serviceProvider services]) {
            NSString *serviceId = [service serviceId];
            
            // Pebble以外は対象外
            if (![[[service name] lowercaseString] hasPrefix: @"pebble"]) {
                continue;
            }
            
            // ServiceProviderにあって最新のリストに無い場合はオフラインにする。有ればオンラインにする
            BOOL isFindDevice = NO;
            for (NSDictionary *device in deviceList) {
                NSString *deviceServiceId = device[@"id"];
                if (deviceServiceId && [serviceId localizedCaseInsensitiveCompare: deviceServiceId] == NSOrderedSame) {
                    isFindDevice = YES;
                    break;
                }
            }
            if (isFindDevice) {
                [service setOnline: YES];
            } else {
                [service setOnline: NO];
            }
        }
        
        // サービス未登録なら登録する
        for (NSDictionary *device in deviceList) {
            NSString *serviceId = device[@"id"];
            NSString *deviceName = device[@"name"];
            if (![self.serviceProvider service: serviceId]) {
                DPPebbleService *service = [[DPPebbleService alloc] initWithServiceId:serviceId
                                                                           deviceName:deviceName
                                            plugin: self.plugin];
                [self.serviceProvider addService: service];
                [service setOnline:YES];
            }
        }
    }
}


#pragma mark - Battery

// バッテリー情報取得
- (void)fetchBatteryInfo:(NSString*)serviceID callback:(void(^)(float level, BOOL isCharging, NSError *error))callback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_BATTERY);
	dic[@(KEY_ATTRIBUTE)] = @(BATTERY_ATTRIBUTE_ALL);
	dic[@(KEY_ACTION)] = @(ACTION_GET);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		// エラー
		if (!data || error) {
			callback(0, NO, error);
			return;
		}
		// レベルを0~1、充電中かをBOOLで返す
		NSNumber *level = data[@(KEY_PARAM_BATTERY_LEVEL)];
		NSNumber *charging = data[@(KEY_PARAM_BATTERY_CHARGING)];
		callback([level intValue] / 100.0, [charging intValue] == BATTERY_CHARGING_ON, nil);
	}];
}

// バッテリーレベル取得
- (void)fetchBatteryLevel:(NSString*)serviceID callback:(void(^)(float level, NSError *error))callback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_BATTERY);
	dic[@(KEY_ATTRIBUTE)] = @(BATTERY_ATTRIBUTE_LEVEL);
	dic[@(KEY_ACTION)] = @(ACTION_GET);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		// エラー
		if (!data || error) {
			callback(0, error);
			return;
		}
		// レベルを0~1で返す
		NSNumber *level = data[@(KEY_PARAM_BATTERY_LEVEL)];
		callback([level intValue] / 100.0, nil);
	}];
}

// バッテリー充電ステータス取得
- (void)fetchBatteryCharging:(NSString*)serviceID callback:(void(^)(BOOL isCharging, NSError *error))callback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_BATTERY);
	dic[@(KEY_ATTRIBUTE)] = @(BATTERY_ATTRIBUTE_CHARING);
	dic[@(KEY_ACTION)] = @(ACTION_GET);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		// エラー
		if (!data || error) {
			callback(NO, error);
			return;
		}
		// 充電中かをBOOLで返す
		NSNumber *charging = data[@(KEY_PARAM_BATTERY_CHARGING)];
		callback([charging intValue] == BATTERY_CHARGING_ON, nil);
	}];
}

// 充電中のステータス変更イベント登録
- (void)registChargingChangeEvent:(NSString*)serviceID
                         callback:(void(^)(NSError *error))callback
                    eventCallback:(void(^)(BOOL isCharging))eventCallback
{
	if (!callback || !eventCallback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_BATTERY);
	dic[@(KEY_ATTRIBUTE)] = @(BATTERY_ATTRIBUTE_ON_CHARGING_CHANGE);
	dic[@(KEY_ACTION)] = @(ACTION_PUT);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		// エラー
		if (!data || error) {
			callback(error);
			return;
		}
		// 充電中かをBOOLで返す
		NSNumber *action = data[@(KEY_ACTION)];
		if ([action intValue] == ACTION_EVENT) {
			NSNumber *charging = data[@(KEY_PARAM_BATTERY_CHARGING)];
			eventCallback([charging intValue] == BATTERY_CHARGING_ON);
		} else {
			callback(nil);
		}
	}];
}

// 充電レベル変更イベント登録
- (void)registBatteryLevelChangeEvent:(NSString*)serviceID
                             callback:(void(^)(NSError *error))callback
                        eventCallback:(void(^)(float level))eventCallback
{
	if (!callback || !eventCallback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_BATTERY);
	dic[@(KEY_ATTRIBUTE)] = @(BATTERY_ATTRIBUTE_ON_BATTERY_CHANGE);
	dic[@(KEY_ACTION)] = @(ACTION_PUT);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		// エラー
		if (!data || error) {
			callback(error);
			return;
		}
		// レベルを0~1で返す
		NSNumber *action = data[@(KEY_ACTION)];
		if ([action intValue] == ACTION_EVENT) {
			NSNumber *level = data[@(KEY_PARAM_BATTERY_LEVEL)];
			eventCallback([level intValue] / 100.0);
		} else {
			callback(nil);
		}
	}];
}

// 充電中のステータス変更イベント削除
- (void)deleteChargingChangeEvent:(NSString*)serviceID callback:(void(^)(NSError *error))callback
{
	[self deleteEvent:serviceID profile:PROFILE_BATTERY attr:BATTERY_ATTRIBUTE_ON_CHARGING_CHANGE callback:callback];
}

// 充電レベル変更イベント削除
- (void)deleteBatteryLevelChangeEvent:(NSString*)serviceID callback:(void(^)(NSError *error))callback
{
	[self deleteEvent:serviceID profile:PROFILE_BATTERY attr:BATTERY_ATTRIBUTE_ON_BATTERY_CHANGE callback:callback];
}


#pragma mark - DeviceOrientation

// 傾きイベント登録
- (void)registDeviceOrientationEvent:(NSString*)serviceID
                            callback:(void(^)(NSError *error))callback
                       eventCallback:(void(^)(float orientationX,
                                              float orientationY,
                                              float orientationZ,
                                              long long interval))eventCallback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_DEVICE_ORIENTATION);
	dic[@(KEY_ATTRIBUTE)] = @(DEVICE_ORIENTATION_ATTRIBUTE_ON_DEVICE_ORIENTATION);
	dic[@(KEY_ACTION)] = @(ACTION_PUT);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		// エラー
		if (!data || error) {
			callback(error);
			return;
		}
		// レベルを0~1で返す
		NSNumber *action = data[@(KEY_ACTION)];
		if ([action intValue] == ACTION_EVENT) {
			NSNumber *orientationX = data[@(KEY_PARAM_DEVICE_ORIENTATION_X)];
			NSNumber *orientationY = data[@(KEY_PARAM_DEVICE_ORIENTATION_Y)];
			NSNumber *orientationZ = data[@(KEY_PARAM_DEVICE_ORIENTATION_Z)];
			NSNumber *intervalX = data[@(KEY_PARAM_DEVICE_ORIENTATION_INTERVAL)];
			
			float orientationXms2 = orientationX.intValue * G_TO_MS2_COEFFICIENT;
			float orientationYms2 = orientationY.intValue * G_TO_MS2_COEFFICIENT;
			float orientationZms2 = orientationZ.intValue * G_TO_MS2_COEFFICIENT;
			
			eventCallback(orientationXms2, orientationYms2, orientationZms2, intervalX.longLongValue);
		} else {
			callback(nil);
		}
	}];
}

// 傾きイベント削除
- (void)deleteDeviceOrientationEvent:(NSString*)serviceID
                            callback:(void(^)(NSError *error))callback
{
	[self deleteEvent:serviceID
              profile:PROFILE_DEVICE_ORIENTATION
                 attr:DEVICE_ORIENTATION_ATTRIBUTE_ON_DEVICE_ORIENTATION
             callback:callback];
}


#pragma mark - Setting

// 日時取得
- (void)fetchDate:(NSString*)serviceID
         callback:(void(^)(NSString *date, NSError *error))callback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_SETTING);
	dic[@(KEY_ATTRIBUTE)] = @(SETTING_ATTRIBUTE_DATE);
	dic[@(KEY_ACTION)] = @(ACTION_GET);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		// エラー
		if (!data || error) {
			callback(nil, error);
			return;
		}
		// 日時を返す
		callback(data[@(KEY_PARAM_SETTING_DATE)], nil);
	}];
}


#pragma mark - Vibration

// バイブレーション開始
- (void)startVibration:(NSString*)serviceID
               pattern:(NSArray *)pattern
              callback:(void(^)(NSError *error))callback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_VIBRATION);
	dic[@(KEY_ATTRIBUTE)] = @(VIBRATION_ATTRIBUTE_VIBRATE);
	dic[@(KEY_ACTION)] = @(ACTION_PUT);
	NSData *pattarnData = [self convertVibrationPattern:pattern];
	if (pattarnData == nil) {
		dic[@(KEY_PARAM_VIBRATION_LEN)] = @(0);
	} else {
		dic[@(KEY_PARAM_VIBRATION_LEN)] = @(pattarnData.length / 2);
		dic[@(KEY_PARAM_VIBRATION_PATTERN)] = pattarnData;
	}
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		callback(error);
	}];
}

// バイブのパターン情報をコンバート
- (NSData*)convertVibrationPattern:(NSArray *)pattern {
	if (pattern != nil || pattern.count != 0) {
		NSMutableData *data = [NSMutableData data];
		for (NSNumber *value in pattern) {
			int iValue = [value intValue];
			char buf[2];
			buf[0] = (char) (iValue >> 8) & 0xff;
			buf[1] = (char) (iValue & 0xff);
			[data appendBytes:buf length:2];
		}
		return data;
	}
    return nil;
}

// バイブレーション停止
- (void)stopVibration:(NSString*)serviceID callback:(void(^)(NSError *error))callback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_VIBRATION);
	dic[@(KEY_ATTRIBUTE)] = @(VIBRATION_ATTRIBUTE_VIBRATE);
	dic[@(KEY_ACTION)] = @(ACTION_DELETE);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		callback(error);
	}];
}


#pragma mark - System

// 全てのイベント登録を解除
- (void)deleteAllEvents:(void(^)(NSError *error))callback
{
	if (!callback) return;
	
	for (NSArray *data in _eventCallbackDict.allKeys) {
		NSString *serviceID = data[0];
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		dic[@(KEY_PROFILE)] = @(PROFILE_SYSTEM);
		dic[@(KEY_ATTRIBUTE)] = @(SYSTEM_ATTRIBUTE_EVENTS);
		dic[@(KEY_ACTION)] = @(ACTION_DELETE);
		[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		}];
	}
	
	// 初期化
	[_eventCallbackDict removeAllObjects];
	
	// コールバック
	callback(nil);
}

#pragma mark - Image


// 分割サイズ（Pebbleアプリ側でも定義してあるので大きくする場合には、
// Pebbleアプリ側の定義も修正すること）
#define BUF_SIZE 64

// 画像データ送信
- (void)sendImage:(NSString*)serviceID
             data:(NSData*)data
         callback:(void(^)(NSError *error))callback
{
	if (!callback) return;
	
	// 画像サイズ送信
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(PROFILE_BINARY);
	dic[@(KEY_PARAM_BINARY_LENGTH)] = @(data.length);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data2, NSError *error) {
		if (error) {
			callback(error);
		} else {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				NSUInteger count = data.length / BUF_SIZE + 1;
				dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 15);
				// 画像を分割して送信
				dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
				__block NSError *err = nil;
				for (int i = 0; i < count; i++) {
					// 送信
					[self sendImageBody:serviceID data:data index:i callback:^(NSError *error2) {
						err = error2;
						dispatch_semaphore_signal(semaphore);
					}];
					// 順番に処理
					long result = dispatch_semaphore_wait(semaphore, timeout);
					if (result!=0 || err) {
						// タイムアウトかエラーがあったら終了
						break;
					}
				}
				// コールバック
				callback(err);
			});
		}
	}];
}

// 画像データ送信（中身）
- (void)sendImageBody:(NSString*)serviceID
                 data:(NSData *)data
                index:(int)index
             callback:(void(^)(NSError *error))callback
{
	BOOL last = (data.length / BUF_SIZE == index);
	
	NSRange range;
	range.location = index * BUF_SIZE;
	if (last) {
		range.length = data.length - index * BUF_SIZE;
	} else {
		range.length = BUF_SIZE;
	}
	NSData *send = [data subdataWithRange:range];
	
	NSMutableDictionary *request = [NSMutableDictionary dictionary];
	request[@(KEY_PROFILE)] = @(PROFILE_BINARY);
	request[@(KEY_PARAM_BINARY_INDEX)] = @(index);
	request[@(KEY_PARAM_BINARY_BODY)] = send;
	[self sendCommand:serviceID request:request callback:^(NSDictionary *data, NSError *error) {
		callback(error);
	}];
}

- (void)deleteImage:(NSString *)serviceId callback:(void(^)(NSError *error))callback
{
    if (!callback) return;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@(KEY_PROFILE)] = @(PROFILE_CANVAS);
    dic[@(KEY_ATTRIBUTE)] = @(CANVAS_DRAW_IMAGE);
    dic[@(KEY_ACTION)] = @(ACTION_DELETE);
    [self sendCommand:serviceId request:dic callback:^(NSDictionary *data, NSError *error) {
        callback(error);
    }];
}

#pragma mark - KeyEvent

// KeyEvent OnDown event registration.
- (void)registOnDownEvent:(NSString*)serviceID
                 callback:(void(^)(NSError *error))callback
            eventCallback:(void(^)(long attr,
                                   int keyId,
                                   int keyType))eventCallback
{
    if (!callback) return;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@(KEY_PROFILE)] = @(PROFILE_KEY_EVENT);
    dic[@(KEY_ATTRIBUTE)] = @(KEY_EVENT_ATTRIBUTE_ON_DOWN);
    dic[@(KEY_ACTION)] = @(ACTION_PUT);
    [self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
        // Error.
        if (!data || error) {
            callback(error);
            return;
        }
        // Set KeyEvent data.
        NSNumber *action = data[@(KEY_ACTION)];
        if ([action intValue] == ACTION_EVENT) {
            NSNumber *Attr = data[@(KEY_ATTRIBUTE)];
            NSNumber *KeyId = data[@(KEY_PARAM_KEY_EVENT_ID)];
            NSNumber *KeyType = data[@(KEY_PARAM_KEY_EVENT_KEY_TYPE)];
            
            long attr = Attr.longValue;
            int keyId = KeyId.intValue;
            int keyType = KeyType.intValue;
            
            eventCallback(attr, keyId, keyType);
        } else {
            callback(nil);
        }
    }];
}

// KeyEvent OnUp event registration.
- (void)registOnUpEvent:(NSString*)serviceID
                 callback:(void(^)(NSError *error))callback
            eventCallback:(void(^)(long attr,
                                   int keyId,
                                   int keyType))eventCallback
{
    if (!callback) return;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@(KEY_PROFILE)] = @(PROFILE_KEY_EVENT);
    dic[@(KEY_ATTRIBUTE)] = @(KEY_EVENT_ATTRIBUTE_ON_UP);
    dic[@(KEY_ACTION)] = @(ACTION_PUT);
    [self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
        // Error.
        if (!data || error) {
            callback(error);
            return;
        }
        // Set KeyEvent data.
        NSNumber *action = data[@(KEY_ACTION)];
        if ([action intValue] == ACTION_EVENT) {
            NSNumber *Attr = data[@(KEY_ATTRIBUTE)];
            NSNumber *KeyId = data[@(KEY_PARAM_KEY_EVENT_ID)];
            NSNumber *KeyType = data[@(KEY_PARAM_KEY_EVENT_KEY_TYPE)];
            
            long attr = Attr.longValue;
            int keyId = KeyId.intValue;
            int keyType = KeyType.intValue;
            
            eventCallback(attr, keyId, keyType);
        } else {
            callback(nil);
        }
    }];
}
// KeyEvent onKeyChange event registration.
- (void)registOnKeyChangeEvent:(NSString*)serviceID
                      callback:(void(^)(NSError *error))callback
                 eventCallback:(void(^)(long attr, int keyId, int keyType, int keyState))eventCallback
{
    if (!callback) return;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@(KEY_PROFILE)] = @(PROFILE_KEY_EVENT);
    dic[@(KEY_ATTRIBUTE)] = @(KEY_EVENT_ATTRIBUTE_ON_KEY_CHANGE);
    dic[@(KEY_ACTION)] = @(ACTION_PUT);
    [self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
        // Error.
        if (!data || error) {
            callback(error);
            return;
        }
        // Set KeyEvent data.
        NSNumber *action = data[@(KEY_ACTION)];
        if ([action intValue] == ACTION_EVENT) {
            NSNumber *Attr = data[@(KEY_ATTRIBUTE)];
            NSNumber *KeyId = data[@(KEY_PARAM_KEY_EVENT_ID)];
            NSNumber *KeyType = data[@(KEY_PARAM_KEY_EVENT_KEY_TYPE)];
            NSNumber *KeyState = data[@(KEY_PARAM_KEY_EVENT_KEY_STATE)];
            long attr = Attr.longValue;
            int keyId = KeyId.intValue;
            int keyType = KeyType.intValue;
            int keyState = KeyState.intValue;
            eventCallback(attr, keyId, keyType, keyState);
        } else {
            callback(nil);
        }
    }];

}

// KeyEvent OnDown event unregistration.
- (void)deleteOnDownEvent:(NSString*)serviceID
                 callback:(void(^)(NSError *error))callback
{
    [self deleteEvent:serviceID
              profile:PROFILE_KEY_EVENT
                 attr:KEY_EVENT_ATTRIBUTE_ON_DOWN
             callback:callback];
}

// KeyEvent OnUp event unregistration.
- (void)deleteOnUpEvent:(NSString*)serviceID
               callback:(void(^)(NSError *error))callback
{
    [self deleteEvent:serviceID
              profile:PROFILE_KEY_EVENT
                 attr:KEY_EVENT_ATTRIBUTE_ON_UP
             callback:callback];
}
// KeyEvent onKeyChange event unregistration.
- (void)deleteOnKeyChangeEvent:(NSString*)serviceID callback:(void(^)(NSError *error))callback
{
    [self deleteEvent:serviceID
              profile:PROFILE_KEY_EVENT
                 attr:KEY_EVENT_ATTRIBUTE_ON_KEY_CHANGE
             callback:callback];
}
#pragma mark - Common

// イベント削除共通
- (void)deleteEvent:(NSString*)serviceID
            profile:(UInt32)profile
               attr:(UInt32)attr
           callback:(void(^)(NSError *error))callback
{
	if (!callback) return;
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@(KEY_PROFILE)] = @(profile);
	dic[@(KEY_ATTRIBUTE)] = @(attr);
	dic[@(KEY_ACTION)] = @(ACTION_DELETE);
	[self sendCommand:serviceID request:dic callback:^(NSDictionary *data, NSError *error) {
		callback(error);
		// 保持していたBlockを解放
		[_eventCallbackDict removeObjectForKey:@[serviceID, @(profile), @(attr)]];
	}];
}


#pragma mark - Send Command

// コマンド送信
- (void)sendCommand:(NSString*)serviceID
            request:(NSMutableDictionary*)request
           callback:(void(^)(NSDictionary*, NSError*))callback
{
	// 別スレッドで実行
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// コマンドが連続して送信されないようにセマフォを立てる
		dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * DPSemaphoreTimeout));
		// メインスレッドじゃないとPebbleコマンドが実行されない
		dispatch_async(dispatch_get_main_queue(), ^{
			// Callbackを保持（updateHandler:update:で使用する）
			_callbackDict[serviceID] = callback;
			// Event用のCallbackを保持（Attribute毎にCallbackが変わるのでキーに追加）
			NSNumber *action = request[@(KEY_ACTION)];
			if ([action intValue] == ACTION_PUT) {
				_eventCallbackDict[@[serviceID, request[@(KEY_PROFILE)], request[@(KEY_ATTRIBUTE)]]] = callback;
			}

			// コマンド実行
			[self sendCommand:serviceID request:request retryCount:0];
		});
	});
}

// コマンド送信（実装）
- (void)sendCommand:(NSString*)serviceID
            request:(NSMutableDictionary*)request
         retryCount:(int)retryCount
{
//	NSLog(@"sendCommand:%@ request:%@ retryCount:%d", serviceID, request, retryCount);

	// リクエストコードを作成して、リクエストに追加
	NSNumber *requestCode = @(rand());
	request[@(KEY_PARAM_REQUEST_CODE)] = requestCode;

	// ServiceIDからWatch取得
	PBWatch *watch = [self watchWithServiceID:serviceID];
	if (!watch) {
		// セマフォ解除
		dispatch_semaphore_signal(_semaphore);
		// エラーをコールバック
		void (^callback)(NSDictionary*, NSError*)  = _callbackDict[serviceID];
		if (callback) {
			NSError *error = [NSError errorWithDomain:@"DPPebbleManager" code:403 userInfo:nil];
			callback(nil, error);
		}
		return;
	}
	
	// UpdateHandler登録（１つのWatchに１つだけ）
	// フロー的に削除される事は無い
    // （アプリがバックグラウンドに行った時は全てクリアされる）
	if (!_updateHandlerDict[serviceID]) {
		[self addHandler:watch serviceID:serviceID];
	}
	
	// メッセージ送信
	[watch appMessagesPushUpdate:request onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
		if (error) {
			// 送信に失敗した場合には、DPMaxRetryCount回までアプリを起動してから再送する
			[watch appMessagesLaunch:^(PBWatch *watch, NSError *error2) {
				if (retryCount < DPMaxRetryCount) {
					// 一定時間後に再度実行
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                                    (int64_t)(DPRetryInterval * NSEC_PER_SEC)),
                                                        dispatch_get_main_queue(), ^{
						[self sendCommand:serviceID request:request retryCount:retryCount+1];
					});
				} else {
					// セマフォ解除
					dispatch_semaphore_signal(_semaphore);
					// エラーをコールバック
					void (^callback)(NSDictionary*, NSError*)  = _callbackDict[serviceID];
					if (callback) {
						callback(nil, error);
					}
				}
			}];
		} else {
			// バイナリ送信時は即時返答
			if ([request[@(KEY_PROFILE)] intValue] == PROFILE_BINARY) {
				// セマフォ解除
				dispatch_semaphore_signal(_semaphore);
				// コールバック
				void (^callback)(NSDictionary*, NSError*)  = _callbackDict[serviceID];
				if (callback) {
					callback(nil, nil);
				}
			}
		}
	}];
}

// ハンドラ追加
- (void)addHandler:(PBWatch*)watch serviceID:(NSString*)serviceID
{
	id opaqueHandle = [watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
		// ここは一度きりの登録なのでBlockを登録する訳にはいかないのでメソッドで。
		[self updateHandler:watch update:update];
		return YES;
	}];
	_updateHandlerDict[serviceID] = opaqueHandle;
}

// Updateハンドラ
- (void)updateHandler:(PBWatch*)watch update:(NSDictionary*)update
{
	NSNumber *action = update[@(KEY_ACTION)];
	if ([action intValue] == ACTION_EVENT) {
		// Eventのアップデート
		void (^callback)(NSDictionary*, NSError*)
                = _eventCallbackDict[@[watch.serialNumber,
                                update[@(KEY_PROFILE)], update[@(KEY_ATTRIBUTE)]]];
		if (callback) {
			callback(update, nil);
		}
        callback = _eventCallbackDict[@[watch.serialNumber,
                               update[@(KEY_PROFILE)], @(KEY_EVENT_ATTRIBUTE_ON_KEY_CHANGE)]];
        if (callback) {
            callback(update, nil);
        }
	} else {
		// SerialNumber==ServiceIDなので、ServiceIDにキーにコールバックを呼び出す
		void (^callback)(NSDictionary*, NSError*)  = _callbackDict[watch.serialNumber];
		if (callback) {
			callback(update, nil);
		}
		// セマフォ解除
		dispatch_semaphore_signal(_semaphore);
	}
}

- (BOOL)existNumberWithString:(NSString *)numberString Regex:(NSString*)regex {
    NSRange match = [numberString rangeOfString:regex options:NSRegularExpressionSearch];
    //数値の場合
    return match.location != NSNotFound;
}

- (BOOL)existDigitWithString:(NSString*)digit {
    return [self existNumberWithString:digit Regex:kDPPebbleRegexDigit];
}

- (BOOL)existDecimalWithString:(NSString*)decimal {
    return [self existNumberWithString:decimal Regex:kDPPebbleRegexDecimalPoint];
}

- (BOOL)existCSVWithString:(NSString *)csv {
    return [self existNumberWithString:csv Regex:kDPPebbleRegexCSV];
}
@end
