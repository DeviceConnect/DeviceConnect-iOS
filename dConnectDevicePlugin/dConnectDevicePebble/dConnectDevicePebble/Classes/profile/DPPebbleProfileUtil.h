//
//  DPPebbleProfileUtil.h
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPPebbleProfileUtil : NSObject

// 共通エラーチェック
+ (BOOL)handleError:(NSError*)error response:(DConnectResponseMessage *)response;

// 通常のエラーチェック
+ (void)handleErrorNormal:(NSError*)error response:(DConnectResponseMessage *)response;

// 共通イベントリクエスト処理
+ (void)handleRequest:(DConnectRequestMessage *)request
			 response:(DConnectResponseMessage *)response
			 isRemove:(BOOL)isRemove
			 callback:(void(^)(void))callback;

// 共通イベントメッセージ送信
+ (void)sendMessageWithPlugin:(id)plugin
						profile:(NSString *)profile
					  attribute:(NSString *)attribute
					   serviceID:(NSString*)serviceID
				messageCallback:(void(^)(DConnectMessage *eventMsg))messageCallback
				 deleteCallback:(void(^)(void))deleteCallback;

@end
