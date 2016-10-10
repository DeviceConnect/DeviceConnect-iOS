//
//  DPAWSIoTUtils.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTUtils.h"
#import "DPAWSIoTKeychain.h"
#import "DPAWSIoTManager.h"
#import "DPAWSIoTNetworkManager.h"
#import "DConnectManager+Private.h"
#import "DConnectManagerServiceDiscoveryProfile.h"
#import "DPAWSIoTController.h"

#define kAccessKeyID @"accessKey"
#define kSecretKey @"secretKey"
#define kRegionKey @"regionKey"
#define kSyncKey @"syncInterval"

#define ERROR_DOMAIN @"DPAWSIoTUtils"

#define kOrigin @"http://localhost:4035"

@implementation DPAWSIoTUtils

// ローディング画面
static UIViewController *loadingHUD;


// アカウントの設定があるか
+ (BOOL)hasAccount {
	NSString *accessKey = [DPAWSIoTKeychain findWithKey:kAccessKeyID];
	NSString *secretKey = [DPAWSIoTKeychain findWithKey:kSecretKey];
	return accessKey!=nil && secretKey!=nil;
}

// アカウントの設定をクリア
+ (void)clearAccount {
	[DPAWSIoTKeychain deleteWithKey:kAccessKeyID];
	[DPAWSIoTKeychain deleteWithKey:kSecretKey];
	[DPAWSIoTKeychain deleteWithKey:kRegionKey];
}

// アカウントを設定
+ (void)setAccount:(NSString*)accessKey secretKey:(NSString*)secretKey region:(NSInteger)region {
	[DPAWSIoTKeychain updateValue:accessKey key:kAccessKeyID];
	[DPAWSIoTKeychain updateValue:secretKey key:kSecretKey];
	[DPAWSIoTKeychain updateValue:[@(region) stringValue] key:kRegionKey];
}

// イベント更新間隔を設定
+ (void)setEventSyncInterval:(NSInteger)interval {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:interval forKey:kSyncKey];
	[defaults synchronize];
}

// イベント更新間隔を取得
+ (NSInteger)eventSyncInterval {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:@{kSyncKey:@(10)}];
	return [defaults integerForKey:kSyncKey];
}

// AccessTokenを取得
+ (NSString*)accessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"_access_token_"];
}

// AccessTokenを追加
+ (void)addAccessToken:(NSString*)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"_access_token_"];
    [defaults synchronize];
}

// Managerを許可
+ (void)addAllowManager:(NSString*)uuid {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *array = [[defaults arrayForKey:@"allowManagers"] mutableCopy];
	if (!array) {
		array = [NSMutableArray array];
	}
	if (![array containsObject:uuid]) {
		[array addObject:uuid];
	}
	[defaults setObject:array forKey:@"allowManagers"];
	[defaults synchronize];
}

// Managerの許可を解除
+ (void)removeAllowManager:(NSString*)uuid {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *array = [[defaults arrayForKey:@"allowManagers"] mutableCopy];
	if (!array) {
		return;
	}
	[array removeObject:uuid];
	[defaults setObject:array forKey:@"allowManagers"];
	[defaults synchronize];
}

// Managerが許可されているか
+ (BOOL)hasAllowedManager:(NSString*)uuid {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *array = [defaults arrayForKey:@"allowManagers"];
	if (array) {
		return [array containsObject:uuid];
	} else {
		return NO;
	}
}

// ログイン
+ (void)loginWithHandler:(void (^)(NSError *error))handler {
	NSString *accessKey = [DPAWSIoTKeychain findWithKey:kAccessKeyID];
	NSString *secretKey = [DPAWSIoTKeychain findWithKey:kSecretKey];
	NSInteger region = [[DPAWSIoTKeychain findWithKey:kRegionKey] integerValue];
	[[DPAWSIoTManager sharedManager] connectWithAccessKey:accessKey secretKey:secretKey region:region completionHandler:^(NSError *error) {
        if (error) {
            if (handler) {
                handler(error);
            }
        } else {
            [DPAWSIoTUtils auth:handler];
        }
	}];
}

+ (void) auth:(void (^)(NSError *error))handler {
    NSArray *supports = @[@"servicediscovery",
                          @"serviceinformation",
                          @"system",
                          @"battery",
                          @"connect",
                          @"deviceorientation",
                          @"filedescriptor",
                          @"file",
                          @"mediaplayer",
                          @"mediastreamrecording",
                          @"notification",
                          @"phone",
                          @"proximity",
                          @"settings",
                          @"vibration",
                          @"light",
                          @"remotecontroller",
                          @"drivecontroller",
                          @"mhealth",
                          @"sphero",
                          @"dice",
                          @"temperature",
                          @"camera",
                          @"canvas",
                          @"health",
                          @"touch",
                          @"humandetect",
                          @"keyevent",
                          @"omnidirectionalimage",
                          @"tv",
                          @"powermeter",
                          @"humidity",
                          @"illuminance",
                          @"videochat",
                          @"airconditioner",
                          @"atmosphericpressure",
                          @"ecg",
                          @"poseEstimation",
                          @"stressEstimation",
                          @"walkState",
                          @"gpio"];
    [DConnectUtil asyncAuthorizeWithOrigin:kOrigin
                                   appName:@"AWSIoT"
                                    scopes:supports
                                   success:^(NSString *clientId, NSString *accessToken) {
                                       [DPAWSIoTUtils addAccessToken:accessToken];
                                       [[DPAWSIoTController sharedManager] openWebSocket:accessToken];
                                       if (handler) {
                                           handler(nil);
                                       }
                                   } error:^(DConnectMessageErrorCodeType errorCode) {
                                       if (handler) {
                                           handler(nil);
                                       }
                                   }];
}

// ローディング画面表示
+ (void)showLoadingHUD:(UIStoryboard*)storyboard {
	if (!loadingHUD) {
		loadingHUD = [storyboard instantiateViewControllerWithIdentifier:@"LoadingHUD"];
	}
	[[UIApplication sharedApplication].keyWindow addSubview:loadingHUD.view];
	loadingHUD.view.alpha = 0;
	loadingHUD.view.tag = 0;
	[UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
		loadingHUD.view.alpha = 1.0;
	} completion:^(BOOL finished) {
		loadingHUD.view.tag = 1;
	}];
}

// ローディング画面非表示
+ (void)hideLoadingHUD {
	if (loadingHUD.view.tag == 0) {
		[loadingHUD.view removeFromSuperview];
	} else {
		[UIView animateWithDuration:0.2 animations:^{
			loadingHUD.view.alpha = 0;
		} completion:^(BOOL finished) {
			[loadingHUD.view removeFromSuperview];
		}];
	}
}

// メニュー作成
+ (UIAlertController*)createMenu:(NSArray*)items handler:(void (^)(int index))handler {
	UIAlertController *alert =
	[UIAlertController alertControllerWithTitle:nil
										message:nil
								 preferredStyle:UIAlertControllerStyleActionSheet];
 
	// cancel
	UIAlertAction * cancelAction =
	[UIAlertAction actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleCancel
						   handler:nil];
	[alert addAction:cancelAction];

	// メニューアイテム
	for (int i=0; i<items.count; i++) {
		UIAlertAction * action =
		[UIAlertAction actionWithTitle:items[i]
								 style:UIAlertActionStyleDefault
							   handler:^(UIAlertAction * action)
		 {
			 handler(i);
		 }];
		[alert addAction:action];
	}
	return alert;
}

// HTTP通信
+ (void)sendRequest:(NSDictionary*)request handler:(void (^)(NSData *data, NSError *error))handler {
	if (!request) {
		handler(nil, [NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
		return;
	}

	// localhostへアクセス
	DConnectManager *mgr = [DConnectManager sharedManager];
	NSString *path = [NSString stringWithFormat:@"http://localhost:%d", mgr.settings.port];
	NSMutableDictionary *params = [request mutableCopy];
	path = [self appendPath:path params:params name:@"api"];
	path = [self appendPath:path params:params name:@"profile"];
	path = [self appendPath:path params:params name:@"interface"];
	path = [self appendPath:path params:params name:@"attribute"];
	NSString *method = request[@"action"];
    NSString *origin = kOrigin;
	// accessTokenを設定
	NSString *profile = request[DConnectMessageProfile];
	NSString *serviceId = request[DConnectMessageServiceId];
	if (serviceId) {
        NSString *token = [self accessToken];
		if (token) {
			params[@"accessToken"] = token;
		}
	}
	
	// 不要なパラメータを削除
	[params removeObjectForKey:@"action"];
	[params removeObjectForKey:@"origin"];
	[params removeObjectForKey:@"_type"];
	[params removeObjectForKey:@"version"];
	
	if ([profile localizedCaseInsensitiveContainsString:DConnectServiceDiscoveryProfileName]) {
		// ServiceDiscoveryはLocalOAuthをやらないように別アクセス
		dispatch_async(dispatch_get_main_queue(), ^{
			DConnectManager *mgr = [DConnectManager sharedManager];
			DConnectManagerServiceDiscoveryProfile *p = (DConnectManagerServiceDiscoveryProfile*)[mgr profileWithName:DConnectServiceDiscoveryProfileName];
			DConnectResponseMessage *response = [DConnectResponseMessage message];
			DConnectRequestMessage *request = [DConnectRequestMessage new];
			[request setString:@"true" forKey:@"_selfOnly"];
			[request setAction: DConnectMessageActionTypeGet];
			[p getServicesRequest:request response:response];
			NSString *json = [response convertToJSONString];
			NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
			handler(data, nil);
		});
	} else {
		// 通常の処理
		[DPAWSIoTNetworkManager sendRequestWithPath:path method:method
											 params:params headers:@{@"X-GotAPI-Origin": origin}
											handler:^(NSData *data, NSURLResponse *response, NSError *error)
		 {
			 if (error) {
				 handler(nil, error);
				 return;
			 }
			 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
			 if (httpResponse.statusCode == 200) {
				 handler(data, nil);
			 } else {
				 handler(data, [NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
			 }
		 }];
	}
}

// パス追加
+ (NSString*)appendPath:(NSString*)path params:(NSMutableDictionary*)params name:(NSString*)name {
	if (params[name]) {
		path = [path stringByAppendingPathComponent:params[name]];
		[params removeObjectForKey:name];
	}
	return path;
}

// Packege名取得
+ (NSString *)packageName {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *package = [bundle bundleIdentifier];
	return package;
}

// アラート表示
+ (void)showAlert:(UIViewController*)vc title:(NSString*)title message:(NSString*)message handler:(void (^)())handler {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
																			 message:message
																	  preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *action =
	[UIAlertAction actionWithTitle:@"OK"
							 style:UIAlertActionStyleCancel
						   handler:^(UIAlertAction *action)
	 {
		 handler();
	 }];
	[alertController addAction:action];
	[vc presentViewController:alertController animated:YES completion:nil];
}

@end
