//
//
//  DPSpheroManager.h
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectServiceProvider.h>

/*!
 @brief 3次元構造体
 */
typedef struct DPPoint3D_ {
    float x, y, z;
} DPPoint3D;

/*!
 @brief クオータニオン構造体
 */
typedef struct DPQuaternion_ {
    float q0, q1, q2, q3;
} DPQuaternion;

/*!
 @brief ジャイロデータ構造体
 */
typedef struct DPGyroData_ {
    double x, y, z;
} DPGyroData;

/*!
 @brief Spheroのセンサー処理用デリゲート。
 */
@protocol DPSpheroManagerSensorDelegate <NSObject>

/*!
 @brief SpheroのQuaternionを通知する。
 
 @param[in] q Quaternion
 @param[in] interval Quaternionを通知する間隔
 */
- (void)spheroManagerStreamingQuaternion:(DPQuaternion)q
                                interval:(int)interval;

/*!
 @brief SpheroのLocatorを通知する。
 
 @param[in] pos Locatorの位置
 @param[in] velocity Locatorの速度座標
 @param[in] interval Locatorを通知する間隔
 */
- (void)spheroManagerStreamingLocatorPos:(CGPoint)pos
                                velocity:(CGPoint)velocity
                                interval:(int)interval;
/*!
 @brief SpheroのCollisionを通知する。
 
 @param[in] accel Collisionの加速度
 @param[in] axis Collisionの軸
 @param[in] power Collisionの力
 @param[in] speed Collisionの速度
 @param[in] time Collisionを通知する間隔
 */
- (void)spheroManagerStreamingCollisionImpactAcceleration:(DPPoint3D)accel
                                                     axis:(CGPoint)axis
                                                    power:(CGPoint)power
                                                    speed:(float)speed
                                                     time:(NSTimeInterval)time;
@end

/*!
 @brief Spheroの加速度・傾きセンサー処理用デリゲート。
 */
@protocol DPSpheroManagerOrientationDelegate <NSObject>

/*!
 @brief Spheroの加速度・ジャイロセンサーを通知する。
 @param[in]  ジャイロデータ構造体
 @param[in] accel 加速度
 @param[in] interval このセンサー値を通知する間隔
 */
- (void)spheroManagerStreamingOrientation:(DPGyroData)gyroData
                                    accel:(DPPoint3D)accel
                                 interval:(int)interval;
@end



/*!
 @brief Spheroの制御クラス
 */
@interface DPSpheroManager : NSObject

/*!
 @brief ServiceProvider.
 */
@property (nonatomic, weak) DConnectServiceProvider *serviceProvider;

/*!
 @brief DevicePlugin.
 */
@property (nonatomic, weak) id plugin;

/*!
 @brief Spheroのセンサー処理用デリゲート。
 */
@property (nonatomic, weak) id<DPSpheroManagerSensorDelegate> sensorDelegate;
/*!
 @brief Spheroの加速度・傾きセンサー処理用デリゲート。
 */
@property (nonatomic, weak) id<DPSpheroManagerOrientationDelegate> orientationDelegate;

/*!
 @brief キャリブレーションライトの明るさ。
 */
@property (nonatomic) float calibrationLightBright;

/*!
 @brief LEDの色。
 */
@property (nonatomic) UIColor* LEDLightColor;

/*!
 @brief LEDが付いているか。
 */
@property (nonatomic, readonly) BOOL isLEDOn;

/*!
 @brief 接続中のサービスID取得。
 */
@property (nonatomic, readonly) NSString *currentServiceID;

/*!
 @brief 接続可能なデバイスリスト取得。
 */
@property (nonatomic, readonly) NSArray *deviceList;

/*!
 @brief アクティベート済みか。
 */
@property (nonatomic, readonly) BOOL isActivated;


/*!
 @brief DPSpheroManagerの共有インスタンスを返す。
 @return DPSpheroManagerの共有インスタンス。
 */
+ (instancetype)sharedManager;


- (void) setServiceProvider: (DConnectServiceProvider *) serviceProvider;

/*!
 @brief アプリがバックグラウンドに入った。
 */
- (void)applicationDidEnterBackground ;

/*!
 @brief アプリがフォアグラウンドに入った
 */
- (void)applicationWillEnterForeground;

/*!
 @brief 有効化。
 */
- (BOOL)activate;

/*!
 @brief 無効化。
 */
- (void)deactivate;

/*!
 @brief デバイスに接続。
 */
- (BOOL)connectDeviceWithID:(NSString*)serviceID;

/*!
 @brief 移動。
 */
- (void)move:(float)angle
    velocity:(float)velocity;

/*!
 @brief 回転。
 */
- (void)rotate:(float)angle;

/*!
 @brief 停止。
 */
- (void)stop;


/*!
 @brief 姿勢センサーのスタート。
 */
- (void)startSensorOrientation;

/*!
 @brief 姿勢センサーのストップ。
 */
- (void)stopSensorOrientation;

/*!
 @brief Quaternionセンサーのスタート。
 */
- (void)startSensorQuaternion;

/*!
 @brief Quaternionセンサーのストップ。
 */
- (void)stopSensorQuaternion;

/*!
 @brief Locatorセンサーのスタート。
 */
- (void)startSensorLocator;

/*!
 @brief Locatorセンサーのストップ。
 */
- (void)stopSensorLocator;

/*!
 @brief Collisionセンサーのスタート。
 */
- (void)startSensorCollision;

/*!
 @brief Collisionセンサーのストップ。
 */
- (void)stopSensorCollision;

/*!
 @brief 全センサー停止。
 */
- (void)stopAllSensor;

/*!
 @brief 整数かどうかを判定する。
 */
- (BOOL)existDigitWithString:(NSString*)digit;

/*!
 @brief 少数かどうかを判定する。
 */
- (BOOL)existDecimalWithString:(NSString*)decimal;



/*!
 @brief Observerの登録。
 */
- (void)addResponseObserver;
/*!
 @brief Observerの削除。
 */
- (void)removeResponseObserver;


/*!
 @brief デバイス管理情報更新
 */
- (void) updateManageServices;


@end
