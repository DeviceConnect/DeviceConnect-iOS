//
//  DConnectSpecConstants.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/30.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectSpecConstants.h"

NSString * const DConnectSpecTypeOneshot = @"one-shot";
NSString * const DConnectSpecTypeEvent = @"event";
NSString * const DConnectSpecTypeStreaming = @"streaming";

NSString * const DConnectSpecMethodGet = @"GET";
NSString * const DConnectSpecMethodPut = @"PUT";
NSString * const DConnectSpecMethodPost = @"POST";
NSString * const DConnectSpecMethodDelete = @"DELETE";

NSString * const DConnectSpecDataTypeArray = @"array";
NSString * const DConnectSpecDataTypeBoolean = @"boolean";
NSString * const DConnectSpecDataTypeInteger = @"integer";
NSString * const DConnectSpecDataTypeNumber = @"number";
NSString * const DConnectSpecDataTypeString = @"string";
NSString * const DConnectSpecDataTypeFile = @"file";

NSString * const DConnectSpecDataFormatInt32 = @"int32";
NSString * const DConnectSpecDataFormatInt64 = @"int64";
NSString * const DConnectSpecDataFormatFloat = @"float";
NSString * const DConnectSpecDataFormatDouble = @"double";
NSString * const DConnectSpecDataFormatText = @"text";
NSString * const DConnectSpecDataFormatByte = @"byte";
NSString * const DConnectSpecDataFormatBinary = @"binary";
NSString * const DConnectSpecDataFormatDate = @"date";
NSString * const DConnectSpecDataFormatDateTime = @"date-time";
NSString * const DConnectSpecDataFormatPassword = @"password";
NSString * const DConnectSpecDataFormatRGB = @"rgb";

NSString * const DConnectSpecBoolFalse = @"false";
NSString * const DConnectSpecBoolTrue = @"true";


@implementation DConnectSpecConstants

+ (DConnectSpecType) parseType: (NSString *)strType {
    
    NSString *strTypeLow = [strType lowercaseString];
    
    int i = 0;
    for (NSString *strType in DConnectSpecTypes) {
        if ([strTypeLow isEqualToString: [strType lowercaseString]]) {
            return (DConnectSpecType)i;
        }
        i ++;
    }
    @throw @"invalid strType";
}

+ (NSString *) toTypeString: (DConnectSpecType)type {
    int index = (int)type;
    if (index <= 0 && index < [DConnectSpecTypes count]) {
        return DConnectSpecTypes()[index];
    }
    
    @throw @"invalid type";
}

+ (DConnectSpecMethod) parseMethod: (NSString *)strMethod {
    
    NSString *strMethodLow = [strMethod lowercaseString];
    
    int i = 0;
    for (NSString *strMethod in DConnectSpecMethods) {
        if ([strMethodLow isEqualToString: [strMethod lowercaseString]]) {
            return (DConnectSpecMethod)i;
        }
        i ++;
    }
    @throw @"invalid strMethod";
}
    
+ (NSString *) toMethodString: (DConnectSpecMethod)method {
    int index = (int)method;
    if (index <= 0 && index < [DConnectSpecMethods count]) {
        return DConnectSpecMethods()[index];
    }
    
    @throw @"invalid method";
}

+ (DConnectSpecMethod) toMethodFromAction: (DConnectMessageActionType) enMethod {
    
    if (enMethod == DConnectMessageActionTypeGet) {
        return GET;
    }
    if (enMethod == DConnectMessageActionTypePut) {
        return PUT;
    }
    if (enMethod == DConnectMessageActionTypePost) {
        return POST;
    }
    if (enMethod == DConnectMessageActionTypeDelete) {
        return DELETE;
    }
    @throw [NSString stringWithFormat: @"unknown DConnectMessageActionType : %d", (int)enMethod];
}
    
+ (DConnectSpecDataType) parseDataType: (NSString *)strDataType {
    
    NSString *strDataTypeLow = [strDataType lowercaseString];
    
    int i = 0;
    for (NSString *strDataType in DConnectSpecDataTypes) {
        if ([strDataTypeLow isEqualToString: [strDataType lowercaseString]]) {
            return (DConnectSpecDataType)i;
        }
        i ++;
    }
    @throw @"invalid strDataType";
}
    
+ (NSString *) toDataTypeString: (DConnectSpecDataType)dataType {
    int index = (int)dataType;
    if (index <= 0 && index < [DConnectSpecDataTypes count]) {
        return DConnectSpecDataTypes()[index];
    }
    
    @throw @"invalid dataType";
}

+ (DConnectSpecDataFormat) parseDataFormat: (NSString *)strDataFormat {
    
    NSString *strDataFormatLow = [strDataFormat lowercaseString];
    
    int i = 0;
    for (NSString *strDataFormat in DConnectSpecDataFormats) {
        if ([strDataFormatLow isEqualToString: [strDataFormat lowercaseString]]) {
            return (DConnectSpecDataFormat)i;
        }
        i ++;
    }
    @throw @"invalid strDataFormat";
}

+ (NSString *) toDataFormatString: (DConnectSpecDataFormat)dataFormat {
    int index = (int)dataFormat;
    if (index <= 0 && index < [DConnectSpecDataFormats count]) {
        return DConnectSpecDataFormats()[index];
    }
    
    @throw @"invalid dataFormat";
}

    
+ (BOOL) parseBool: (NSString *)strBool {
    
    NSArray *dConnectSpecBools = DConnectSpecBools();
    BOOL dConnectSpecBoolValues[] = DConnectSpecBoolValues();
    
    NSString *strBoolLow = [strBool lowercaseString];
    int i = 0;
    for (NSString *strBool in dConnectSpecBools) {
        if ([strBoolLow isEqualToString: [strBool lowercaseString]]) {
            return dConnectSpecBoolValues[i];
        }
        i ++;
    }
    @throw @"invalid strBool";
}
    
+ (NSString *) toBoolString: (BOOL)boolValue {
    
    BOOL dConnectSpecBoolValues[] = DConnectSpecBoolValues();
    
    int count = [DConnectSpecBools count];
    for (int i = 0; i < count; i ++) {
        if (dConnectSpecBoolValues[i] == boolValue) {
            return DConnectSpecBools[i];
        }
    }
    
    @throw @"invalid boolValue";
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
