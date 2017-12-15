//
//  DConnectRFC3339DateUtils.h
//  DConnectSDK
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

/*!
 @file
 @brief RFC3339形式の日付データをを利用するためのユーティリティ機能を提供する。
 @author NTT DOCOMO
 */
@interface DConnectRFC3339DateUtils : NSObject
/*!
 @brief long型のTimeStampからRFC3339形式の文字列を生成する。
 
 @param[in] timeStamp long型のtimeStamp
 @param[in] locale timeStampのLocale
 @param[in] timeZone timeStampのTimeZone
 */
+ (NSString *) stringWithTimeStamp:(long)timeStamp locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone;

/*!
 @brief NSDateオブジェクトからRFC3339形式の文字列を生成する。
 
 @param[in] date NSDateオブジェクト
 @param[in] locale timeStampのLocale
 @param[in] timeZone timeStampのTimeZone
 */
+ (NSString *) stringWithDate:(NSDate*)date locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone;

/*!
 @brief RFC3339形式の文字列からlong型のTimeStampを生成する。
 
 @param[in] timeStampString RFC3339形式の文字列
 @param[in] locale timeStampのLocale
 @param[in] timeZone timeStampのTimeZone
 */
+ (long)timeStampWithString:(NSString*)timeStampString locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone;

/*!
 @brief RFC3339形式の文字列からNSDateオブジェクトを生成する。
 
 @param[in] timeStampString RFC3339形式の文字列
 @param[in] locale timeStampのLocale
 @param[in] timeZone timeStampのTimeZone
 */
+ (NSDate *) dateWithString:(NSString*)timeStampString locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone;


/*!
 @brief long型のTimeStampからRFC3339形式の文字列を生成する。localeとTimezoneはスマートフォンに設定されているものが設定される。
 
 @param[in] timeStamp long型のtimeStamp
 */
+ (NSString *) stringWithTimeStamp:(long)timeStamp;

/*!
 @brief NSDateオブジェクトからRFC3339形式の文字列を生成する。localeとTimezoneはスマートフォンに設定されているものが設定される。
 
 @param[in] date NSDateオブジェクト
 */
+ (NSString *) stringWithDate:(NSDate*)date;

/*!
 @brief RFC3339形式の文字列からlong型のTimeStampを生成する。localeとTimezoneはスマートフォンに設定されているものが設定される。
 
 @param[in] timeStampString RFC3339形式の文字列
 */
+ (long) timeStampWithString:(NSString*)timeStampString;
/*!
 @brief RFC3339形式の文字列からNSDateオブジェクトを生成する。localeとTimezoneはスマートフォンに設定されているものが設定される。
 
 @param[in] timeStampString RFC3339形式の文字列
 */
+ (NSDate *) dateWithString:(NSString*)timeStampString;

/*!
 @brief 現在のタイムスタンプをRFC3339形式の文字列に変換して生成する。localeとTimezoneはスマートフォンに設定されているものが設定される。
 */
+ (NSString*)nowTimeStampString;
@end
