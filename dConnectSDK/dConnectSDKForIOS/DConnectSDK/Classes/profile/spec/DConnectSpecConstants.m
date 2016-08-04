//
//  DConnectSpecConstants.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
    NSArray *strTypes = DConnectSpecTypes();
    for (NSString *strType in strTypes) {
        if ([strTypeLow isEqualToString: [strType lowercaseString]]) {
            return (DConnectSpecType)i;
        }
        i ++;
    }
    @throw @"invalid strType";
}

+ (NSString *) toTypeString: (DConnectSpecType)type {
    
    NSArray *types = DConnectSpecTypes();
    
    int index = (int)type;
    if (index <= 0 && index < [types count]) {
        return DConnectSpecTypes()[index];
    }
    
    @throw @"invalid type";
}

+ (DConnectSpecMethod) parseMethod: (NSString *)strMethod {
    
    NSArray *methods = DConnectSpecMethods();
    
    NSString *strMethodLow = [strMethod lowercaseString];
    
    int i = 0;
    for (NSString *strMethod in methods) {
        if ([strMethodLow isEqualToString: [strMethod lowercaseString]]) {
            return (DConnectSpecMethod)i;
        }
        i ++;
    }
    @throw @"invalid strMethod";
}
    
+ (NSString *) toMethodString: (DConnectSpecMethod)method {
    
    NSArray *methods = DConnectSpecMethods();
    
    int index = (int)method;
    if (index <= 0 && index < [methods count]) {
        return methods[index];
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
    
    NSArray *dataTypes = DConnectSpecDataTypes();
    
    NSString *strDataTypeLow = [strDataType lowercaseString];
    
    int i = 0;
    for (NSString *dataType in dataTypes) {
        if ([strDataTypeLow isEqualToString: [dataType lowercaseString]]) {
            return (DConnectSpecDataType)i;
        }
        i ++;
    }
    @throw @"invalid strDataType";
}
    
+ (NSString *) toDataTypeString: (DConnectSpecDataType)dataType {
    NSArray *types = DConnectSpecDataTypes();
    int index = (int)dataType;
    if (index <= 0 && index < [types count]) {
        return types[index];
    }
    
    @throw @"invalid dataType";
}

+ (DConnectSpecDataFormat) parseDataFormat: (NSString *)strDataFormat {
    
    NSArray *dataFormats = DConnectSpecDataFormats();
    
    NSString *strDataFormatLow = [strDataFormat lowercaseString];
    
    int i = 0;
    for (NSString *strDataFormat in dataFormats) {
        if ([strDataFormatLow isEqualToString: [strDataFormat lowercaseString]]) {
            return (DConnectSpecDataFormat)i;
        }
        i ++;
    }
    @throw @"invalid strDataFormat";
}

+ (NSString *) toDataFormatString: (DConnectSpecDataFormat)dataFormat {
    NSArray *dataFormats = DConnectSpecDataFormats();
    int index = (int)dataFormat;
    if (index <= 0 && index < [dataFormats count]) {
        return dataFormats[index];
    }
    
    @throw @"invalid dataFormat";
}

    
+ (BOOL) parseBool: (NSString *)strBool {
    
    NSArray *bools = DConnectSpecBools();
    BOOL boolValues[] = DConnectSpecBoolValues();
    
    NSString *strBoolLow = [strBool lowercaseString];
    int i = 0;
    for (NSString *strBool in bools) {
        if ([strBoolLow isEqualToString: [strBool lowercaseString]]) {
            return boolValues[i];
        }
        i ++;
    }
    @throw @"invalid strBool";
}
    
+ (NSString *) toBoolString: (BOOL)boolValue {
    
    NSArray *bools = DConnectSpecBools();
    BOOL boolValues[] = DConnectSpecBoolValues();
    
    int count = [bools count];
    for (int i = 0; i < count; i ++) {
        if (boolValues[i] == boolValue) {
            return bools[i];
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
