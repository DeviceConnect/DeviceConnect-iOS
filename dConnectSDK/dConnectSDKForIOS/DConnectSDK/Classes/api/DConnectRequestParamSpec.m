//
//  DConnectRequestParamSpec.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/06/27.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectRequestParamSpec.h"

#define NAME        @"name"
#define MANDATORY   @"mandatory"
#define TYPE        @"type"

#define TYPE_STRING @"STRING"
#define TYPE_INTEGER @"INTEGER"
#define TYPE_NUMBER @"NUMBER"
#define TYPE_BOOLEAN @"BOOLEAN"



@interface DConnectRequestParamSpec()

@property DConnectRequestParamSpecType mType;
@property NSString *mName;
@property BOOL mIsMandatory;

@end

@implementation DConnectRequestParamSpec

- (instancetype)initWithType: (DConnectRequestParamSpecType)type
{
    self = [super init];
    if (self) {
        self.mType = type;
        self.mName = @"";
        self.mIsMandatory = NO;
    }
    return self;
}

- (DConnectRequestParamSpecType) type {
    return self.mType;
}

- (void) setName: (NSString *)name {
    self.mName = name;
}

- (NSString *) name {
    return self.mName;
}

- (void) setMandatory: (BOOL) isMandatory {
    self.mIsMandatory = isMandatory;
}

- (BOOL) isMandatory {
    return self.mIsMandatory;
}

- (BOOL) validate: (id) param {
    
    if (param == nil) {
        return ![self isMandatory];
    }
    
    // 「return param instanceof Boolean;」の代替処理(idにBOOLを入れる場合はNSNumberにYES/NOの実値が渡される想定)
    if ([param isKindOfClass: [NSNumber class]]) {
        
        NSNumber *num = (NSNumber *)param;
        if ([num isEqualToNumber: [NSNumber numberWithBool: YES]] || [num isEqualToNumber: [NSNumber numberWithBool: NO]]) {
            return YES;
        }
    }
    return NO;
}

// toBundle()相当
- (NSDictionary *) toDictionary {
    return nil; // TODO
}

// enum Type#getName()相当
+ (NSString *) convertTypeToString: (DConnectRequestParamSpecType) type {
    if (type == STRING) {
        return TYPE_STRING;
    }
    if (type == INTEGER) {
        return TYPE_INTEGER;
    }
    if (type == NUMBER) {
        return TYPE_NUMBER;
    }
    if (type == BOOLEAN) {
        return TYPE_BOOLEAN;
    }
    @throw [NSString stringWithFormat: @"type is invalid : type: %d", (int)type];
    
}

// enum Type#fromName()相当
+ (DConnectRequestParamSpecType)parseType: (NSString *)strType {
    
    NSString *strTypeLow = [strType lowercaseString];
    
    if ([strTypeLow isEqualToString: [(TYPE_STRING) lowercaseString]]) {
        return STRING;
    }
    if ([strTypeLow isEqualToString: [(TYPE_INTEGER) lowercaseString]]) {
        return INTEGER;
    }
    if ([strTypeLow isEqualToString: [(TYPE_NUMBER) lowercaseString]]) {
        return NUMBER;
    }
    if ([strTypeLow isEqualToString: [(TYPE_BOOLEAN) lowercaseString]]) {
        return BOOLEAN;
    }
    @throw [NSString stringWithFormat: @"type is invalid : %@", strType];
}

+ (DConnectRequestParamSpec *)fromJson: (NSDictionary *) json {
    
    NSString *type = [json objectForKey: TYPE];
    
    @try {
        // 失敗したら例外を返す
        DConnectRequestParamSpecType paramType = [DConnectRequestParamSpec parseType: type];
        
        DConnectRequestParamSpec *spec = nil;
        switch (paramType) {
            case BOOLEAN:
                //                spec = [BooleanRequestParamSpec fromJson: json];
                break;
            case STRING:
                //                spec = [StringRequestParamSpec fromJson: json];
                break;
            case INTEGER:
                //                spec = [IntegerRequestParamSpec fromJson: json];
                break;
            case NUMBER:
                //                spec = [NumberRequestParamSpec fromJson: json];
                break;
            default:
                @throw [NSString stringWithFormat: @"Illegal Argument Exception type: %@", type];
        }
        return spec;
    }
    @catch (NSException *e) {
        return nil;
    }
}

@end
