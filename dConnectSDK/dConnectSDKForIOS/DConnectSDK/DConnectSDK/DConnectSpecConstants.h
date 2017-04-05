//
//  DConnectSpecConstants.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectMessage.h>

typedef enum {
    ONESHOT = 0,
    EVENT,
    STREAMING,
} DConnectSpecType;

typedef enum {
    GET = 0,
    PUT,
    POST,
    DELETE,
} DConnectSpecMethod;

typedef enum {
    ARRAY = 0,
    BOOLEAN,
    INTEGER,
    NUMBER,
    STRING,
    FILE_,
} DConnectSpecDataType;

typedef enum {
    INT32,
    INT64,
    FLOAT,
    DOUBLE,
    TEXT,
    BYTE,
    BINARY,
    DATE,
    DATE_TIME,
    PASSWORD,
    RGB,
} DConnectSpecDataFormat;


extern NSString * const DConnectSpecTypeOneshot;
extern NSString * const DConnectSpecTypeEvent;
extern NSString * const DConnectSpecTypeStreaming;

extern NSString * const DConnectSpecMethodGet;
extern NSString * const DConnectSpecMethodPut;
extern NSString * const DConnectSpecMethodPost;
extern NSString * const DConnectSpecMethodDelete;

extern NSString * const DConnectSpecDataTypeArray;
extern NSString * const DConnectSpecDataTypeBoolean;
extern NSString * const DConnectSpecDataTypeInteger;
extern NSString * const DConnectSpecDataTypeNumber;
extern NSString * const DConnectSpecDataTypeString;
extern NSString * const DConnectSpecDataTypeFile;

extern NSString * const DConnectSpecDataFormatInt32;
extern NSString * const DConnectSpecDataFormatInt64;
extern NSString * const DConnectSpecDataFormatFloat;
extern NSString * const DConnectSpecDataFormatDouble;
extern NSString * const DConnectSpecDataFormatText;
extern NSString * const DConnectSpecDataFormatByte;
extern NSString * const DConnectSpecDataFormatBinary;
extern NSString * const DConnectSpecDataFormatDate;
extern NSString * const DConnectSpecDataFormatDateTime;
extern NSString * const DConnectSpecDataFormatPassword;
extern NSString * const DConnectSpecDataFormatRGB;

extern NSString * const DConnectSpecBoolFalse;
extern NSString * const DConnectSpecBoolTrue;

#define DConnectSpecTypes() @[DConnectSpecTypeOneshot, DConnectSpecTypeEvent, DConnectSpecTypeStreaming]

#define DConnectSpecMethods() @[DConnectSpecMethodGet, DConnectSpecMethodPut, DConnectSpecMethodPost, DConnectSpecMethodDelete]

#define DConnectSpecDataTypes() @[DConnectSpecDataTypeArray, DConnectSpecDataTypeBoolean, DConnectSpecDataTypeInteger, DConnectSpecDataTypeNumber, DConnectSpecDataTypeString, DConnectSpecDataTypeFile]

#define DConnectSpecDataFormats() @[DConnectSpecDataFormatInt32, DConnectSpecDataFormatInt64, DConnectSpecDataFormatFloat, DConnectSpecDataFormatDouble, DConnectSpecDataFormatText, DConnectSpecDataFormatByte, DConnectSpecDataFormatBinary, DConnectSpecDataFormatDate, DConnectSpecDataFormatDateTime, DConnectSpecDataFormatPassword, DConnectSpecDataFormatRGB]

#define DConnectSpecBools() @[DConnectSpecBoolFalse,DConnectSpecBoolTrue]

#define DConnectSpecBoolValues()    {NO, YES}


/*!
 @class DConnectSpecConstants
 @brief Device Connect APIを定義する上で使用される定数、ユーティリティ関数を提供する。
 */
@interface DConnectSpecConstants : NSObject

/*!
 @brief 文字列をDConnectSpecTypeに変換する。
 @param[in] strType 文字列
 @param[out] outType DConnectSpecType
 @param[out] error 変換時のエラー
 @return 変換に成功した場合はYES、失敗した場合はNO
 */
+ (BOOL) parseType: (NSString *)strType outType: (DConnectSpecType *) outType error: (NSError **) error;

/*!
 @brief DConnectSpecTypeを文字列に変換する。
 @param[in] type DConnectSpecType
 @param[out] error 変換時のエラー
 @return 文字列
 */
+ (NSString *) toTypeString: (DConnectSpecType)type error:(NSError **) error;

/*!
 @brief 文字列をDConnectSpecMethodに変換する。
 @param[in] strMethod 文字列
 @param[out] outMethod DConnectSpecMethod
 @param[out] error 変換時のエラー
 @return 変換に成功した場合はYES、失敗した場合はNO
 */
+ (BOOL) parseMethod: (NSString *)strMethod outMethod: (DConnectSpecMethod *) outMethod error: (NSError **) error;

/*!
 @brief DConnectMessageActionTypeをDConnectSpecMethodに変換する。
 @param[in] method DConnectMessageActionType
 @param[out] outMethod DConnectSpecMethod
 @param[out] error 変換時のエラー
 @return 変換に成功した場合はYES、失敗した場合はNO
 */
+ (BOOL) toMethodFromAction: (DConnectMessageActionType) method outMethod: (DConnectSpecMethod *) outMethod error: (NSError **) error;

/*!
 @brief DConnectSpecMethodを文字列に変換する。
 @param[in] method DConnectSpecMethod
 @param[out] error 変換時のエラー
 @return 文字列
 */
+ (NSString *) toMethodString: (DConnectSpecMethod)method error: (NSError **) error;

/*!
 @brief 文字列をDConnectSpecDataTypeに変換する。
 @param[in] strDataType 文字列
 @param[out] outDataType DConnectSpecDataType
 @param[out] error 変換時のエラー
 @return 変換に成功した場合はYES、失敗した場合はNO
 */
+ (BOOL) parseDataType: (NSString *)strDataType outDataType: (DConnectSpecDataType *) outDataType error: (NSError **) error;

/*!
 @brief DConnectSpecDataTypeを文字列に変換する。
 @param[in] dataType DConnectSpecDataType
 @param[out] error 変換時のエラー
 @return 文字列
 */
+ (NSString *) toDataTypeString: (DConnectSpecDataType)dataType error:(NSError **) error;

/*!
 @brief 文字列をDConnectSpecDataFormatに変換する。
 @param[in] strDataFormat 文字列
 @param[out] outDataFormat DConnectSpecDataFormat
 @param[out] error 変換時のエラー
 @return 変換に成功した場合はYES、失敗した場合はNO
 */
+ (BOOL) parseDataFormat: (NSString *)strDataFormat outDataFormat: (DConnectSpecDataFormat *) outDataFormat error:(NSError **) error;

/*!
 @brief DConnectSpecDataFormatを文字列に変換する。
 @param[in] dataFormat DConnectSpecDataFormat
 @param[out] error 変換時のエラー
 @return 文字列
 */
+ (NSString *) toDataFormatString: (DConnectSpecDataFormat)dataFormat error:(NSError **)error;

/*!
 @brief オブジェクトのインスタンスをBOOLに変換する。
 @param[in] 変換元のインスタンス
 @param[out] 変換先のBOOLへのポインタ
 @param[out] 変換時のエラー
 @return 変換に成功した場合はYES、失敗した場合はNO
 */
+ (BOOL) parseBool: (id)idBool outBoolValue: (BOOL *)outBoolValue error:(NSError **) error;

/*!
 @brief 指定された文字列が整数値を表現しているかどうかを返す。
 @param[in] text 文字列
 @return 整数値表現である場合はYES、そうでない場合はNO
 */
+ (BOOL) isDigit:(NSString *)text;

/*!
 @brief 指定された文字列が実数値を表現しているかどうかを返す。
 @param[in] text 文字列
 @return 実数値表現である場合はYES、そうでない場合はNO
 */
+ (BOOL) isNumber:(NSString *)text;

@end
