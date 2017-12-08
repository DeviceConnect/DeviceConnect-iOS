//
//  DPSpheroProfile.h
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
/*! @file
 @brief Spheroプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 @date 作成日(2014.6.23)
 */
#import <DConnectSDK/DConnectSDK.h>
/*! @brief プロファイル名: sphero。 */
extern NSString *const DPSpheroProfileName;

/*!
 @brief インタフェース: quaternion。
 */
extern NSString *const DPSpheroProfileInterfaceQuaternion;
/*!
 @brief インタフェース: locator。
 */
extern NSString *const DPSpheroProfileInterfaceLocator;
/*!
 @brief インタフェース: collision。
 */
extern NSString *const DPSpheroProfileInterfaceCollision;
/*!
 @brief 属性: onquaternion。
 */
extern NSString *const DPSpheroProfileAttrOnQuaternion;
/*!
 @brief 属性: onlocator。
 */
extern NSString *const DPSpheroProfileAttrOnLocator;
/*!
 @brief 属性: oncollision。
 */
extern NSString *const DPSpheroProfileAttrOnCollision;

/*!
 @brief パラメータ: quaternion。
 */
extern NSString *const DPSpheroProfileParamQuaternion;
/*!
 @brief パラメータ: q0。
 */
extern NSString *const DPSpheroProfileParamQ0;
/*!
 @brief パラメータ: q1。
 */
extern NSString *const DPSpheroProfileParamQ1;
/*!
 @brief パラメータ: q2。
 */
extern NSString *const DPSpheroProfileParamQ2;
/*!
 @brief パラメータ: q3。
 */
extern NSString *const DPSpheroProfileParamQ3;
/*!
 @brief パラメータ: interval。
 */
extern NSString *const DPSpheroProfileParamInterval;
/*!
 @brief パラメータ: flag。
 */
extern NSString *const DPSpheroProfileParamFlag;
/*!
 @brief パラメータ: newX。
 */
extern NSString *const DPSpheroProfileParamNewX;
/*!
 @brief パラメータ: newY。
 */
extern NSString *const DPSpheroProfileParamNewY;
/*!
 @brief パラメータ: newCalibration。
 */
extern NSString *const DPSpheroProfileParamNewCalibration;
/*!
 @brief パラメータ: locator。
 */
extern NSString *const DPSpheroProfileParamLocator;
/*!
 @brief パラメータ: positionX。
 */
extern NSString *const DPSpheroProfileParamPositionX;
/*!
 @brief パラメータ: positionY。
 */
extern NSString *const DPSpheroProfileParamPositionY;
/*!
 @brief パラメータ: velocityX。
 */
extern NSString *const DPSpheroProfileParamVelocityX;
/*!
 @brief パラメータ: velocityY。
 */
extern NSString *const DPSpheroProfileParamVelocityY;
/*!
 @brief パラメータ: xThreshold。
 */
extern NSString *const DPSpheroProfileParamXThreshold;
/*!
 @brief パラメータ: yThreshold。
 */
extern NSString *const DPSpheroProfileParamYThreshold;
/*!
 @brief パラメータ: xSpeedThreshold。
 */
extern NSString *const DPSpheroProfileParamXSpeedThreshold;
/*!
 @brief パラメータ: ySpeedThreshold。
 */
extern NSString *const DPSpheroProfileParamYSpeedThreshold;
/*!
 @brief パラメータ: deadZone。
 */
extern NSString *const DPSpheroProfileParamDeadZone;
/*!
 @brief パラメータ: collision。
 */
extern NSString *const DPSpheroProfileParamCollision;
/*!
 @brief パラメータ: impactAcceleration。
 */
extern NSString *const DPSpheroProfileParamImpactAcceleration;
/*!
 @brief パラメータ: x。
 */
extern NSString *const DPSpheroProfileParamX;
/*!
 @brief パラメータ: y。
 */
extern NSString *const DPSpheroProfileParamY;
/*!
 @brief パラメータ: z。
 */
extern NSString *const DPSpheroProfileParamZ;
/*!
 @brief パラメータ: impactAxis。
 */
extern NSString *const DPSpheroProfileParamImpactAxis;
/*!
 @brief パラメータ: impactPower。
 */
extern NSString *const DPSpheroProfileParamImpactPower;
/*!
 @brief パラメータ: impactSpeed。
 */
extern NSString *const DPSpheroProfileParamImpactSpeed;
/*!
 @brief パラメータ: impactTimeStamp。
 */
extern NSString *const DPSpheroProfileParamImpactTimeStamp;
/*!
 @brief パラメータ: impactTimestamp。
 */
extern NSString *const DPSpheroProfileParamImpactTimeStampString;

/*!
 @class DPSpheroProfile
 @brief Spheroプロファイル。
 
 Sphero Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DPSpheroProfile : DConnectProfile

@end
