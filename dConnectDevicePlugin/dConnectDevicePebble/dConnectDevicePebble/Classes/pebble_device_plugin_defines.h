//
//  pebble_device_plugin_defines.h
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#ifndef pebble_defines_h
#define pebble_defines_h

// MEMO: Java の PebbleManager.java で同じ定義があるので、
//       ここを編集する場合にはJavaファイルも修正すること。

/////////////////// 共通

/*! @define プロファイル。 */
#define KEY_PROFILE 1
/*! @define インターフェース。 */
#define KEY_INTERFACE 2
/*! @define アトリビュート。 */
#define KEY_ATTRIBUTE 3
/*! @define アクション。 */
#define KEY_ACTION 4

/*! @define リザルトコード. */
#define KEY_PARAM_RESULT 100
/*! @define エラーコード. */
#define KEY_PARAM_ERROR_CODE 101
/*! @define リクエストコード。 */
#define KEY_PARAM_REQUEST_CODE 102

/////////////////// battery

/*! @define バッテリーチャージングフラグ。 */
#define KEY_PARAM_BATTERY_CHARGING 200
#define KEY_PARAM_BATTERY_LEVEL 201

/////////////////// binary
#define KEY_PARAM_BINARY_LENGTH 300
#define KEY_PARAM_BINARY_INDEX 301
#define KEY_PARAM_BINARY_BODY 302

/////////////////// device orientation
#define KEY_PARAM_DEVICE_ORIENTATION_X 400
#define KEY_PARAM_DEVICE_ORIENTATION_Y 401
#define KEY_PARAM_DEVICE_ORIENTATION_Z 402
#define KEY_PARAM_DEVICE_ORIENTATION_INTERVAL 403

////////// setting

#define KEY_PARAM_SETTING_DATE 600

////////// vibration

#define KEY_PARAM_VIBRATION_LEN 500
#define KEY_PARAM_VIBRATION_PATTERN 501

///////// key event
/** Key number of KeyID.*/
#define KEY_PARAM_KEY_EVENT_ID 700
/** Key number of KeyType.*/
#define KEY_PARAM_KEY_EVENT_KEY_TYPE 701
/** Key number of KeyState.*/
#define KEY_PARAM_KEY_EVENT_KEY_STATE 702
///////////////////////////////////////////////////////////////////

/*! @define GETアクション。 */
#define ACTION_GET 1
/*! @define POSTアクション。 */
#define ACTION_POST 2
/*! @define PUTアクション。 */
#define ACTION_PUT 3
/*! @define DELETEアクション。 */
#define ACTION_DELETE 4
/*! @define イベントアクション。 */
#define ACTION_EVENT 5


///////////////////////////////////////////////////////////////////

/*! @define バッテリープロファイル。 */
#define PROFILE_BATTERY 1
/*! @define Device Orientationプロファイル。 */
#define PROFILE_DEVICE_ORIENTATION 2
/*! @define バイブレーションプロファイル。 */
#define PROFILE_VIBRATION 3
/*! @define Settingsプロファイル。 */
#define PROFILE_SETTING 4
/*! @define Systemプロファイル。 */
#define PROFILE_SYSTEM 5
/*! @define Canvas プロファイル。canvas 用. */
#define PROFILE_CANVAS 6
/**! @define Numeric value that represents the key event profile. */
#define PROFILE_KEY_EVENT 7
/*! バイナリを送るためのプロファイル。 */
#define PROFILE_BINARY 255

///////////////////////////////////////////////////////////////////

////////// battery

#define BATTERY_ATTRIBUTE_ALL 1
#define BATTERY_ATTRIBUTE_CHARING 2
#define BATTERY_ATTRIBUTE_LEVEL 3
#define BATTERY_ATTRIBUTE_ON_BATTERY_CHANGE 4
#define BATTERY_ATTRIBUTE_ON_CHARGING_CHANGE 5

////////// device orientation

#define DEVICE_ORIENTATION_ATTRIBUTE_ON_DEVICE_ORIENTATION 1

////////// setting

#define SETTING_ATTRIBUTE_VOLUME 1
#define SETTING_ATTRIBUTE_DATE 2

////////// system
#define SYSTEM_ATTRIBUTE_EVENTS 1

//iPhone4の画面サイズ（高さ）
#define IPONE4_H 480

//設定画面のページ数（iPhone）
#define SETTING_PAGE_COUNT_IPHNE 5

//設定画面のページ数（iPad）
#define SETTING_PAGE_COUNT_IPAD 3

////////// vibration

#define VIBRATION_ATTRIBUTE_VIBRATE 1

////////// canvas

#define CANVAS_DRAW_IMAGE 1

///////// key event
/** key event attribute ondown. */
#define KEY_EVENT_ATTRIBUTE_ON_DOWN 1

/** key event attribute onup. */
#define KEY_EVENT_ATTRIBUTE_ON_UP 2

/** key event attribute onup. */
#define KEY_EVENT_ATTRIBUTE_ON_KEY_CHANGE 3

/** key event action down. */
#define KEY_EVENT_ACTION_DOWN 1

/** key event action up. */
#define KEY_EVENT_ACTION_UP 2

/** key event key ID up. */
#define KEY_EVENT_KEY_ID_UP 1

/** key event key ID select. */
#define KEY_EVENT_KEY_ID_SELECT 2

/** key event key ID down. */
#define KEY_EVENT_KEY_ID_DOWN 3

/** key event key ID back. */
#define KEY_EVENT_KEY_ID_BACK 4

/** key event key type STD_KEY. */
#define KEY_EVENT_KEY_TYPE_STD_KEY 1

/** key event key type MEDIA. */
#define KEY_EVENT_KEY_TYPE_MEDIA 2

/** key event key type DPAD_BUTTON. */
#define KEY_EVENT_KEY_TYPE_DPAD_BUTTON 3

/** key event key type USER. */
#define KEY_EVENT_KEY_TYPE_USER 4

///////////////////////////////////////////////////////////////////

#define RESULT_OK 1
#define RESULT_ERROR 2

#define BATTERY_CHARGING_ON 1
#define BATTERY_CHARGING_OFF 2

#define ERROR_NOT_SUPPORT_PROFILE 1
#define ERROR_NOT_SUPPORT_INTERFACE 2
#define ERROR_NOT_SUPPORT_ATTRIBUTE 3
#define ERROR_NOT_SUPPORT_ACTION 4
#define ERROR_ILLEGAL_PARAMETER 5

#define RETURN_SYNC 1
#define RETURN_ASYNC 2

/*! バイナリーサイズ。 */
#define BINARY_BUF_SIZE 64

/*!
 @define バイブレーションパターン数の最大数。
 PebbleのDictionaryに入れられる最大が64byteなので、
 64 / 2 = 16までしか入らない。
 */
#define VIBRATION_PATTERN_SIZE 32


#define PEBBLE_SCREEN_WIDTH 144
#define PEBBLE_SCREEN_HEIGHT 168

// MEMO: ここまで、定数の宣言を終了

#endif	/* pebble_defines_h */
