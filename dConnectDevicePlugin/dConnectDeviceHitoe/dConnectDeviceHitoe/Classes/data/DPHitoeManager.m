//
//  DPHitoeManager.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeManager.h"
#import "DPHitoeDBManager.h"
#import "DPHitoeStringUtil.h"
#import "DPHitoeTempExData.h"
#import "DPHitoeRawDataParseUtil.h"



@interface DPHitoeManager() {
    HitoeSdkAPI *api;
}
@property (nonatomic, strong) NSMutableDictionary *hrData;
@property (nonatomic, strong) NSMutableDictionary *accelData;
@property (nonatomic, strong) NSMutableDictionary *ecgData;
@property (nonatomic, strong) NSMutableDictionary *poseEstimationData;
@property (nonatomic, strong) NSMutableDictionary *stressEstimationData;
@property (nonatomic, strong) NSMutableDictionary *walkStateData;
@property (nonatomic, strong) NSMutableArray *listForPosture;
@property (nonatomic, strong) NSMutableArray *listForWalk;
@property (nonatomic, strong) NSMutableArray *listForLRBalance;

@end
@implementation DPHitoeManager

#pragma mark - Initialize
+ (DPHitoeManager *)sharedInstance {
    static DPHitoeManager *instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [DPHitoeManager new];
    });
    return instance;
}

- (id) init {
    
    self = [super init];
    
    if (self) {
        self.hrData = [NSMutableDictionary dictionary];
        self.accelData = [NSMutableDictionary dictionary];
        self.ecgData = [NSMutableDictionary dictionary];
        self.poseEstimationData = [NSMutableDictionary dictionary];
        self.stressEstimationData = [NSMutableDictionary dictionary];
        self.walkStateData = [NSMutableDictionary dictionary];

        api = [HitoeSdkAPI sharedManager];
        [api setAPIDelegate:self];
        _registeredDevices = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Hitoe delegate

- (void)cbCallback:(int)apiId
        apiResorce:(int)apiResorce
            object:(id)object {
    NSString *responseData = (NSString*) object;
    NSLog(@"cbCallback:%d:%d:%@", apiId, apiResorce, responseData);
    if (apiId == DPHitoeApiIdGetAvailableSensor) {
        [self notifyDiscoveryHitoeDeviceWithResponseId:apiResorce responseString:responseData];
    } else if (apiId == DPHitoeApiIdConnect) {
        [self notifyConnectHitoeDeviceWithResponseId:apiResorce
                                              responseString:responseData];
        
    } else if (apiId == DPHitoeApiIdDisconnect) {
    } else if (apiId == DPHitoeApiIdGetAvailableData) {
        [self notifyAddBaReceiverWithResponseId:apiResorce
                                 responseString:responseData];
    } else if (apiId == DPHitoeApiIdAddReceiver) {
        [self notifyAddReceiverWithResponseId:apiResorce
                               responseString:responseData];
    } else if (apiId == DPHitoeApiIdRemoveReceiver) {
        
    } else {
        // etc
    }
}

- (void)onDataReceiver:(NSString *)connectionId
               dataKey:(NSString *)dataKey
                  data:(NSString *)data
            responseId:(int)responseId {
    NSLog(@"DataCallback:connectId=%@,dataKey=%@,rawData=%@",connectionId, dataKey, data);
    int pos = [self currentDeviceForConnectionId:connectionId];
    if (pos == -1) {
        NSLog(@"no connectionId");
        return;
    }
    DPHitoeDevice *receiveDevice = _registeredDevices[pos];
    if (!receiveDevice.sessionId) {
        return;
    }
    if([dataKey isEqualToString:@"raw.ecg"]) {
        [self extractHealthWithHeartRateType:DPHitoeHeartECG raw:data device:receiveDevice];
    } else if([dataKey isEqualToString:@"raw.acc"]) {
        [self analizeAccelerationData:data device:receiveDevice];
        DPHitoeAccelerationData *currentAccel = _accelData[receiveDevice.serviceId];
        if (!currentAccel) {
            currentAccel = [DPHitoeAccelerationData new];
        }
        [DPHitoeRawDataParseUtil parseAccelerationData:currentAccel raw:data];
        _accelData[receiveDevice.serviceId] = currentAccel;
    } else if([dataKey isEqualToString:@"raw.rri"]) {
        [self extractHealthWithHeartRateType:DPHitoeHeartRRI raw:data device:receiveDevice];
    } else if([dataKey isEqualToString:@"raw.bat"]) {
        [self extractBatteryWithRaw:data device:receiveDevice];
    } else if([dataKey isEqualToString:@"raw.hr"]) {
        [self extractHealthWithHeartRateType:DPHitoeHeartRate raw:data device:receiveDevice];
    } else if([dataKey isEqualToString:@"raw.saved_hr"]) {
        
    } else if([dataKey isEqualToString:@"raw.saved_rri"]) {
        
    } else if([dataKey isEqualToString:@"ba.extracted_rri"]) {
        
    } else if([dataKey isEqualToString:@"ba.cleaned_rri"]) {
        
    } else if([dataKey isEqualToString:@"ba.interpolated_rri"]) {
        
    } else if([dataKey isEqualToString:@"ba.freq_domain"]) {
        [self parseFreqDomainWithData:data device:receiveDevice];
    } else if([dataKey isEqualToString:@"ba.time_domain"]) {
        
    } else if([dataKey isEqualToString:@"ex.stress"]) {
        DPHitoeStressEstimationData *stress = [DPHitoeRawDataParseUtil parseStressEstimationWithRaw:data];
        _stressEstimationData[receiveDevice.serviceId] = stress;
    } else if([dataKey isEqualToString:@"ex.posture"]) {
        DPHitoePoseEstimationData *pose = [DPHitoeRawDataParseUtil parsePoseEstimationWithRaw:data];
        _poseEstimationData[receiveDevice.serviceId] = pose;
    } else if([dataKey isEqualToString:@"ex.walk"]) {
        DPHitoeWalkStateData *walk = _walkStateData[receiveDevice.serviceId];
        if (!walk) {
            walk = [DPHitoeWalkStateData new];
        }
        walk = [DPHitoeRawDataParseUtil parseWalkStateWithData:walk raw:data];
        _walkStateData[receiveDevice.serviceId] = walk;
    } else if([dataKey isEqualToString:@"ex.lr_balance"]) {
        DPHitoeWalkStateData *walk = _walkStateData[receiveDevice.serviceId];
        if (!walk) {
            walk = [DPHitoeWalkStateData new];
        }
        walk = [DPHitoeRawDataParseUtil parseWalkStateForBalanceWithData:walk raw:data];
        _walkStateData[receiveDevice.serviceId] = walk;
    }
    
    if ([dataKey isEqualToString:DPHitoeExConnectionPrefix]) {
        // 拡張分析はコネクションを破棄する
        [api removeReceiver:connectionId];
        [receiveDevice removeConnectionId:connectionId];
    }
    
    [self notifyCallbacksWithDevice:receiveDevice];
}

#pragma mark - Public method
- (void)start {
    
}

- (void)stop {
    
}

- (void)discovery {
    NSString *param = [NSString stringWithFormat:@"search_time=%lld", DPHitoeSensorParamSearchTime];
    [api getAvilableSensor:DPHitoeSensorDeviceType parameter:param];
}
- (void)readHitoeData {
    NSArray *dbHitoe = [[DPHitoeDBManager sharedInstance] queryHitoDeviceWithServiceId:nil];
    for (DPHitoeDevice *hitoe in dbHitoe) {
        if (![self containsConnectedHitoeDevice:hitoe.serviceId]) {
            [_registeredDevices addObject:hitoe];
        }
    }
}

- (void)connectForHitoe:(DPHitoeDevice *)device {
    if (!device.pinCode) {
        return;
    }
    
    NSString *param = [NSString stringWithFormat:@"pincode=%@", device.pinCode];
    [api connect:device.type individualIdentifier:device.serviceId connectMode:device.connectMode parameterSettings:param];
    device.responseId = DPHitoeResIdSensorConnect;
    NSMutableArray *existDevice = [[DPHitoeDBManager sharedInstance] queryHitoDeviceWithServiceId:device.serviceId];
    if ([existDevice count] == 0) {
        [[DPHitoeDBManager sharedInstance] insertHitoeDevice:device];
    } else {
        [[DPHitoeDBManager sharedInstance] updateHitoeDevice:device];
    }
    _stressEstimationData[device.serviceId] = [DPHitoeStressEstimationData new];
    for (int i = 0; i < [_registeredDevices count]; i++) {
        DPHitoeDevice *exist = _registeredDevices[i];
        if ([exist.serviceId isEqualToString:device.serviceId]) {
            _registeredDevices[i] = device;
        } else {
            exist.responseId = DPHitoeResIdSensorDisconnectNotice;
            _registeredDevices[i] = exist;
        }
    }
}
- (void)disconnectForHitoe:(DPHitoeDevice *)device {
    DPHitoeDevice *current = [self getHitoeDeviceForServiceId:device.serviceId];
    [api disconnect:current.sessionId];
    current.registerFlag = NO;
    current.sessionId = nil;
    [[DPHitoeDBManager sharedInstance] updateHitoeDevice:current];
    
    // TODO scanhitoe
    
    if (_connectionDelegate) {
        [_connectionDelegate didDisconnectWithDevice:current];
    }
}
- (void)deleteAtHitoe:(DPHitoeDevice *)device {
    [[DPHitoeDBManager sharedInstance] deleteHitoeDeviceWithServiceId:device.serviceId];

    if (_connectionDelegate) {
        [_connectionDelegate didDeleteAtDevice:device];
    }
    int pos = -1;
    for (int i = 0; i < [_registeredDevices count]; i++) {
        if ([((DPHitoeDevice *) _registeredDevices[i]).serviceId isEqualToString:device.serviceId]) {
            pos = i;
            break;
        }
    }
    if (pos != -1) {
        [_registeredDevices removeObjectAtIndex:pos];
    }
}
- (BOOL)containsConnectedHitoeDevice:(NSString *)serviceId {
    for (DPHitoeDevice *device in _registeredDevices) {
        if ([device.serviceId isEqualToString:serviceId]) {
            return YES;
        }
    }
    return NO;
}

- (DPHitoeDevice *)getHitoeDeviceForServiceId:(NSString *)serviceId {
    for (int i = 0; i < [_registeredDevices count]; i++) {
        DPHitoeDevice *current = _registeredDevices[i];
        if (current) {
            if ([current.serviceId isEqualToString:serviceId]) {
                return current;
            }
        }
    }
    return nil;
}
- (DPHitoeHeartRateData *)getHeartRateDataForServiceId:(NSString *)serviceId {
    return _hrData[serviceId];
}
- (DPHitoeHeartRateData *)getECGDataForServiceId:(NSString *)serviceId {
    return _ecgData[serviceId];
}
- (DPHitoeStressEstimationData *)getStressEstimationDataForServiceId:(NSString *)serviceId {
    return _stressEstimationData[serviceId];
}
- (DPHitoePoseEstimationData *)getPoseEstimationDataForServiceId:(NSString *)serviceId {
    return _poseEstimationData[serviceId];
}
- (DPHitoeWalkStateData *)getWalkStateDataForServiceId:(NSString *)serviceId {
    return _walkStateData[serviceId];
}
- (DPHitoeAccelerationData *)getAccelerationDataForServiceId:(NSString *)serviceId {
    return _accelData[serviceId];
}




#pragma mark - Private method
- (int)currentPosForResponseId:(int)responseId {
    int pos = -1;
    for (int i = 0; i < [_registeredDevices count]; i++) {
        DPHitoeDevice *current = _registeredDevices[i];
        if (current.responseId == responseId) {
            pos = i;
            break;
        }
    }
    return pos;
}


- (DPHitoeDevice *)currentDeviceForServiceId:(NSString *)serviceId {
    DPHitoeDevice *device = nil;
    for (int i = 0; i < [_registeredDevices count]; i++) {
        DPHitoeDevice *current = _registeredDevices[i];
        if ([current.serviceId isEqualToString:serviceId]) {
            device = current;
            break;
        }
    }
    return device;
}

- (int)currentDeviceForConnectionId:(NSString*)connectionId {
    int pos = -1;
    for (int i = 0; i < [_registeredDevices count]; i++) {
        if ([((DPHitoeDevice *)_registeredDevices[i]).rawConnectionId isEqualToString:connectionId]) {
            pos = i;
            break;
        }
        if ([((DPHitoeDevice *)_registeredDevices[i]).baConnectionId isEqualToString:connectionId]) {
            pos = i;
            break;
        }
        for (int j = 0; j < [((DPHitoeDevice *)_registeredDevices[i]).exConnectionList count]; j++) {
            NSString* exConnectionId = ((DPHitoeDevice *)_registeredDevices[i]).exConnectionList[j];
            if (!exConnectionId) {
                continue;
            }
            if ([exConnectionId isEqualToString:connectionId]) {
                pos = i;
                break;
            }
        }
    }
    return pos;
}

- (void)notifyCallbacksWithDevice:(DPHitoeDevice*)device {
    if (_heartRateReceived) {
        _heartRateReceived(device, _hrData[device.serviceId]);
    }
    if (_ecgReceived) {
        _ecgReceived(device, _ecgData[device.serviceId]);
    }
    if (_stressEstimationReceived) {
        _stressEstimationReceived(device, _stressEstimationData[device.serviceId]);
    }
    if (_poseEstimationReceived) {
        _poseEstimationReceived(device, _poseEstimationData[device.serviceId]);
    }
    if (_walkStateReceived) {
        _walkStateReceived(device, _walkStateData[device.serviceId]);
    }
    if (_accelReceived) {
        _accelReceived(device, _accelData[device.serviceId]);
    }
}

#pragma mark - Notify method
- (void)notifyDiscoveryHitoeDeviceWithResponseId:(int)responseId
                                  responseString:(NSString *)responseString {
    if (responseId != DPHitoeResIdSuccess || responseString == nil) {
        return;
    }
    NSArray *sensors = [responseString componentsSeparatedByString:DPHitoeBR];
    NSMutableArray *pins = [[DPHitoeDBManager sharedInstance] queryHitoDeviceWithServiceId:nil];
    for (int i = 0; i < [sensors count]; i++) {
        NSString *sensorStr = [sensors[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (sensorStr.length == 0) {
            continue;
        }
        if (![sensorStr containsString:@"memory_setting"] && ![sensorStr containsString:@"memory_get"]) {
            DPHitoeDevice *device = [[DPHitoeDevice alloc] initWithInfoString:sensorStr];
            if ([_registeredDevices count] == 0) {
                [_registeredDevices addObject:device];
            }
            if (![self containsConnectedHitoeDevice:device.serviceId]) {
                [_registeredDevices addObject:device];
            }
        }
    }
    for (DPHitoeDevice *pin in pins) {
        for (DPHitoeDevice *registerDevice in _registeredDevices) {
            if ([registerDevice.serviceId  isEqualToString:pin.serviceId]) {
                registerDevice.pinCode = pin.pinCode;
                registerDevice.registerFlag = pin.isRegisterFlag;
            }
        }
    }
    if (_connectionDelegate) {
        [_connectionDelegate didDiscoveryForDevices:_registeredDevices];
    }
}

- (void)notifyConnectHitoeDeviceWithResponseId:(int)responseId
                                  responseString:(NSString *)responseString {
    int pos = [self currentPosForResponseId:responseId];
    if (pos == -1) {
        if (_connectionDelegate) {
            [_connectionDelegate didConnectFailWithDevice:nil];
        }
        return;
    }
    DPHitoeDevice *currentDevice = _registeredDevices[pos];
    if (responseId == DPHitoeResIdSensorDisconnectNotice) {
        if (_connectionDelegate) {
            [_connectionDelegate didConnectFailWithDevice:currentDevice];
        }
        return;
    } else if (responseId == DPHitoeResIdSensorConnectNotice) {
        if (_connectionDelegate) {
            [_connectionDelegate didConnectWithDevice:currentDevice];
        }
        return;
    } else if (responseId != DPHitoeResIdSensorConnect) {
        if (_connectionDelegate) {
           [_connectionDelegate didConnectFailWithDevice:currentDevice];
        }
        return;
    }
    currentDevice.sessionId = responseString;
    currentDevice.registerFlag = YES;
    currentDevice.responseId =  DPHitoeResIdSuccess;
    [[DPHitoeDBManager sharedInstance] updateHitoeDevice:currentDevice];

    [self notifyAddRawReceiverWithDevice:currentDevice
                                responseString:@"raw.ecg\nraw.acc\nraw.rri\nraw.bat\nraw.hr"];

    if (_connectionDelegate) {
        [_connectionDelegate didConnectWithDevice:currentDevice];
    }
    
    for (int i = 0; i < [_registeredDevices count]; i++) {
        DPHitoeDevice *pos = _registeredDevices[i];
        if ([pos.serviceId isEqualToString:currentDevice.serviceId]) {
            _registeredDevices[i] = currentDevice;
        }
    }
    [api getAvilableData:currentDevice.sessionId];
}

- (void)notifyAddRawReceiverWithDevice:(DPHitoeDevice*)device
                              responseString:(NSString *)responseString {
    [device setRawData];
    NSMutableArray *keyList = device.availableRawDataList;
    NSMutableString *keyStringBuffer = [NSMutableString new];
    NSMutableString *paramStringBuffer = [NSMutableString new];
    for (int i = 0; i < [keyList count]; i++) {
        if (keyStringBuffer.length > 0
            && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
            [keyStringBuffer appendString:DPHitoeBR];
        }
        [keyStringBuffer appendString:keyList[i]];
        
        if ([keyList[i] isEqualToString:@"raw.ecg"]) {
            
            if([DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [paramStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"raw.ecg_sampling_interval="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeECGSamplingInterval];
        } else if ([keyList[i] isEqualToString:@"raw.acc"]) {
            if ([DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [paramStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"raw.acc_sampling_interval="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeACCSamplingInterval];
        } else if([keyList[i] isEqualToString:@"raw.rri"]) {
            if ([DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [paramStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"raw.rri_sampling_interval="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeRRISamplingInterval];
        } else if([keyList[i] isEqualToString:@"raw.hr"]) {
            if ([DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [paramStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"raw.hr_sampling_interval="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeHRSamplingInterval];
        } else if([keyList[i] isEqualToString:@"raw.bat"]) {
            if ([DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [paramStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"raw.bat_sampling_interval="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBatSamplingInterval];
        }

    }
    [api addReceiver:device.sessionId dataKey:(NSString *) keyStringBuffer dataReceiver:self parameterSetting:(NSString *)paramStringBuffer dataList:@""];
}

- (void)notifyAddBaReceiverWithResponseId:(int)responseId
                         responseString:(NSString *)responseString {
    if (responseId != DPHitoeResIdSuccess || !responseString) {
        return;
    }
    int pos = [self currentPosForResponseId:responseId];
    if (pos == -1) {
        return;
    }
    DPHitoeDevice *receiveDevice = _registeredDevices[pos];
    [receiveDevice setBaData];
    
    NSMutableArray *keyList = ((DPHitoeDevice *)_registeredDevices[pos]).availableBaDataList;

    NSMutableString *keyStringBuffer = [NSMutableString new];
    NSMutableString *paramStringBuffer = [NSMutableString new];
    
    for (int i = 0; i < [keyList count]; i++) {
        
        if (keyStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
            [keyStringBuffer appendString:DPHitoeBR];
        }
        [keyStringBuffer appendString:keyList[i]];
        
        if ([keyList[i] isEqualToString:@"ba.extracted_rri"]) {
            
            if ([paramStringBuffer rangeOfString:@"ba.sampling_interval"].location == NSNotFound) {
                if ([DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [paramStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.sampling_interval="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaSamplingInterval];
            }
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.ecg_threshhold="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBaECGThreshold];
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.ecg_skip_count="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBaSkipCount];
        } else if ([keyList[i] isEqualToString:@"ba.cleaned_rri"]) {
            
            if ([paramStringBuffer rangeOfString:@"ba.sampling_interval"].location == NSNotFound) {
                if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [keyStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.sampling_interval="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaSamplingInterval];
            }
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.rri_min="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBaRRIMin];
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.rri_max="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBaRRIMax];
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.sample_count="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBaSampleCount];
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.rri_input="];
            [paramStringBuffer appendFormat:@"%@", DPHitoeBaRRIInput];
        } else if([keyList[i] isEqualToString:@"ba.interpolated_rri"]) {
            
            if ([paramStringBuffer rangeOfString:@"ba.freq_sampling_interval"].location == NSNotFound) {
                if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [keyStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.freq_sampling_interval="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaFreqSamplingInterval];
            }
            if ([paramStringBuffer rangeOfString:@"ba.freq_sampling_window"].location == NSNotFound) {
                if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [keyStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.freq_sampling_window="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaFreqSamplingWindow];
            }
            if ([paramStringBuffer rangeOfString:@"ba.rri_sampling_rate"].location == NSNotFound) {
                if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [keyStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.rri_sampling_rate="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaRRISamplingRate];
            }
        } else if ([keyList[i] isEqualToString:@"ba.freq_domain"]) {
            
            if ([paramStringBuffer rangeOfString:@"ba.freq_sampling_interval"].location == NSNotFound) {
                if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [keyStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.freq_sampling_interval="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaFreqSamplingInterval];
            }
            if ([paramStringBuffer rangeOfString:@"ba.freq_sampling_window"].location == NSNotFound) {
                if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [keyStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.freq_sampling_window="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaFreqSamplingWindow];
            }
            if ([paramStringBuffer rangeOfString:@"ba.rri_sampling_rate"].location == NSNotFound) {
                if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                    [keyStringBuffer appendString:DPHitoeBR];
                }
                [paramStringBuffer appendString:@"ba.rri_sampling_rate="];
                [paramStringBuffer appendFormat:@"%d", DPHitoeBaRRISamplingRate];
            }
        } else if ([keyList[i] isEqualToString:@"ba.time_domain"]) {
            
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.time_sampling_interval="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBaTimeSamplingInterval];
            if (paramStringBuffer.length > 0 && [DPHitoeStringUtil lastIndexOf:keyStringBuffer c:DPHitoeBR] != keyStringBuffer.length - 1) {
                [keyStringBuffer appendString:DPHitoeBR];
            }
            [paramStringBuffer appendString:@"ba.time_sampling_window="];
            [paramStringBuffer appendFormat:@"%d", DPHitoeBaTimeSamplingWindow];
        }
    }
    [api addReceiver:receiveDevice.sessionId dataKey:(NSString *) keyStringBuffer dataReceiver:self parameterSetting:(NSString *) paramStringBuffer dataList:@""];
}

- (void)notifyAddExReceiverWithKey:(NSString*)key
                          dataList:(NSMutableArray *)dataList {

    
    NSMutableString *paramStringBuilder = [NSMutableString new];
    NSMutableString *dataStringBuilder = [NSMutableString new];
    
    for (int i = 0; i < [dataList count]; i++) {
        if (dataStringBuilder.length > 0) {
            [dataStringBuilder appendString:DPHitoeBR];
        }
        [dataStringBuilder appendString:dataList[i]];
    }
    if ([key isEqualToString:@"ex.posture"]) {
        [paramStringBuilder appendString:@"ex.acc_axis="];
        [paramStringBuilder appendString:DPHitoeExAccAxisXYZ];
        
        [paramStringBuilder appendString:@"ex.posture_window="];
        [paramStringBuilder appendFormat:@"%d", DPHitoeExPostureWinodw];
    } else if([key isEqualToString:@"ex.walk"]) {
        [paramStringBuilder appendString:@"ex.acc_axis="];
        [paramStringBuilder appendString:DPHitoeExAccAxisXYZ];
        [paramStringBuilder appendString:@"ex.walk_stride="];
        [paramStringBuilder appendFormat:@"%lf", DPHitoExWalkStride];
        [paramStringBuilder appendString:@"ex.run_stride_cof="];
        [paramStringBuilder appendFormat:@"%lf", DPHitoeExRunStrideCOF];
        [paramStringBuilder appendString:@"ex.run_stride_int="];
        [paramStringBuilder appendFormat:@"%lf", DPHitoeExRunStrideINT];
    } else if ([key isEqualToString:@"ex.lr_balance"]) {
        [paramStringBuilder appendString:@"ex.acc_axis="];
        [paramStringBuilder appendString:DPHitoeExAccAxisXYZ];
    }

    [api addReceiver:@"" dataKey:key dataReceiver:self parameterSetting:paramStringBuilder dataList:dataStringBuilder];
}

- (void)removeExReceiverForConnectionId:(NSString*)connectionId {
    [api removeReceiver:connectionId];
}

- (void)notifyAddReceiverWithResponseId:(int)responseId
                           responseString:(NSString *)responseString {
    if (responseId != DPHitoeResIdSuccess || !responseString) {
        return;
    }
    int pos = [self currentPosForResponseId:responseId];
    if (pos == -1) {
        return;
    }
    [((DPHitoeDevice *) _registeredDevices[pos]) setConnectionId:responseString];

}

- (void)notifyRemoveReceiverWithResponseId:(int)responseId
                         responseString:(NSString *)responseString {
    if (responseId != DPHitoeResIdSuccess || !responseString) {
        return;
    }
    int pos = [self currentPosForResponseId:responseId];
    if (pos == -1) {
        return;
    }
    ((DPHitoeDevice *) _registeredDevices[pos]).registerFlag = NO;
    [((DPHitoeDevice *) _registeredDevices[pos]) removeConnectionId:responseString];
    [[DPHitoeDBManager sharedInstance] updateHitoeDevice:_registeredDevices[pos]];
    [self disconnectForHitoe:_registeredDevices[pos]];
}

#pragma mark - Hitoe's data Extract method

- (void)extractHealthWithHeartRateType:(DPHitoeHeart)heartRateType
                                   raw:(NSString*)raw
                                device:(DPHitoeDevice*)device {
    DPHitoeHeartRateData *currentHeartRate = _hrData[device.serviceId];
    if (!currentHeartRate) {
        currentHeartRate = [DPHitoeHeartRateData new];
    }
    if (heartRateType == DPHitoeHeartRate) {
        DPHitoeHeartData *heart = [DPHitoeRawDataParseUtil parseHeartRateWithRaw:raw];
        currentHeartRate.heartRate = heart;
        _hrData[device.serviceId] = currentHeartRate;
    } else if (heartRateType == DPHitoeHeartRRI) {
        DPHitoeHeartData *rri = [DPHitoeRawDataParseUtil parseRRIWithRaw:raw];
        currentHeartRate.rrinterval = rri;
        _hrData[device.serviceId] = currentHeartRate;
    } else if (heartRateType == DPHitoeHeartEnergyExpended) {
        DPHitoeHeartData *energy = [DPHitoeRawDataParseUtil parseEnergyExpendedWithRaw:raw];
        currentHeartRate.energyExpended = energy;
        _hrData[device.serviceId] = currentHeartRate;
    } else if (heartRateType == DPHitoeHeartECG) {
        DPHitoeHeartData *ecg = [DPHitoeRawDataParseUtil parseECGWithRaw:raw];
        currentHeartRate.ecg = ecg;
        _ecgData[device.serviceId] = currentHeartRate;
    }
}

- (void)extractBatteryWithRaw:(NSString*)raw device:(DPHitoeDevice*)device {
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSString* levelString = lineList[[lineList count] - 1];
    NSArray *level = [levelString componentsSeparatedByString:DPHitoeComma];
    
    DPHitoeTargetDeviceData *current = [DPHitoeRawDataParseUtil parseDeviceDataWithDevice:device batteryLevel:[level[1] floatValue]];

    DPHitoeHeartRateData *currentHeartRate = _hrData[device.serviceId];
    if (!currentHeartRate) {
        currentHeartRate = [DPHitoeHeartRateData new];
    }
    currentHeartRate.target = current;
    _hrData[device.serviceId] = currentHeartRate;
}

-(void)analizeAccelerationData:(NSString *)raw
                        device:(DPHitoeDevice*)device {
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSMutableArray *postureInputList = [NSMutableArray array];
    NSMutableArray *walkInputList = [NSMutableArray array];
    NSMutableArray *lrBalanceInputList = [NSMutableArray array];
    
    @autoreleasepool {
        for (int i = 0; i < [lineList count]; i++) {
            if ([device.availableExDataList containsObject:@"ex.posture"]) {
                [_listForPosture addObject:lineList[i]];
                if ([_listForPosture count] > DPHitoeExPostureUnitNum + 5) {
                    for (int j = 0; j < DPHitoeExPostureUnitNum + 5; j++) {
                        [postureInputList addObject:_listForPosture[j]];
                    }
                    // 1秒分を削除
                    [_listForPosture removeObjectsInRange:NSMakeRange(0, 25)];
                }
                if ([postureInputList count] > 0) {
                    [self notifyAddExReceiverWithKey:@"ex.posture" dataList:postureInputList];
                    [postureInputList removeAllObjects];
                }
            }
            
            if ([device.availableExDataList containsObject:@"ex.walk"]) {
                [_listForWalk addObject:lineList[i]];
                if ([_listForWalk count] > DPHitoeExWalkUnitNum + 5) {
                    for (int j = 0 ; j < DPHitoeExWalkUnitNum + 5; j++) {
                        [walkInputList addObject:_listForWalk[j]];
                    }
                    // 1秒分を削除
                    [_listForWalk removeObjectsInRange:NSMakeRange(0, 25)];
                }
                
                if ([walkInputList count] > 0) {
                    [self notifyAddExReceiverWithKey:@"ex.walk" dataList:walkInputList];
                    [walkInputList removeAllObjects];
                }
            }
            
            if ([device.availableExDataList containsObject:@"ex.lr_balance"]) {
                [_listForLRBalance addObject:lineList[i]];
                if ([_listForLRBalance count] > DPHitoeExLRBalanceUnitNum + 5) {
                    for (int j = 0; j < DPHitoeExLRBalanceUnitNum + 5; j++) {
                        [lrBalanceInputList addObject:_listForLRBalance[j]];
                    }
                    // 1秒分を削除
                    [_listForLRBalance removeObjectsInRange:NSMakeRange(0, 25)];
                }
                
                if ([lrBalanceInputList count] > 0) {
                    [self notifyAddExReceiverWithKey:@"ex.lr_balance" dataList:lrBalanceInputList];
                    [lrBalanceInputList removeAllObjects];
                }
            }
        }

    }
}

- (void)parseFreqDomainWithData:(NSString*)raw device:(DPHitoeDevice*)device {
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSMutableArray *stressInputList = [NSMutableArray array];

    if ([device.availableExDataList containsObject:@"ex.stress"]) {
        for (int i = 0; i < [lineList count]; i++) {
            [stressInputList addObject:lineList[i]];
        }

        [self notifyAddExReceiverWithKey:@"ex.stress" dataList:stressInputList];
    }
}
@end
