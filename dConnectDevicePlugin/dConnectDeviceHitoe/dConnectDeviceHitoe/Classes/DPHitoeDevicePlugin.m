//
//  DPHitoeDevicePlugin.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeDevicePlugin.h"
#import "DPHitoeSystemProfile.h"
#import "DPHitoeManager.h"
#import "DPHitoeConsts.h"
#import "DPHitoeService.h"
#import "DPHitoeDevice.h"
// Const.h
NSString *const DPHitoeBundleName = @"dConnectDeviceHitoe_resources";


NSString *const DPHitoeBR = @"\n";
NSString *const DPHitoeVB = @"|";
NSString *const DPHitoeComma = @",";
NSString *const DPHitoeColon = @":";

NSString *const DPHitoeRawDataPrefix = @"raw.";
NSString *const DPHitoeBaDataPrefix = @"ba.";
NSString *const DPHitoeExDataPrefix = @"ex.";

NSString *const DPHitoeRawConnectionPrefix = @"R";
NSString *const DPHitoeBaConnectionPrefix = @"B";
NSString *const DPHitoeExConnectionPrefix = @"E";

int const DPHitoeExPostureUnitNum = 30;
int const DPHitoeExWalkUnitNum = 110;
int const DPHitoeExLRBalanceUnitNum = 280;

NSString *const DPHitoeSensorDeviceType = @"hitoe D01";
long long const DPHitoeSensorParamSearchTime = 5000;

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
NSString *const DPHitoeBaRRIInput = @"extracted_rri";
int const DPHitoeBaFreqSamplingInterval = 4000;
int const DPHitoeBaFreqSamplingWindow = 60;
int const DPHitoeBaRRISamplingRate = 8;
int const DPHitoeBaTimeSamplingInterval = 4000;
int const DPHitoeBaTimeSamplingWindow = 60;

NSString *const DPHitoeExAccAxisXYZ = @"XYZ=XYZ";
int const DPHitoeExPostureWinodw = 1;
double const DPHitoExWalkStride = 0.81;
double const DPHitoeExRunStrideCOF = 0.0091;
double const DPHitoeExRunStrideINT = 0.1806;


int const DPHitoeBackForwardThreshold = 30;
int const DPHitoeLeftRightThreshold = 20;



int const DPHitoeChartTitleSize = 25;
int const DPHitoeLabesSize = 16;


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


NSString *const DPHitoeDeviceNameHitoeTX = @"hitoe tx";
int const DPHitoeDeviceTypeUnknown = 0;
int const DPHitoeDeviceTypeHitoeTx = 1;

int const DPHitoeDataKeyRaw = 0x01;
int const DPHitoeDataKeyBasic = 0x02;
int const DPHitoeDataKeyExtension = 0x04;



@implementation DPHitoeDevicePlugin

- (id) init
{
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"Hitoe (Device Connect Device Plug-in)";

        
        DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
        [mgr readHitoeData];
        NSMutableArray *devices = mgr.registeredDevices;
        for (DPHitoeDevice *device in devices) {
            DConnectService *hitoeService = [[DPHitoeService alloc] initWithServiceId:device.serviceId plugin:self];
            [hitoeService setName:device.name];
            [hitoeService setOnline:device.registerFlag];
            [self.serviceProvider addService: hitoeService];
        }

        [self addProfile:[DPHitoeSystemProfile new]];
        // イベントマネージャの準備
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key] setController:[DConnectMemoryCacheController new]];


        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:_self selector:@selector(enterForeground)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:nil];
            [notificationCenter addObserver:_self selector:@selector(didConnectWithDevice:)
                                       name:DPHitoeConnectDeviceNotification
                                     object:nil];
            [notificationCenter addObserver:_self selector:@selector(didConnectFailWithDevice:)
                                       name:DPHitoeConnectFailedDeviceNotification
                                     object:nil];
            [notificationCenter addObserver:_self selector:@selector(didDisconnectWithDevice:)
                                       name:DPHitoeDisconnectNotification
                                     object:nil];
            [notificationCenter addObserver:_self selector:@selector(didDiscoveryForDevices:)
                                       name:DPHitoeDiscoveryDeviceNotification
                                     object:nil];
            [notificationCenter addObserver:_self selector:@selector(didDeleteAtDevice:)
                                       name:DPHitoeDeleteDeviceNotification
                                     object:nil];

        });

    }
    
    return self;
}

- (void) dealloc {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeConnectDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeConnectFailedDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDisconnectNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDiscoveryDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDeleteDeviceNotification object:nil];
}
- (void)enterForeground {
    [[DPHitoeManager sharedInstance] startRetryTimer];
}

#pragma mark - Hitoe Delegate

-(void)didConnectWithDevice:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    DPHitoeDevice *device = userInfo[DPHitoeConnectDeviceObject];
    DConnectService *hitoeService = [self.serviceProvider service:device.serviceId];
    if (hitoeService) {
        [hitoeService setOnline:YES];
    }
    
}
-(void)didConnectFailWithDevice:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    DPHitoeDevice *device = userInfo[DPHitoeConnectFailedDeviceObject];
    DConnectService *hitoeService = [self.serviceProvider service:device.serviceId];
    if (hitoeService) {
        [hitoeService setOnline:NO];
    }
}

-(void)didDisconnectWithDevice:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    DPHitoeDevice *device = userInfo[DPHitoeDisconnectObject];
    DConnectService *hitoeService = [self.serviceProvider service:device.serviceId];
    if (hitoeService) {
        [hitoeService setOnline:NO];
    }
}
-(void)didDiscoveryForDevices:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    NSMutableArray *devices = userInfo[DPHitoeDiscoveryDeviceObject];
    for (DPHitoeDevice *device in devices) {
        DConnectService *hitoeService = [[DPHitoeService alloc] initWithServiceId:device.serviceId
                                                                           plugin:self];
        [hitoeService setName:device.name];
        [hitoeService setOnline:device.registerFlag];
        [self.serviceProvider addService: hitoeService];
    }
}
-(void)didDeleteAtDevice:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    DPHitoeDevice *device = userInfo[DPHitoeDeleteDevicObject];
    DConnectService *hitoeService = [self.serviceProvider service:device.serviceId];
    [self.serviceProvider removeService:hitoeService];
}


#pragma mark - DevicePlugin's icon image

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPHitoeBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
    return nil;
}

@end
