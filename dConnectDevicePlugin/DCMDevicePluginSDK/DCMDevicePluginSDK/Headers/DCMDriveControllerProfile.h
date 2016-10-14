//
//  DCMDriveControllerProfileName.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
/*! @file
 @brief DriveControllerプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 @date 作成日(2014.7.22)
 */
#import <DConnectSDK/DConnectSDK.h>
/*! @brief プロファイル名: driveController。 */
extern NSString *const DCMDriveControllerProfileName;
/*!
 @brief 属性: move。
 */
extern NSString *const DCMDriveControllerProfileAttrMove;
/*!
 @brief 属性: stop。
 */
extern NSString *const DCMDriveControllerProfileAttrStop;
/*!
 @brief 属性: rotate。
 */
extern NSString *const DCMDriveControllerProfileAttrRotate;
/*!
 @brief パラメータ: angle。
 */
extern NSString *const DCMDriveControllerProfileParamAngle;
/*!
 @brief パラメータ: speed。
 */
extern NSString *const DCMDriveControllerProfileParamSpeed;

/*!
 @class DCMDriveControllerProfile
 @brief DriveControllerプロファイル。
 
 DriveController Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMDriveControllerProfile : DConnectProfile

@end
