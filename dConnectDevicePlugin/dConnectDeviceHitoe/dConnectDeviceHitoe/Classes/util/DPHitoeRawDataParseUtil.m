//
//  DPHitoeRawDataParseUtil.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

#import "DPHitoeRawDataParseUtil.h"
#import "DPHitoeMDERFloatConvertUtil.h"

@implementation DPHitoeRawDataParseUtil

#pragma mark - Public Method
+ (DPHitoeHeartData *)parseHeartRateWithRaw:(NSString*)raw {
    return [DPHitoeRawDataParseUtil parseHeartDataForRaw:raw
                        heartRateType:DPHitoeHeartRate
                                 type:@"heart rate"
                             typeCode:147842
                                 unit:@"beat per min"
                             unitCode:264864];
}

+ (DPHitoeHeartData *)parseRRIWithRaw:(NSString*)raw {
    return [DPHitoeRawDataParseUtil parseHeartDataForRaw:raw
                        heartRateType:DPHitoeHeartRRI
                                 type:@"RR interval"
                             typeCode:147240
                                 unit:@"ms"
                             unitCode:264338];
}

+ (DPHitoeHeartData * )parseEnergyExpendedWithRaw:(NSString*)raw {
    return [DPHitoeRawDataParseUtil parseHeartDataForRaw:raw
                        heartRateType:DPHitoeHeartEnergyExpended
                                 type:@"energy expended"
                             typeCode:119
                                 unit:@"Calories"
                             unitCode:6784];
}

+ (DPHitoeTargetDeviceData *)parseDeviceDataWithDevice:(DPHitoeDevice *)device batteryLevel:(float)batteryLevel {
    DPHitoeTargetDeviceData *deviceData = [DPHitoeTargetDeviceData new];
    deviceData.productName = device.name;
    deviceData.batteryLevel = (batteryLevel + 1) / 4.0f;
    return deviceData;
}

+ (void)parseAccelerationData:(DPHitoeAccelerationData *)data raw:(NSString *)raw {
    if (!raw) {
        return;
    }
    DPHitoeAccelerationData *accel = data;
    if (!accel) {
        accel = [DPHitoeAccelerationData new];
    }
    NSArray* lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSArray* list = [lineList[0] componentsSeparatedByString:DPHitoeComma];
    data.timeStamp = [((NSString*) list[0]) longLongValue];
    NSArray* accList = [list[1] componentsSeparatedByString:DPHitoeColon];
    data.accelX = [accList[0] doubleValue];
    data.accelY = [accList[1] doubleValue];
    data.accelZ = [accList[2] doubleValue];

}

+ (DPHitoeHeartData*)parseECGWithRaw:(NSString *)raw {
    NSArray  *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    DPHitoeHeartData *ecg = [DPHitoeHeartData new];
    for (int i = 0; i < [lineList count]; i++) {
        NSString* val = lineList[i];
        if (!val) {
            continue;
        }
        NSArray *list = [val componentsSeparatedByString:DPHitoeComma];
        long timestamp = (long) [((NSString*) list[0]) longLongValue];
        NSArray *ecgList = [list[1] componentsSeparatedByString:DPHitoeColon];
        NSString *date = [DConnectRFC3339DateUtils stringWithTimeStamp:timestamp];
        ecg.value = [ecgList[0] floatValue];
        ecg.timeStamp = timestamp;
        ecg.timeStampString = date;
    }
    ecg.heartType = DPHitoeHeartECG;
    ecg.mderFloat = [DPHitoeMDERFloatConvertUtil converMDERFloatToFloat:ecg.value];
    ecg.type = @"ecg beat";
    ecg.typeCode = 663568;
    ecg.unit = @"mVolt * miliSecond";
    ecg.unitCode = 3328;
    
    return ecg;
}

+ (DPHitoeStressEstimationData*)parseStressEstimationWithRaw:(NSString*)raw {
    DPHitoeStressEstimationData *stress = [DPHitoeStressEstimationData new];
    if (!raw) {
        return stress;
    }
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSArray *stressList = [lineList[0] componentsSeparatedByString:DPHitoeComma];
    if (!stressList[0] || !stressList[1]) {
        return stress;
    }
    long timestamp = (long) [((NSString*) stressList[0]) longLongValue];
    double lfhf = [stressList[1] doubleValue];
    stress.lfhf = lfhf;
    stress.timeStamp = timestamp;
    stress.timeStampString = [DConnectRFC3339DateUtils stringWithTimeStamp:timestamp];
    return stress;
}


+ (DPHitoePoseEstimationData *)parsePoseEstimationWithRaw:(NSString*)raw {
    DPHitoePoseEstimationData  *pose = [DPHitoePoseEstimationData new];
    if (!raw) {
        return pose;
    }
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSArray *poseList = [lineList[0] componentsSeparatedByString:DPHitoeComma];
    long timestamp = (long) [((NSString*) poseList[0]) longLongValue];
    pose.timeStamp = timestamp;
    pose.timeStampString = [DConnectRFC3339DateUtils stringWithTimeStamp:timestamp];
    
    NSString *type = poseList[1];
    
    int backForward = [poseList[2] intValue];
    int leftRight = [poseList[3] intValue];
    
    if ([type isEqualToString:@"LyingLeft"]) {
        pose.state = DCMPoseEstimationProfileStateFaceLeft;
    } else if ([type isEqualToString:@"LyingRight"]) {
        pose.state = DCMPoseEstimationProfileStateFaceRight;
    } else if ([type isEqualToString:@"LyingFaceUp"]) {
        pose.state = DCMPoseEstimationProfileStateFaceUp;
    } else if ([type isEqualToString:@"LyingFaceDown"]) {
        pose.state = DCMPoseEstimationProfileStateFaceDown;
    } else {
        if (backForward > DPHitoeBackForwardThreshold) {
            pose.state = DCMPoseEstimationProfileStateForward;
        } else if (backForward < -1 * DPHitoeBackForwardThreshold) {
            pose.state = DCMPoseEstimationProfileStateBackward;
        } else if (leftRight > DPHitoeLeftRightThreshold) {
            pose.state = DCMPoseEstimationProfileStateLeftside;
        } else if (leftRight < -1 * DPHitoeLeftRightThreshold) {
            pose.state = DCMPoseEstimationProfileStateRightside;
        } else {
            pose.state = DCMPoseEstimationProfileStateStanding;
        }
    }
    
    return pose;
}

+ (DPHitoeWalkStateData*)parseWalkStateWithData:(DPHitoeWalkStateData*)data
                                            raw:(NSString*)raw {
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSArray *walkList = [lineList[0] componentsSeparatedByString:DPHitoeComma];
    long timestamp = (long) [((NSString*) walkList[0]) longLongValue];
    data.timeStamp = timestamp;

    data.timeStampString = [DConnectRFC3339DateUtils stringWithTimeStamp:timestamp];
    data.step = [walkList[1] intValue];
    if ([walkList[4] isEqualToString:@"Walking"]) {
        data.state = DCMWalkStateProfileStateWalking;
    } else if ([walkList[4] isEqualToString:@"Running"]) {
        data.state = DCMWalkStateProfileStateRunning;
    } else {
        data.state = DCMWalkStateProfileStateStop;
    }
    data.speed = [walkList[6] doubleValue];
    data.distance = [walkList[7] doubleValue];
    return data;
}

+ (DPHitoeWalkStateData*)parseWalkStateForBalanceWithData:(DPHitoeWalkStateData*)data
                                                      raw:(NSString*)raw {
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSArray *walkList = [lineList[0] componentsSeparatedByString:DPHitoeComma];
    if ([walkList count] <= 1) {
        return data;
    }
    data.balance = [walkList[1] doubleValue];
    return data;
}
#pragma mark - Private Method
+ (DPHitoeHeartData *)parseHeartDataForRaw:(NSString*)raw
                             heartRateType:(DPHitoeHeart)heartRateType
                                      type:(NSString*)type
                                  typeCode:(int)typeCode
                                      unit:(NSString*)unit
                                  unitCode:(int)unitCode
{
    DPHitoeHeartData *heart = [DPHitoeHeartData new];
    NSArray *lineList = [raw componentsSeparatedByString:DPHitoeBR];
    NSString* rateString = lineList[[lineList count] - 1 ];
    if (!rateString) {
        return nil;
    }
    heart.heartType = heartRateType;
    NSArray *hrValue = [self splitCommaWithString:rateString];
    float rate = [hrValue[1] floatValue];
    heart.value = rate;
    heart.mderFloat = [DPHitoeMDERFloatConvertUtil converMDERFloatToFloat:rate];
    heart.type = type;
    heart.typeCode = typeCode;
    heart.unit = unit;
    heart.unitCode = unitCode;
    heart.timeStamp = (long) [((NSString*) hrValue[0]) longLongValue];
    heart.timeStampString = [DConnectRFC3339DateUtils stringWithTimeStamp:heart.timeStamp];
    
    return heart;
}



+ (NSArray*)splitCommaWithString:(NSString*)value {
    return [value componentsSeparatedByString:@","];
}
@end
