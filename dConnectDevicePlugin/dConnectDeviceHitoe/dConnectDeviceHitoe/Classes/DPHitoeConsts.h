//
//  DPHitoeConsts.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#pragma mark - Sensor define
/*!
 @brief Bundle名。
 */
extern NSString *const DPHitoeBundleName;

/*!
 @brief \n。
 */
extern NSString *const DPHitoeBR;
/*!
 @brief |。
 */
extern NSString *const DPHitoeVB;
/*!
 @brief ,。
 */
extern NSString *const DPHitoeComma;
/*!
 @brief :。
 */
extern NSString *const DPHitoeColon;

extern NSString *const DPHitoeRawDataPrefix;
extern NSString *const DPHitoeBaDataPrefix;
extern NSString *const DPHitoeExDataPrefix;

extern NSString *const DPHitoeRawConnectionPrefix;
extern NSString *const DPHitoeBaConnectionPrefix;
extern NSString *const DPHitoeExConnectionPrefix;

extern int const DPHitoeExPostureUnitNum;
extern int const DPHitoeExWalkUnitNum;
extern int const DPHitoeExLRBalanceUnitNum;

extern NSString *const DPHitoeSensorDeviceType;
extern long long const DPHitoeSensorParamSearchTime;

extern int const DPHitoeECGSamplingInterval;
extern int const DPHitoeACCSamplingInterval;
extern int const DPHitoeRRISamplingInterval;
extern int const DPHitoeHRSamplingInterval;
extern int const DPHitoeBatSamplingInterval;

extern int const DPHitoeBaSamplingInterval;
extern int const DPHitoeBaECGThreshold;
extern int const DPHitoeBaSkipCount;
extern int const DPHitoeBaRRIMin;
extern int const DPHitoeBaRRIMax;
extern int const DPHitoeBaSampleCount;
extern NSString *const DPHitoeBaRRIInput;
extern int const DPHitoeBaFreqSamplingInterval;
extern int const DPHitoeBaFreqSamplingWindow;
extern int const DPHitoeBaRRISamplingRate;
extern int const DPHitoeBaTimeSamplingInterval;
extern int const DPHitoeBaTimeSamplingWindow;

extern NSString *const DPHitoeExAccAxisXYZ;
extern int const DPHitoeExPostureWinodw;
extern double const DPHitoExWalkStride;
extern double const DPHitoeExRunStrideCOF;
extern double const DPHitoeExRunStrideINT;

extern int const DPHitoeBackForwardThreshold;
extern int const DPHitoeLeftRightThreshold;


extern int const DPHitoeChartTitleSize;
extern int const DPHitoeLabesSize;



#pragma mark - APIDefine

extern int const DPHitoeApiIdGetAvailableSensor;
extern int const DPHitoeApiIdConnect;
extern int const DPHitoeApiIdDisconnect;
extern int const DPHitoeApiIdGetAvailableData;
extern int const DPHitoeApiIdAddReceiver;
extern int const DPHitoeApiIdRemoveReceiver;
extern int const DPHitoeApiIdGetStatus;

/*!
 @brief 成功。
 */
extern int const DPHitoeResIdSuccess;
/*!
 @brief 失敗。
 */
extern int const DPHitoeResIdFailure;
/*!
 @brief 継続。
 */
extern int const DPHitoeResIdContinue;

/*!
 @brief 引数不正。
 */
extern int const DPHitoeResIdInvalidArg;

/*!
 @brief 引数過不足。
 */
extern int const DPHitoeResIdInsufficientArg;

/*!
 @brief パラメータ不正。
 */
extern int const DPHitoeResIdInvalidParam;

/*!
 @brief パラメータ過不足。
 */
extern int const DPHitoeResIdInsufficientParam;

/*!
 @brief センサー接続完了。
 */
extern int const DPHitoeResIdSensorConnect;

/*!
 @brief センサー接続失敗。
 */
extern int const DPHitoeResIdSensorConnectFailure;

/*!
 @brief センサー接続検知。
 */
extern int const DPHitoeResIdSensorConnectNotice;

/*!
 @brief センサー切断完了。
 */
extern int const DPHitoeResIdSensorDisconnect;

/*!
 @brief センサー切断検知。
 */
extern int const DPHitoeResIdSensorDisconnectNotice;


extern NSString *const DPHitoeDeviceNameHitoeTX;
extern int const DPHitoeDeviceTypeUnknown;
extern int const DPHitoeDeviceTypeHitoeTx;

extern int const DPHitoeDataKeyRaw;
extern int const DPHitoeDataKeyBasic;
extern int const DPHitoeDataKeyExtension;



#define DPHitoeBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:DPHitoeBundleName ofType:@"bundle"]]

#define DPHitoeLocalizedString(bundle, key) \
[bundle localizedStringForKey:key value:@"" table:nil]

#define IPHONE4_H 480
