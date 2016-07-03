//
//  DConnectRequestParamSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectRequestParamSpec.h"

NSString *const DConnectRequestParamSpecJsonKeyName = @"name";
NSString *const DConnectRequestParamSpecJsonKeyMandatory = @"mandatory";
NSString *const DConnectRequestParamSpecJsonKeyType = @"type";

NSString *const BOOL_TRUE = @"true";
NSString *const BOOL_FALSE = @"false";

NSString *const TYPE_STRING = @"STRING";
NSString *const TYPE_INTEGER = @"INTEGER";
NSString *const TYPE_NUMBER = @"NUMBER";
NSString *const TYPE_BOOLEAN = @"BOOLEAN";



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

- (void) setIsMandatory: (BOOL) isMandatory {
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



+ (NSString *) convertBoolToString: (BOOL) boolValue {
    if (boolValue == YES) {
        return BOOL_TRUE;
    }
    if (boolValue == NO) {
        return BOOL_FALSE;
    }
    @throw [NSString stringWithFormat: @"bool is invalid : boolValue: %d", (int)boolValue];
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


+ (BOOL)isDigit:(NSString *)text {
    NSCharacterSet *digitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"+-0123456789"];
    
    NSScanner *aScanner = [NSScanner localizedScannerWithString:text];
    [aScanner setCharactersToBeSkipped:nil];
    
    [aScanner scanCharactersFromSet:digitCharSet intoString:NULL];
    return [aScanner isAtEnd];
}

+ (BOOL)isNumber:(NSString *)text {
    NSCharacterSet *digitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"+-0123456789."];
    
    NSScanner *aScanner = [NSScanner localizedScannerWithString:text];
    [aScanner setCharactersToBeSkipped:nil];
    
    [aScanner scanCharactersFromSet:digitCharSet intoString:NULL];
    return [aScanner isAtEnd];
}

@end
