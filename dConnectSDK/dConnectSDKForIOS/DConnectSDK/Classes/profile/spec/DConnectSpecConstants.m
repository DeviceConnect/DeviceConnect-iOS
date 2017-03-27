//
//  DConnectSpecConstants.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSpecConstants.h"
#import "DConnectSpecErrorFactory.h"

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

+ (BOOL) parseType: (NSString *)strType outType: (DConnectSpecType *) outType error: (NSError **) error {

    NSString *errorMessage;
    
    if (![strType isKindOfClass: [NSString class]]) {
        id idType = strType;
        errorMessage = [NSString stringWithFormat: @"parseType, not string parameter. class:%@", [[idType class] description]];
        *error = [DConnectSpecErrorFactory createError: errorMessage];
        return NO;
    }
    
    NSString *strTypeLow = [strType lowercaseString];
    
    int i = 0;
    NSArray *strTypes = DConnectSpecTypes();
    for (NSString *strType_ in strTypes) {
        if ([strTypeLow isEqualToString: [strType_ lowercaseString]]) {
            *outType = (DConnectSpecType)i;
            return YES;
        }
        i ++;
    }
    errorMessage = [NSString stringWithFormat: @"unknown type string :%@", strType];
    *error = [DConnectSpecErrorFactory createError: errorMessage];
    return NO;
}

+ (NSString *) toTypeString: (DConnectSpecType)type error:(NSError **) error {
    
    NSArray *types = DConnectSpecTypes();
    
    int index = (int)type;
    if (0 <= index && index < [types count]) {
        return DConnectSpecTypes()[index];
    }
    
    NSString *errorMessage = [NSString stringWithFormat: @"unknown type value :%d", (int)type];
    *error = [DConnectSpecErrorFactory createError: errorMessage];
    return nil;
}

+ (BOOL) parseMethod: (NSString *)strMethod outMethod: (DConnectSpecMethod *) outMethod error: (NSError **) error {
    
    if (![strMethod isKindOfClass: [NSString class]]) {
        *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"parseMethod Error. %@", strMethod]];
        return NO;
    }
    
    NSArray *methods = DConnectSpecMethods();
    
    NSString *strMethodLow = [strMethod lowercaseString];
    
    int i = 0;
    for (NSString *strMethod in methods) {
        if ([strMethodLow isEqualToString: [strMethod lowercaseString]]) {
            *outMethod = (DConnectSpecMethod)i;
            return YES;
        }
        i ++;
    }
    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"parseMethod Error. %@", strMethod]];
    return NO;
}
    
+ (NSString *) toMethodString: (DConnectSpecMethod)method error: (NSError **) error {
    
    NSArray *methods = DConnectSpecMethods();
    
    int index = (int)method;
    if (0 <= index && index < [methods count]) {
        return methods[index];
    }
    
    NSString *errorMessage = [NSString stringWithFormat: @"unknown method value :%d", (int)method];
    *error = [DConnectSpecErrorFactory createError: errorMessage];
    return nil;
}

+ (BOOL) toMethodFromAction: (DConnectMessageActionType) method outMethod: (DConnectSpecMethod *) outMethod error: (NSError **) error {
    
    if (method == DConnectMessageActionTypeGet) {
        *outMethod = GET;
        return YES;
    }
    if (method == DConnectMessageActionTypePut) {
        *outMethod = PUT;
        return YES;
    }
    if (method == DConnectMessageActionTypePost) {
        *outMethod = POST;
        return YES;
    }
    if (method == DConnectMessageActionTypeDelete) {
        *outMethod = DELETE;
        return YES;
    }

    NSString *errorMessage = [NSString stringWithFormat: @"unknown method value :%d", (int)method];
    *error = [DConnectSpecErrorFactory createError: errorMessage];
    return NO;
}

+ (BOOL) parseDataType: (NSString *)strDataType outDataType: (DConnectSpecDataType *) outDataType error: (NSError **) error {
    
    if (![strDataType isKindOfClass: [NSString class]]) {
        id idDataType = strDataType;
        NSString *errorMessage = [NSString stringWithFormat: @"parseDataType, not string parameter. class:%@", [[idDataType class] description]];
        *error = [DConnectSpecErrorFactory createError: errorMessage];
        return NO;
    }
    
    NSArray *dataTypes = DConnectSpecDataTypes();
    
    NSString *strDataTypeLow = [strDataType lowercaseString];
    
    int i = 0;
    for (NSString *dataType in dataTypes) {
        if ([strDataTypeLow isEqualToString: [dataType lowercaseString]]) {
            *outDataType = (DConnectSpecDataType)i;
            return YES;
        }
        i ++;
    }
    
    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"parseDataType Error. %@", strDataType]];
    return NO;
}

+ (NSString *) toDataTypeString: (DConnectSpecDataType)dataType error:(NSError **) error {
    NSArray *types = DConnectSpecDataTypes();
    int index = (int)dataType;
    if (0 <= index && index < [types count]) {
        return types[index];
    }
    
    NSString *errorMessage = [NSString stringWithFormat: @"unknown dataType value :%d", (int)dataType];
    *error = [DConnectSpecErrorFactory createError: errorMessage];
    return nil;
}

+ (BOOL) parseDataFormat: (NSString *)strDataFormat outDataFormat: (DConnectSpecDataFormat *) outDataFormat error:(NSError **) error {
    
    if (![strDataFormat isKindOfClass: [NSString class]]) {
        id idDataFormat = strDataFormat;
        NSString *errorMessage = [NSString stringWithFormat: @"parseDataFormat, not string parameter. class:%@", [[idDataFormat class] description]];
        *error = [DConnectSpecErrorFactory createError: errorMessage];
        return NO;
    }
    
    NSArray *dataFormats = DConnectSpecDataFormats();
    
    NSString *strDataFormatLow = [strDataFormat lowercaseString];
    
    int i = 0;
    for (NSString *strDataFormat in dataFormats) {
        if ([strDataFormatLow isEqualToString: [strDataFormat lowercaseString]]) {
            *outDataFormat = (DConnectSpecDataFormat)i;
            return YES;
        }
        i ++;
    }
    
    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"parseDataFormat Error. %@", strDataFormat]];
    return NO;
}

+ (NSString *) toDataFormatString: (DConnectSpecDataFormat)dataFormat error:(NSError **)error {
    NSArray *dataFormats = DConnectSpecDataFormats();
    int index = (int)dataFormat;
    if (0 <= index && index < [dataFormats count]) {
        return dataFormats[index];
    }
    
    NSString *errorMessage = [NSString stringWithFormat: @"unknown dataFormat value :%d", (int)dataFormat];
    *error = [DConnectSpecErrorFactory createError: errorMessage];
    return nil;
}

+ (BOOL) parseBool: (id)idBool outBoolValue: (BOOL *)outBoolValue error:(NSError **) error {
    if ([idBool isKindOfClass: [NSNumber class]]) {
        if ([[[idBool class] description] isEqualToString: @"__NSCFBoolean"]) {
            NSNumber *numBool = (NSNumber *)idBool;
            *outBoolValue = [numBool boolValue];
            return YES;
        } else {
            *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"parseBool, not bool or string parameter. class:%@", [[idBool class] description]]];
            return NO;
        }
    } else if ([idBool isKindOfClass: [NSString class]]) {
        NSArray *bools = DConnectSpecBools();
        BOOL boolValues[] = DConnectSpecBoolValues();
        
        NSString *strBool = (NSString *)idBool;
        NSString *strBoolLow = [strBool lowercaseString];
        int i = 0;
        for (NSString *strBool in bools) {
            if ([strBoolLow isEqualToString: [strBool lowercaseString]]) {
                *outBoolValue = boolValues[i];
                return YES;
            }
            i ++;
        }
        
        *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"parseBool, invalid bool value. %@", strBool]];
        return NO;
        
    } else {
        NSString *errorMessage = [NSString stringWithFormat: @"parseBool, not bool or string parameter. class:%@", [[idBool class] description]];
        *error = [DConnectSpecErrorFactory createError: errorMessage];
        return NO;
    }
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
    NSString *expression = @"^[-+]?([0-9]+)$";
    NSError *error = nil;
    
    NSRegularExpression *regex =
    [NSRegularExpression
     regularExpressionWithPattern:expression
     options:NSRegularExpressionCaseInsensitive
     error:&error];
    
    NSUInteger numberOfMatches =
    [regex numberOfMatchesInString:text
                           options:0
                             range:NSMakeRange(0, [text length])];
    
    return (numberOfMatches != 0);
}

+ (BOOL)isNumber:(NSString *)text {
    NSString *expression = @"^[-+]?([0-9]+)((\\.)[0-9]+)?$";
    NSError *error = nil;
    
    NSRegularExpression *regex =
    [NSRegularExpression
     regularExpressionWithPattern:expression
     options:NSRegularExpressionCaseInsensitive
     error:&error];
    
    NSUInteger numberOfMatches =
    [regex numberOfMatchesInString:text
                           options:0
                             range:NSMakeRange(0, [text length])];
    
    return (numberOfMatches != 0);
}

@end
