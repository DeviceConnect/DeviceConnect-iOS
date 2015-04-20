//
//  DPChromecastManager.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastManager.h"
#import <GoogleCast/GoogleCast.h>
#import "GCIPUtil.h"
#import "HTTPServer.h"

static NSString *const kReceiverAppID = @"[YOUR APPLICATION ID]";
static NSString *const kReceiverNamespace
    = @"urn:x-cast:com.name.space.chromecast.test.receiver";
static NSString * const kDPChromeRegexDecimalPoint = @"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$";
static NSString * const kDPChromeRegexDigit = @"^([0-9]*)?$";
static NSString * const kDPChromeMimeType = @"^([a-zA-Z]*)(/)([a-zA-Z]+)$";

// セマフォのタイムアウト
static const NSTimeInterval DPSemaphoreTimeout = 20.0;

@interface DPChromecastManagerData : NSObject
@property (nonatomic) GCKDeviceManager *deviceManager;
@property (nonatomic) GCKCastChannel *textChannel;
@property (nonatomic) GCKMediaControlChannel *ctrlChannel;
@property (nonatomic) NSString *mediaID;
@property (nonatomic) NSMutableArray *connectCallbacks;
@property (nonatomic, copy) void (^eventCallback)(NSString *mediaID);
@end
@implementation DPChromecastManagerData
@end


@interface DPChromecastManager () <GCKDeviceScannerListener,
                                GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate> {
	GCKDeviceScanner *_deviceScanner;
	NSMutableDictionary *_dataDict;
	dispatch_semaphore_t _semaphore;
    HTTPServer *_httpServer;
}

@end

@implementation DPChromecastManager

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
        _deviceScanner = [GCKDeviceScanner new];
		[_deviceScanner addListener:self];
		_dataDict = [NSMutableDictionary dictionary];
		_semaphore = dispatch_semaphore_create(1);
        // HTTP Server Activate.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        _httpServer = [HTTPServer new];
        [_httpServer setType:@"_http._tcp."];
        [_httpServer setPort:38088];
        [_httpServer setDocumentRoot:documentsDirectory];
	}
	return self;
}

#pragma mark - GCKLoggerDelegate

// スキャン開始
- (void)startScan
{
	[_deviceScanner startScan];
}

// スキャン停止
- (void)stopScan
{
	[_deviceScanner stopScan];
}



// Http Server Start
- (void)startHttpServer {
    [_httpServer start:NULL];
}

// Http Server Stop
- (void)stopHttpServer {
    [_httpServer stop];
}

// Get Server Host Name
- (NSString *)getIPString {
    NSString *ip = [GCIPUtil myIPAddress];
    UInt16 port = [_httpServer listeningPort];
    return [NSString stringWithFormat:@"%@:%hu", ip, port];
}

// デバイスリスト
- (NSArray*)deviceList
{
	NSMutableArray *array = [NSMutableArray array];
	for (GCKDevice *device in _deviceScanner.devices) {
        [array addObject:@{@"name": device.friendlyName, @"id": device.deviceID}];
	}
	return array;
}

// 接続チェック
- (BOOL)isConnectedWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	if (data) {
		// 既に接続済み
		GCKDeviceManager *deviceManager = data.deviceManager;
		return deviceManager.isConnected;
	}
	return NO;
}

// デバイスに接続
- (void)connectToDeviceWithID:(NSString*)deviceID
				   completion:(void (^)(BOOL success, NSString *error))completion
{
	GCKDevice *device = nil;
	for (device in _deviceScanner.devices) {
        NSString *dID = [NSString stringWithFormat:@"%@",device.deviceID];
		if ([dID isEqualToString:deviceID]) {
			break;
		}
	}
	// デバイスが見つからない
	if (!device) {
		// callback
		completion(NO, @"Device not found.");
		return;
	}
	
	// コマンドが連続して送信されないようにセマフォを立てる
	dispatch_semaphore_wait(_semaphore,
                            dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * DPSemaphoreTimeout));
	
    // GCKDeviceManagerへのアクセスはメインスレッド上で実行する
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // 接続確認
            DPChromecastManagerData *cache = _dataDict[deviceID];
        if (cache) {
            GCKDeviceManager *deviceManager = cache.deviceManager;
            [cache.connectCallbacks addObject:completion];
            if (deviceManager.isConnected) {
                dispatch_semaphore_signal(_semaphore);
                completion(YES, nil);
            } else {
                // 切断されていた場合は再接続
                [deviceManager connect];
            }
            return;
        }

        // 新規接続
        DPChromecastManagerData *data = [DPChromecastManagerData new];
        data.connectCallbacks = [NSMutableArray array];
        [data.connectCallbacks addObject:completion];
        _dataDict[deviceID] = data;

        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        data.deviceManager = [[GCKDeviceManager alloc]
                              initWithDevice:device
                           clientPackageName:info[@"CFBundleIdentifier"]];
        data.deviceManager.delegate = self;
        [data.deviceManager connect];
    });
}

// イベントコールバックを設定
- (void)setEventCallbackWithID:(NSString*)deviceID callback:(void (^)(NSString *mediaID))callback
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	if (data) {
		data.eventCallback = callback;
	} else {
		[self connectToDeviceWithID:deviceID completion:^(BOOL success, NSString *error) {
			DPChromecastManagerData *data = _dataDict[deviceID];
			data.eventCallback = callback;
		}];
	}
}

// 接続中のデバイスから切断
- (void)disconnectDeviceWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	if (data) {
		[data.deviceManager stopApplication];
		[data.deviceManager disconnect];
        [data.deviceManager removeChannel:data.ctrlChannel];
        [data.deviceManager removeChannel:data.textChannel];
        
		data.deviceManager = nil;
		data.ctrlChannel = nil;
		data.textChannel = nil;
        data.eventCallback = nil;
        data.connectCallbacks = nil;
		[_dataDict removeObjectForKey:deviceID];
	}
    [self stopScan];
}

// テキストの送信
- (void)sendMessageWithID:(NSString*)deviceID message:(NSString*)message type:(int)type
{
	NSDictionary *messageDict = @{@"function": @"write",
								  @"type": @(type),
								  @"message": message};
	[self sendJsonWithID:deviceID json:messageDict];
}

// テキストのクリア
- (void)clearMessageWithID:(NSString*)deviceID
{
	[self sendJsonWithID:deviceID json:@{@"function": @"clear"}];
}


// Canvasの送信
- (void)sendCanvasWithID:(NSString*)deviceID
                imageURL:(NSString*)imageURL
                  imageX:(double)imageX
                  imageY:(double)imageY
                    mode:(NSString*)mode {
    NSDictionary *messageDict = @{@"function": @"canvas_draw",
                                  @"url": imageURL,
                                  @"x": @(imageX),
                                  @"y": @(imageY),
                                  @"mode": mode};
    [self sendJsonWithID:deviceID json:messageDict];
    
}
// Canvasのクリア
- (void)clearCanvasWithID:(NSString*)deviceID {
    [self sendJsonWithID:deviceID json:@{@"function": @"canvas_delete"}];
}



// JSONの送信
- (void)sendJsonWithID:(NSString*)deviceID json:(NSDictionary *)json
{
	NSData *msgData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
	NSString *jsonstr = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
	
	DPChromecastManagerData *data = _dataDict[deviceID];
	[data.textChannel sendTextMessage:jsonstr];
}

// メディアプレイヤーの状態取得
- (NSString*)mediaPlayerStateWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	switch (data.ctrlChannel.mediaStatus.playerState) {
		case GCKMediaPlayerStateIdle:
			return @"stop";
		case GCKMediaPlayerStatePlaying:
			return @"play";
		case GCKMediaPlayerStatePaused:
			return @"pause";
		case GCKMediaPlayerStateBuffering:
			return @"buffering";
		default:
			return @"unknown";
	}
}

// 再生位置を取得
- (NSTimeInterval)streamPositionWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	return[data.ctrlChannel approximateStreamPosition];
}

// 再生位置を変更
- (void)setStreamPositionWithID:(NSString*)deviceID position:(NSTimeInterval)streamPosition
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	[data.ctrlChannel seekToTimeInterval:streamPosition];
}

// 音量を取得
- (float)volumeWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	return data.ctrlChannel.mediaStatus.volume;
}

// 音量を設定
- (void)setVolumeWithID:(NSString*)deviceID volume:(float)volume
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	[data.ctrlChannel setStreamVolume:volume];
}

// ミュート状態取得
- (BOOL)isMutedWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	return data.ctrlChannel.mediaStatus.isMuted;
}

// ミュート状態設定
- (void)setIsMutedWithID:(NSString*)deviceID muted:(BOOL)isMuted
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	[data.ctrlChannel setStreamMuted:isMuted];
}

// メディア読み込み
- (NSInteger)loadMediaWithID:(NSString*)deviceID mediaID:(NSString*)mediaID
{
    GCKMediaMetadata *metadata = [GCKMediaMetadata new];
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:mediaID
                                        streamType:GCKMediaStreamTypeBuffered
                                       contentType:@"video/qucktime"
                                          metadata:metadata
                                    streamDuration:123
                                        customData:nil];
    
    DPChromecastManagerData *data = _dataDict[deviceID];
    data.mediaID = mediaID;
    return [data.ctrlChannel loadMedia:mediaInformation autoplay:NO];
}

// 再生
- (NSInteger)playWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
    if (data.ctrlChannel.mediaStatus.playerState == GCKMediaPlayerStateIdle) {
        GCKMediaMetadata *metadata = [GCKMediaMetadata new];
        GCKMediaInformation *mediaInformation =
        [[GCKMediaInformation alloc]
                 initWithContentID:data.mediaID
                        streamType:GCKMediaStreamTypeBuffered
                       contentType:@"video/quicktime"
                          metadata:metadata
                    streamDuration:123
                        customData:nil];
        return [data.ctrlChannel loadMedia:mediaInformation autoplay:YES];
    }
    return [data.ctrlChannel play];
}

// 停止
- (NSInteger)stopWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	return [data.ctrlChannel stop];
}

// 一時停止
- (NSInteger)pauseWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	return [data.ctrlChannel pause];
}

// 長さ取得
- (NSTimeInterval)durationWithID:(NSString*)deviceID
{
	DPChromecastManagerData *data = _dataDict[deviceID];
	return data.ctrlChannel.mediaStatus.mediaInformation.streamDuration;
}


// directoryPath内のextension(拡張子)と一致する全てのファイル名
- (void)removeFileForfileNamesAtDirectoryPath:(NSString*)directoryPath
                                    extension:(NSString*)extension
{
    NSFileManager *fileManager = [NSFileManager new];
    NSArray *allFileName = [fileManager contentsOfDirectoryAtPath:directoryPath
                                                            error:NULL];
    for (NSString *fileName in allFileName) {
        NSRange range = [fileName rangeOfString:@"dConnectDeviceChromecast"];
        if ([[fileName pathExtension] isEqualToString:extension]
            && range.location != NSNotFound) {
            [fileManager removeItemAtPath:[directoryPath
                                           stringByAppendingFormat:@"/%@",
                                           fileName]
                                    error:NULL];
        }
    }
}

#pragma mark - GCKDeviceManagerDelegate

// デバイス接続
- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager
{
	// アプリケーションを起動
	[deviceManager launchApplication:kReceiverAppID];
}

- (void)disconnectApplicationForDeviceManager:(GCKDeviceManager *)deviceManager
                   didFailToConnectWithError:(NSError *)error

{
    
    DPChromecastManagerData *data = _dataDict[deviceManager.device.deviceID];
    for (DPChromeCastCallback callback in data.connectCallbacks) {
        callback(NO, [GCKError enumDescriptionForCode:error.code]);
    }
    [self disconnectDeviceWithID:deviceManager.device.deviceID];
    // セマフォ解除
    dispatch_semaphore_signal(_semaphore);

}


// デバイス接続に失敗
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectWithError:(GCKError *)error
{
    [self disconnectApplicationForDeviceManager:deviceManager
        didFailToConnectWithError:error];
}

// アプリケーションに接続
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
			sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication
{
    DPChromecastManagerData *data = _dataDict[deviceManager.device.deviceID];
	
	data.textChannel = [[GCKCastChannel alloc] initWithNamespace:kReceiverNamespace];
	[deviceManager addChannel:data.textChannel];
	
	data.ctrlChannel = [GCKMediaControlChannel new];
	data.ctrlChannel.delegate = self;
	[deviceManager addChannel:data.ctrlChannel];
	
    for (DPChromeCastCallback callback in data.connectCallbacks) {
        callback(YES, nil);
    }
    // セマフォ解除
    dispatch_semaphore_signal(_semaphore);
}

// アプリケーションに接続失敗
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectToApplicationWithError:(NSError *)error
{
    [self disconnectApplicationForDeviceManager:deviceManager
                     didFailToConnectWithError:error];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didDisconnectFromApplicationWithError:(NSError *)error
{
    [self disconnectApplicationForDeviceManager:deviceManager
                     didFailToConnectWithError:error];
}


- (void)deviceManager:(GCKDeviceManager *)deviceManager
didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata;
{
	DPChromecastManagerData *data = _dataDict[deviceManager.device.deviceID];
	if (data.eventCallback) {
		data.eventCallback(data.mediaID);
	}
}

-  (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
didCompleteLoadWithSessionID:(NSInteger)sessionID
{
	[self updateEvent:mediaControlChannel];
}

- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel
   requestDidCompleteWithID:(NSInteger)requestID
{
	[self updateEvent:mediaControlChannel];
}

- (void)mediaControlChannelDidUpdateStatus:(GCKMediaControlChannel *)mediaControlChannel
{
    [self updateEvent:mediaControlChannel];
}

- (void)updateEvent:(GCKMediaControlChannel *)mediaControlChannel
{
	for (DPChromecastManagerData *data in _dataDict.allValues) {
		if (data.ctrlChannel == mediaControlChannel) {
			if (data.eventCallback) {
				data.eventCallback(data.mediaID);
			}
			break;
		}
	}
}

/*
 数値判定。
 */
- (BOOL)existNumberWithString:(NSString *)numberString Regex:(NSString*)regex {
    NSRange match = [numberString rangeOfString:regex options:NSRegularExpressionSearch];
    //数値の場合
    return match.location != NSNotFound;
}

// 整数かどうかを判定する。 true:存在する
- (BOOL)existDigitWithString:(NSString*)digit {
    return [self existNumberWithString:digit Regex:kDPChromeRegexDigit];
}

// 少数かどうかを判定する。
- (BOOL)existDecimalWithString:(NSString*)decimal {
    return [self existNumberWithString:decimal Regex:kDPChromeRegexDecimalPoint];
}

// MimeTypeの判定をする。
- (BOOL)existMimeTypeWithString:(NSString*)mimeType {
    return [self existNumberWithString:mimeType Regex:kDPChromeMimeType];
}

@end
