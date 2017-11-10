//
//  DPHostRecorderManager.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectFileManager.h>

#import "DPHostRecorder.h"
#import "DPHostPhotoRecorder.h"
#import "DPHostStreamRecorder.h"

@interface DPHostRecorderManager : NSObject
// Recorderの作成
- (void)createRecorders;
// Recorderの初期化
- (void)initialize;
// Recorderの削除
- (void)clean;
// すべてのRecorderを取得する
- (NSArray*)getRecorders;
// Recorderを取得する
- (DPHostRecorder*)getRecorderForRecorderId:(NSString*)recorderId;
// CameraのRecorderを取得する
- (DPHostPhotoRecorder*)getCameraRecorderForRecorderId:(NSString*)recorderId;
// VideoのRecorderを取得する
- (DPHostStreamRecorder*)getVideoRecorderForRecorderId:(NSString*)recorderId;
// 使用中のRecorderを返す
- (NSString *)usedRecorder;
@end
