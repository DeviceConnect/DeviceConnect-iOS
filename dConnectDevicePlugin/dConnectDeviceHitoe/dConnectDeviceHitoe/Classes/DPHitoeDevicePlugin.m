//
//  DPHitoeDevicePlugin.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeDevicePlugin.h"
#import "DPHitoeConsts.h"
// Const.h
NSString *const DPHitoeBundleName = @"dConnectDeviceHitoe_resources";


NSString *const DPHitoeBR = "\n";
NSString *const DPHitoeVB = "|";
NSString *const DPHitoeComma = ",";
NSString *const DPHitoeColon = ":"

NSString *const DPHitoeRawDataPrefix = "raw.";
NSString *const DPHitoeBaDataPrefix = "ba.";
NSString *const DPHitoeExDataPrefix = "ex.";

NSString *const DPHitoeRawConnectionPrefix = "R";
NSString *const DPHitoeBaConnectionPrefix = "B";
NSString *const DPHitoeExConnectionPrefix = "E";

int const DPHitoeExPostureUnitNum = 30;
int const DPHitoeExWalkUnitNum = 110;
int const DPHitoeExLRBalanceUnitNum = 280;

NSString *const DPHitoeSensorDeviceType = "hitoe D01";
NSString *const DPHitoeSensorParamSearchTime = 5000;

int const DPHitoeECGSamplingInterval = 40;
int const DPHitoeACCSamplingInterval = 40;
int const DPHitoeRRISamplingInterval = 1000;
int const DPHitoeHRSamplingInterval = 1000;
int const DPHitoeBatSamplingInterval = 10000;

int const DPHitoeBaSamplingInterval = 4000;
int const DPHitoeBaECGThreshold = 250;
int const DPHitoeBaSkipCount = 50;
int const DPHitoeBaRRIMin = 240;
int const DPHitoeBaRRIMax = 3999;
int const DPHitoeBaSampleCount = 20;
NSString *const DPHitoeBaRRIInput = "extracted_rri";
int const DPHitoeBaFreqSamplingInterval = 4000;
int const DPHitoeBaFreqSamplingWindow = 60;
int const DPHitoeBaRRISamplingRate = 8;
int const DPHitoeBaTimeSamplingInterval = 4000;
int const DPHitoeBaTimeSamplingWindow = 60;

NSString *const DPHitoeExAccAxisXYZ = "XYZ=XYZ";
int const DPHitoeExPostureWinodw = 1;
double const DPHitoExWalkStride = 0.81;
double const DPHitoeExRunStrideCOF = 0.0091;
double const DPHitoeExRunStrideINT = 0.1806;


int const DPHitoeBackForwardThreshold = 30;
int const DPHitoeLeftRightThreshold = 20;



int const DPHitoeChartTitleSize = 25;
int const DPHitoeLabesSize = 16;
UIColor *const DPHitoeAxisColor = [UIColor whiteColor];
UIColor *const DPHitoeGridColor = [UIColor whiteColor];
UIColor *const DPHitoeTitleColor = [UIColor blackColor];
UIColor *const DPHitoeXLabelColor = [UIColor blackColor];
UIColor *const DPHitoeYLabelColor = [UIColor blackColor];



int const DPHitoeApiIdGetAvailableSensor = 0x1010;
int const DPHitoeApiIdConnect = 0x1020;
int const DPHitoeApiIdDisconnect = 0x1021;
int const DPHitoeApiIdGetAvailableData = 0x1030;
int const DPHitoeApiIdAddReceiver = 0x1040;
int const DPHitoeApiIdRemoveReceiver = 0x1041;
int const DPHitoeApiIdGetStatus = 0x1090;

int const DPHitoeResIdSuccess = 0x00;
int const DPHitoeResIdFailure = 0x01;
int const DPHitoeResIdContinue = 0x05;
int const DPHitoeResIdInvalidArg = 0x10;
int const DPHitoeResIdInsufficientArg = 0x11;
int const DPHitoeResIdInvalidParam = 0x30;
int const DPHitoeResIdInsufficientParam = 0x31;
int const DPHitoeResIdSensorConnect = 0x60;
int const DPHitoeResIdSensorConnectFailure = 0x61;
int const DPHitoeResIdSensorConnectNotice = 0x62;
int const DPHitoeResIdSensorDisconnect = 0x65;
int const DPHitoeResIdSensorDisconnectNotice = 0x66;


NSString *const DPHitoeDeviceNameHitoeTX = "hitoe tx";
int const DPHitoeDeviceTypeUnknown = 0;
int const DPHitoeDeviceTypeHitoeTx = 1;

int const DPHitoeDataKeyRaw = 0x01;
int const DPHitoeDataKeyBasic = 0x02;
int const DPHitoeDataKeyExtension = 0x04;



@implementation DPHitoeDevicePlugin

- (id) init
{
    self = [super init];
    if (self) {
        self.pluginName = @"Hitoe (Device Connect Device Plug-in)";
        
//        [self addProfile:[DPThetaBatteryProfile new]];
//        [self addProfile:[DPThetaFileProfile new]];
//        [self addProfile:[DPThetaMediaStreamRecordingProfile new]];
//        [self addProfile:[DPThetaServiceDiscoveryProfile new]];
//        [self addProfile:[DPThetaSystemProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
        
        
        // イベントマネージャの準備
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key]
         setController:[DConnectDBCacheController
                        controllerWithClass:key]];
        
    }
    
    return self;
}
@end
