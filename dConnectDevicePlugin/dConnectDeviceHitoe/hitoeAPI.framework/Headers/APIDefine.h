/**
 * Copyright(c) 2015 NTT DOCOMO, INC. All Rights Reserved.
 */

#ifndef APIDefine_h
#define APIDefine_h

#import <Foundation/Foundation.h>

@interface APIDefine : NSObject

// コールバック識別用のID
extern int const kAPI_ID_GET_AVAIRABLE_SENSOR;// getAvairableSensor
extern int const kAPI_ID_CONNECT;// connect
extern int const kAPI_ID_DISCONNECT;// disconnect
extern int const kAPI_ID_GET_AVAIRABLE_DATA;// getAvailableData
extern int const kAPI_ID_ADD_RECIVER;// addReciever
extern int const kAPI_ID_REMOVE_RECEIVER;// removeReciever
extern int const kAPI_ID_GET_STATUS;// getStatus

// 応答ID
extern int const kRES_ID_SUCCESS;// 成功
extern int const kRES_ID_FAILURE;// 失敗
extern int const kRES_ID_CONTINUE;// 継続
extern int const kRES_ID_API_BUSY;// API実行中
extern int const kRES_ID_INVALID_ARG;// 引数不正
extern int const kRES_ID_INVALID_PARAM;// パラメータ不正
extern int const kRES_ID_SENSOR_CONNECT;// センサー接続完了
extern int const kRES_ID_SENSOR_CONNECT_FAILURE;// センサー接続失敗
extern int const kRES_ID_SENSOR_UNAUTHORIZED;// センサー認証失敗
extern int const kRES_ID_SENSOR_DISCONECT;// センサー切断完了

// デバイス名
extern NSString * const kDEVICE_NAME_HITOE_TX;

// データキー種別
extern NSString * const kDATA_KEY_PREF_RAW;
extern NSString * const kDATA_KEY_PREF_RAW_DOT;
extern NSString * const kDATA_KEY_PREF_BASIC;
extern NSString * const kDATA_KEY_PREF_BASIC_DOT;
extern NSString * const kDATA_KEY_PREF_EXTENSION;
extern NSString * const kDATA_KEY_PREF_EXTENSION_DOT;

extern int const kDATA_KEY_RAW;    // RAWのデータキー
extern int const kDATA_KEY_BASIC;    // 基本分析のデータキー
extern int const kDATA_KEY_EXTENSION;    // 拡張分析のデータキー
extern int const kDATA_KEY_OTHER;

extern NSString * const kMODE_REALTIME_STR;
extern NSString * const kMODE_MEMORY_SET_STR;
extern NSString * const kMODE_MEMORY_GET_STR;

extern int const kMODE_REALTIME;
extern int const kMODE_MEMORY_SET;
extern int const kMODE_MEMORY_GET;

extern NSString * const kRAW_DATA_TYPE_ECG_STR;
extern NSString * const kRAW_DATA_TYPE_ACC_STR;
extern NSString * const kRAW_DATA_TYPE_RRI_STR;
extern NSString * const kRAW_DATA_TYPE_BAT_STR;
extern NSString * const kRAW_DATA_TYPE_HR_STR;
extern NSString * const kRAW_DATA_TYPE_SAVED_HR_STR;
extern NSString * const kRAW_DATA_TYPE_SAVED_RRI_STR;

extern int const kRAW_DATA_TYPE_HR;
extern int const kRAW_DATA_TYPE_RRI;
extern int const kRAW_DATA_TYPE_ECG;
extern int const kRAW_DATA_TYPE_ACC;
extern int const kRAW_DATA_TYPE_BAT;
extern int const kRAW_DATA_TYPE_SAVED_HR;
extern int const kRAW_DATA_TYPE_SAVED_RRI;

extern NSString * const kSTR_SEARCH_TIME;
extern NSString * const kSTR_PINCODE;
extern NSString * const kSTR_DISCONNECT_RETRY_TIME;
extern NSString * const kSTR_DISCONNECT_RETRY_COUNT;
extern NSString * const kSTR_RECORDING_DATA;

extern NSString * const kSTR_RECORDING_DATA_TYPE_HR;
extern NSString * const kSTR_RECORDING_DATA_TYPE_RRI;

extern NSString * const kSTR_SESSION_PREFIX;
extern NSString * const kSTR_CONNECTION_R_PREFIX;
extern NSString * const kSTR_CONNECTION_B_PREFIX;
extern NSString * const kSTR_CONNECTION_E_PREFIX;

extern int const kPINCODE_LOWER;
extern int const kPINCODE_UPPER;

extern int const kDISCONNECT_RETRY_TIME_LOWER;
extern int const kDISCONNECT_RETRY_TIME_UPPER;
extern int const kDISCONNECT_RETRY_COUNT_LOWER;
extern int const kDISCONNECT_RETRY_COUNT_UPPER;

extern int const kSEARCH_TIME_LOWER;
extern int const kSEARCH_TIME_UPPER;
extern int const kSEARCH_TIME_DEFAULT;

extern NSArray * const kAVAILABLE_SENSOR_ID_LIST;
extern NSArray * const kAVAILABLE_SENSOR_PREFIX;

@end

#endif /* APIDefine_h */
