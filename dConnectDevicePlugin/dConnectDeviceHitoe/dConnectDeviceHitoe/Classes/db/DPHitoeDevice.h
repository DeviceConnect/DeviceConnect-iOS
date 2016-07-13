//
//  DPHitoeDevice.h
//  dConnectDeviceHitoe
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>

@interface DPHitoeDevice : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *connectMode;
@property (nonatomic, copy) NSString *pinCode;
@property (nonatomic, assign, getter=isRegisterFlag) BOOL registerFlag;
@property (nonatomic, copy) NSString *memorySetting;
@property (nonatomic, copy) NSMutableArray *availableRawDataList;
@property (nonatomic, copy) NSMutableArray *availableBaDataList;
@property (nonatomic, copy) NSMutableArray *availableExDataList;
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, copy) NSString *rawConnectionId;
@property (nonatomic, copy) NSString *baConnectionId;
@property (nonatomic, copy) NSString *exConnectionId;
@property (nonatomic, copy) NSMutableArray *exConnectionList;
@property (nonatomic, assign) int responseId;

- (id) initWithInfoString:(NSString *)info;
- (void)setAvailableData:(NSString *)availableData;
- (void)setConnectionId:(NSString *)connectionId;
- (void)removeConnectionId:(NSString *)connectionId;


- (void)setRawData;
- (void)setBaData;
- (void)setExData;

@end
