//
//  DPHitoeDevice.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeDevice.h"
#import "DPHitoeConsts.h"

@implementation DPHitoeDevice

- (id) initWithInfoString:(NSString *)info {
    if (self = [super init]) {
        _availableBaDataList = [NSMutableArray array];
        _availableExDataList = [NSMutableArray array];
        _availableRawDataList = [NSMutableArray array];
//                                 arrayWithObjects:@"ex.stress", @"ex.posture", @"ex.walk", @"ex.lr_balance", nil];
        _exConnectionList = [NSMutableArray array];
        if (info) {
            NSArray *infos = [info componentsSeparatedByString:DPHitoeComma];
            _type = infos[0];
            _name = infos[1];
            _serviceId = infos[2];
            _connectMode = infos[3];
            _memorySetting = infos[4];
            NSArray *list = [_memorySetting componentsSeparatedByString:DPHitoeVB];
            for (NSString *l in list) {
                [_availableRawDataList addObject:l];
            }
        }
    }
    return self;
}

- (void)setAvailableData:(NSString *)availableData {
    NSArray* dataList = [availableData componentsSeparatedByString:DPHitoeBR];
    for (int i = 0; i < [dataList count]; i++) {
        if ([dataList[i] hasPrefix:DPHitoeRawDataPrefix]) {
            
            if (![_availableRawDataList containsObject:dataList[i]]) {
                
                [_availableRawDataList addObject:[NSString stringWithString:dataList[i]]];
            }
        } else if ([dataList[i] hasPrefix:DPHitoeBaDataPrefix]) {
            
            if (![_availableRawDataList containsObject:dataList[i]]) {
                
                [_availableRawDataList addObject:[NSString stringWithString:dataList[i]]];
            }
        } else if ([dataList[i]  hasPrefix:DPHitoeExDataPrefix]) {
            
            if (![_availableRawDataList  containsObject:dataList[i]]) {
                
                [_availableRawDataList addObject:[NSString stringWithString:dataList[i]]];
            }
        }
    }
}


- (void)setConnectionId:(NSString *)connectionId {
    if ([connectionId hasPrefix:DPHitoeRawConnectionPrefix]) {
        _rawConnectionId = connectionId;
    } else if ([connectionId hasPrefix:DPHitoeBaConnectionPrefix]) {
        _baConnectionId = connectionId;
    } else if ([connectionId hasPrefix:DPHitoeExConnectionPrefix]) {
        [_exConnectionList addObject:connectionId];
    }
}

- (void)removeConnectionId:(NSString *)connectionId {
    if (_rawConnectionId && [_rawConnectionId isEqualToString:connectionId]) {
        _rawConnectionId = nil;
    } else if (_baConnectionId && [_baConnectionId isEqualToString:connectionId]) {
        _baConnectionId = nil;
    } else if ([_exConnectionList count] > 0 && [_exConnectionList containsObject:connectionId]) {
        [_exConnectionList removeObject:connectionId];
    }
}

- (void)setRawData {
    _availableRawDataList = [NSMutableArray array];
    [_availableRawDataList removeAllObjects];
    [_availableRawDataList addObject:@"raw.ecg"];
    [_availableRawDataList addObject:@"raw.acc"];
    [_availableRawDataList addObject:@"raw.rri"];
    [_availableRawDataList addObject:@"raw.bat"];
    [_availableRawDataList addObject:@"raw.hr"];
}

- (void)setBaData {
    _availableBaDataList = [NSMutableArray array];
    [_availableBaDataList removeAllObjects];
    [_availableBaDataList addObject:@"ba.extracted_rri"];
    [_availableBaDataList addObject:@"ba.cleaned_rri"];
    [_availableBaDataList addObject:@"ba.interpolated_rri"];
    [_availableBaDataList addObject:@"ba.freq_domain"];
    [_availableBaDataList addObject:@"ba.time_domain"];
}

- (void)setExData {
    _availableExDataList = [NSMutableArray array];

    [_availableExDataList removeAllObjects];
    [_availableExDataList addObject:@"ex.stress"];
    [_availableExDataList addObject:@"ex.posture"];
    [_availableExDataList addObject:@"ex.walk"];
    [_availableExDataList addObject:@"ex.lr_balance"];
}

- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}
@end
