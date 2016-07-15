//
//  DPHitoeDevice.h
//  dConnectDeviceHitoe
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>

@interface DPHitoeDevice : NSObject<NSCopying>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, strong) NSString *connectMode;
@property (nonatomic, strong) NSString *pinCode;
@property (nonatomic, assign, getter=isRegisterFlag) BOOL registerFlag;
@property (nonatomic, strong) NSString *memorySetting;
@property (nonatomic, strong) NSMutableArray *availableRawDataList;
@property (nonatomic, strong) NSMutableArray *availableBaDataList;
@property (nonatomic, strong) NSMutableArray *availableExDataList;
@property (nonatomic, strong) NSString *sessionId;
@property (nonatomic, strong) NSString *rawConnectionId;
@property (nonatomic, strong) NSString *baConnectionId;
@property (nonatomic, strong) NSString *exConnectionId;
@property (nonatomic, strong) NSMutableArray *exConnectionList;
@property (nonatomic, assign) int responseId;

- (id) initWithInfoString:(NSString *)info;
- (void)setAvailableData:(NSString *)availableData;
- (void)setConnectionId:(NSString *)connectionId;
- (void)removeConnectionId:(NSString *)connectionId;


- (void)setRawData;
- (void)setBaData;
- (void)setExData;

@end
