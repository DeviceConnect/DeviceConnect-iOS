//
//  DConnectRequestParamSpec.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/06/27.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    STRING = 0,
    INTEGER,
    NUMBER,
    BOOLEAN
} DConnectRequestParamSpecType;

@interface  DConnectRequestParamSpec : NSObject

- (instancetype)initWithType: (DConnectRequestParamSpecType)type;
- (DConnectRequestParamSpecType) type;
- (void) setName: (NSString *)name;
- (NSString *) name;
- (void) setMandatory: (BOOL) isMandatory;
- (BOOL) isMandatory;
- (NSDictionary *) toDictionary;

+ (NSString *) convertTypeToString: (DConnectRequestParamSpecType) type;
+ (DConnectRequestParamSpecType)parseType: (NSString *)strType;
+ (DConnectRequestParamSpec *)fromJson: (NSDictionary *) json;

@end
