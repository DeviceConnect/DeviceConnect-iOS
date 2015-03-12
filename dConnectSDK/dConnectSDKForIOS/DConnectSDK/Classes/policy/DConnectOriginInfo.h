//
//  DConnectOriginInfo.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectOrigin.h"

/*!
 @enum DConnectOriginError
 @brief Originの管理上のエラー定義。
 */
typedef NS_ENUM(NSUInteger, DConnectOriginError) {
    DConnectOriginErrorNone,                /*!< エラー無し */
    DConnectOriginErrorInvalidParameter,	/*!< 不正なパラメータ */
    DConnectOriginErrorNotFound,       		/*!< マッチするオリジン無し */
    DConnectOriginErrorFailed,            	/*!< 処理失敗 */
};

@interface DConnectOriginInfo : NSObject

@property id<DConnectOrigin>origin;
@property NSString *title;
@property long date;
@property long long rowId;

- (BOOL) matches:(id<DConnectOrigin>) origin;

@end
