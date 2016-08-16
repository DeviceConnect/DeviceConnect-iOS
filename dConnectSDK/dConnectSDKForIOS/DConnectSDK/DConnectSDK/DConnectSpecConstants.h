//
//  DConnectSpecConstants.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectMessage.h>

typedef enum {
    ONESHOT = 0,
    EVENT,
    STREAMING,
} DConnectSpecType;

typedef enum {
    GET = 0,
    PUT,
    POST,
    DELETE,
} DConnectSpecMethod;

typedef enum {
    ARRAY = 0,
    BOOLEAN,
    INTEGER,
    NUMBER,
    STRING,
    FILE_,
} DConnectSpecDataType;

typedef enum {
    INT32,
    INT64,
    FLOAT,
    DOUBLE,
    TEXT,
    BYTE,
    BINARY,
    DATE,
    DATE_TIME,
    PASSWORD,
    RGB,
} DConnectSpecDataFormat;


extern NSString * const DConnectSpecTypeOneshot;
extern NSString * const DConnectSpecTypeEvent;
extern NSString * const DConnectSpecTypeStreaming;

extern NSString * const DConnectSpecMethodGet;
extern NSString * const DConnectSpecMethodPut;
extern NSString * const DConnectSpecMethodPost;
extern NSString * const DConnectSpecMethodDelete;

extern NSString * const DConnectSpecDataTypeArray;
extern NSString * const DConnectSpecDataTypeBoolean;
extern NSString * const DConnectSpecDataTypeInteger;
extern NSString * const DConnectSpecDataTypeNumber;
extern NSString * const DConnectSpecDataTypeString;
extern NSString * const DConnectSpecDataTypeFile;

extern NSString * const DConnectSpecDataFormatInt32;
extern NSString * const DConnectSpecDataFormatInt64;
extern NSString * const DConnectSpecDataFormatFloat;
extern NSString * const DConnectSpecDataFormatDouble;
extern NSString * const DConnectSpecDataFormatText;
extern NSString * const DConnectSpecDataFormatByte;
extern NSString * const DConnectSpecDataFormatBinary;
extern NSString * const DConnectSpecDataFormatDate;
extern NSString * const DConnectSpecDataFormatDateTime;
extern NSString * const DConnectSpecDataFormatPassword;
extern NSString * const DConnectSpecDataFormatRGB;

extern NSString * const DConnectSpecBoolFalse;
extern NSString * const DConnectSpecBoolTrue;

#define DConnectSpecTypes() @[DConnectSpecTypeOneshot, DConnectSpecTypeEvent, DConnectSpecTypeStreaming]

#define DConnectSpecMethods() @[DConnectSpecMethodGet, DConnectSpecMethodPut, DConnectSpecMethodPost, DConnectSpecMethodDelete]

#define DConnectSpecDataTypes() @[DConnectSpecDataTypeArray, DConnectSpecDataTypeBoolean, DConnectSpecDataTypeInteger, DConnectSpecDataTypeNumber, DConnectSpecDataTypeString, DConnectSpecDataTypeFile]

#define DConnectSpecDataFormats() @[DConnectSpecDataFormatInt32, DConnectSpecDataFormatInt64, DConnectSpecDataFormatFloat, DConnectSpecDataFormatDouble, DConnectSpecDataFormatText, DConnectSpecDataFormatByte, DConnectSpecDataFormatBinary, DConnectSpecDataFormatDate, DConnectSpecDataFormatDateTime, DConnectSpecDataFormatPassword, DConnectSpecDataFormatRGB]

#define DConnectSpecBools() @[DConnectSpecBoolFalse,DConnectSpecBoolTrue]

#define DConnectSpecBoolValues()    {NO, YES}



@interface DConnectSpecConstants : NSObject

+ (BOOL) parseType: (NSString *)strType outType: (DConnectSpecType *) outType error: (NSError **) error;
+ (NSString *) toTypeString: (DConnectSpecType)type error:(NSError **) error;
+ (BOOL) parseMethod: (NSString *)strMethod outMethod: (DConnectSpecMethod *) outMethod error: (NSError **) error;
+ (BOOL) toMethodFromAction: (DConnectMessageActionType) method outMethod: (DConnectSpecMethod *) outMethod error: (NSError **) error;
+ (NSString *) toMethodString: (DConnectSpecMethod)method error: (NSError **) error;
+ (BOOL) parseDataType: (NSString *)strDataType outDataType: (DConnectSpecDataType *) outDataType error: (NSError **) error;
+ (NSString *) toDataTypeString: (DConnectSpecDataType)dataType error:(NSError **) error;
+ (BOOL) parseDataFormat: (NSString *)strDataFormat outDataFormat: (DConnectSpecDataFormat *) outDataFormat error:(NSError **) error;
+ (NSString *) toDataFormatString: (DConnectSpecDataFormat)dataFormat error:(NSError **)error;
+ (BOOL) parseBool: (id)idBool outBoolValue: (BOOL *)outBoolValue error:(NSError **) error;
+ (BOOL)isDigit:(NSString *)text;
+ (BOOL)isNumber:(NSString *)text;

@end
