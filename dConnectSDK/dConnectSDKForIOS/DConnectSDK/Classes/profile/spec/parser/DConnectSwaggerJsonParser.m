//
//  DConnectSwaggerJsonParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSwaggerJsonParser.h"
#import "DConnectProfileSpecBuilder.h"
#import "DConnectApiSpecBuilder.h"
#import "DConnectParameterSpec.h"

#import "DConnectIntegerDataSpecBuilder.h"
#import "DConnectNumberDataSpecBuilder.h"
#import "DConnectStringDataSpecBuilder.h"
#import "DConnectBooleanDataSpecBuilder.h"
#import "DConnectArrayDataSpecBuilder.h"

#import "DConnectIntegerParameterSpecBuilder.h"
#import "DConnectNumberParameterSpecBuilder.h"
#import "DConnectStringParameterSpecBuilder.h"
#import "DConnectBooleanParameterSpecBuilder.h"
#import "DConnectArrayParameterSpecBuilder.h"
#import "DConnectFileParameterSpecBuilder.h"

#import "DConnectSpecErrorFactory.h"

static NSString * const KEY_BASE_PATH = @"basePath";
static NSString * const KEY_PATHS = @"paths";

NSString * const OperationObjectParserKeyXType = @"x-type";
NSString * const OperationObjectParserKeyParameters = @"parameters";

NSString * const ParameterObjectParserKeyName = @"name";
NSString * const ParameterObjectParserKeyRequied = @"required";
NSString * const ParameterObjectParserKeyType = @"type";

NSString * const ItemObjectParserKeyFormat = @"format";     // ItemsObjectParser # KEY_FORMAT
NSString * const ItemObjectParserKeyMaximum = @"maximum";   // ItemsObjectParser # KEY_MAXIMUM
NSString * const ItemObjectParserKeyMinimum = @"minimum";   // ItemsObjectParser # KEY_MINIMUM
NSString * const ItemObjectParserKeyExclusiveMaximum = @"exclusiveMaximum"; // ItemsObjectParser # KEY_EXCLUSIVE_MAXIMUM
NSString * const ItemObjectParserKeyExclusiveMinimum = @"exclusiveMinimum"; // ItemsObjectParser # KEY_EXCLUSIVE_MINIMUM
NSString * const ItemObjectParserKeyMaxLength = @"maxLength";       // ItemsObjectParser # KEY_MAX_LENGTH
NSString * const ItemObjectParserKeyMinLength = @"minLength";       // ItemsObjectParser # KEY_MIN_LENGTH
NSString * const ItemObjectParserKeyEnum = @"enum";                 // ItemsObjectParser # KEY_ENUM
NSString * const ItemObjectParserKeyItems = @"items";                // ItemsObjectParser # KEY_ITEMS


typedef DConnectApiSpec * (^OperationObjectParser)(DConnectSpecMethod method, NSDictionary *jsonOpObj, NSError **error);
typedef DConnectDataSpec * (^ItemsObjectParser)(NSDictionary *json, NSError **error);
typedef DConnectParameterSpec * (^ParameterObjectParser)(NSDictionary *json, NSError **error);

@interface DConnectSwaggerJsonParser()
    
@property(nonatomic, strong) OperationObjectParser OPERATION_OBJECT_PARSER;
    
@property(nonatomic, strong) ItemsObjectParser ARRAY_ITEMS_PARSER;
@property(nonatomic, strong) ItemsObjectParser BOOLEAN_ITEMS_PARSER;
@property(nonatomic, strong) ItemsObjectParser INTEGER_ITEMS_PARSER;
@property(nonatomic, strong) ItemsObjectParser NUMBER_ITEMS_PARSER;
@property(nonatomic, strong) ItemsObjectParser STRING_ITEMS_PARSER;
    
@property(nonatomic, strong) ParameterObjectParser ARRAY_PARAM_PARSER;
@property(nonatomic, strong) ParameterObjectParser BOOLEAN_PARAM_PARSER;
@property(nonatomic, strong) ParameterObjectParser FILE_PARAM_PARSER;
@property(nonatomic, strong) ParameterObjectParser INTEGER_PARAM_PARSER;
@property(nonatomic, strong) ParameterObjectParser NUMBER_PARAM_PARSER;
@property(nonatomic, strong) ParameterObjectParser STRING_PARAM_PARSER;

@end


@implementation DConnectSwaggerJsonParser

- (instancetype) init {
    
    self = [super init];
    if (self) {
        __weak DConnectSwaggerJsonParser *weakSelf = self;
        
        // private static final OperationObjectParser OPERATION_OBJECT_PARSER = new OperationObjectParser();
        self.OPERATION_OBJECT_PARSER = ^ DConnectApiSpec * (DConnectSpecMethod method, NSDictionary *jsonOpObj, NSError **error) {
            DConnectSpecType type;
            if (![DConnectSpecConstants parseType: jsonOpObj[OperationObjectParserKeyXType] outType: &type error: error]) {
                return nil;
            }
            NSArray *parameters = jsonOpObj[OperationObjectParserKeyParameters];
            
            NSMutableArray *paramSpecs = [NSMutableArray array]; // DConnectParameterSpecの配列
            
            for (NSDictionary *paramObj in parameters) {
                
                if (!paramObj) {
                    continue;
                }
                
                ParameterObjectParser parser = [weakSelf getParameterParser: paramObj error: error];
                if (!parser) {
                    return nil;
                }
                DConnectParameterSpec *paramSpec = parser(paramObj, error);
                if (!paramSpec) {
                    return nil;
                }
                [paramSpecs addObject: paramSpec];
            }
            
            DConnectApiSpecBuilder *builder = [[DConnectApiSpecBuilder alloc] init];
            [builder setType: type];
            [builder setMethod: method];
            [builder setParams: paramSpecs];
            return [builder build];
        };
        
        // private static final ItemsObjectParser ARRAY_ITEMS_PARSER = new ArrayItemsObjectParser();
        self.ARRAY_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json, NSError **error) {
            DConnectArrayDataSpecBuilder *builder = [[DConnectArrayDataSpecBuilder alloc] init];
            
            NSDictionary *itemsObj = json[ItemObjectParserKeyItems];
            ItemsObjectParser parser = [weakSelf getItemsParser: itemsObj error: error];
            if (!parser) {
                return nil;
            }
            DConnectDataSpec *itemSpec = parser(itemsObj, error);
            if (!itemSpec) {
                return nil;
            }
            [builder setItemsSpec: itemSpec];
            
            if (json[ItemObjectParserKeyMaxLength]) {
                [builder setMaxLength: json[ItemObjectParserKeyMaxLength]];
            }
            if (json[ItemObjectParserKeyMinLength]) {
                [builder setMinLength: json[ItemObjectParserKeyMinLength]];
            }
            return [builder build];
        };
                 
        // BOOLEAN_ITEMS_PARSER = new BooleanItemsObjectParser();
        self.BOOLEAN_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json, NSError **error) {
            return [[[DConnectBooleanDataSpecBuilder alloc] init] build];
        };
                 
        // INTEGER_ITEMS_PARSER = new IntegerItemsObjectParser();
        self.INTEGER_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json, NSError **error) {
            DConnectIntegerDataSpecBuilder *builder = [[DConnectIntegerDataSpecBuilder alloc] init];
            if (json[ItemObjectParserKeyFormat]) {
                DConnectSpecDataFormat dataFormat;
                if (![DConnectSpecConstants parseDataFormat:json[ItemObjectParserKeyFormat] outDataFormat:&dataFormat error: error]) {
                    return nil;
                }
                [builder setFormat: dataFormat];
            }
            if (json[ItemObjectParserKeyMaximum]) {
                if ([json[ItemObjectParserKeyMaximum] isKindOfClass: [NSNumber class]]) {
                    [builder setMaximum: json[ItemObjectParserKeyMaximum]];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"maximum is invalid: %@", json[ItemObjectParserKeyMaximum]]];
                    return nil;
                }
            }
            if (json[ItemObjectParserKeyMinimum]) {
                if ([json[ItemObjectParserKeyMinimum] isKindOfClass: [NSNumber class]]) {
                    [builder setMinimum: json[ItemObjectParserKeyMinimum]];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"minimum is invalid: %@", json[ItemObjectParserKeyMinimum]]];
                    return nil;
                }
            }
            if (json[ItemObjectParserKeyExclusiveMaximum]) {
                BOOL exclusiveMaximumValue;
                if (![DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMaximum] outBoolValue:&exclusiveMaximumValue error: error]) {
                    return nil;
                }
                [builder setExclusiveMaximum: exclusiveMaximumValue];
            }
            if (json[ItemObjectParserKeyExclusiveMinimum]) {
                BOOL exclusiveMinimumValue;
                if (![DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMinimum] outBoolValue:&exclusiveMinimumValue error: error]) {
                    return nil;
                }
                [builder setExclusiveMinimum: exclusiveMinimumValue];
            }
            if (json[ItemObjectParserKeyEnum]) {
                NSArray *array = json[ItemObjectParserKeyEnum];
                if ([array isKindOfClass: [NSArray class]]) {
                    
                    NSMutableArray *enums = [NSMutableArray array];
                    for (int i = 0; i < [array count]; i ++) {
                        if ([array[i] isKindOfClass:[NSNumber class]]) {
                            [enums addObject: array[i]];
                        } else {
                            *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"enum is invalid: %@", json[ItemObjectParserKeyEnum]]];
                            return nil;
                        }
                    }
                    [builder setEnumList: enums];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"enum is invalid: %@", json[ItemObjectParserKeyEnum]]];
                    return nil;
                }
            }
            return [builder build];
        };
        
        // NUMBER_ITEMS_PARSER = new NumberItemsObjectParser();
        self.NUMBER_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json, NSError **error) {
            DConnectNumberDataSpecBuilder *builder = [[DConnectNumberDataSpecBuilder alloc] init];
            if (json[ItemObjectParserKeyFormat]) {
                DConnectSpecDataFormat dataFormat;
                if (![DConnectSpecConstants parseDataFormat:json[ItemObjectParserKeyFormat] outDataFormat:&dataFormat error:error]) {
                    return nil;
                }
                [builder setDataFormat: dataFormat];
            }
            if (json[ItemObjectParserKeyMaximum]) {
                if ([json[ItemObjectParserKeyMaximum] isKindOfClass: [NSNumber class]]) {
                    [builder setMaximum: json[ItemObjectParserKeyMaximum]];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"maximum is invalid: %@", json[ItemObjectParserKeyMaximum]]];
                    return nil;
                }
            }
            if (json[ItemObjectParserKeyMinimum]) {
                if ([json[ItemObjectParserKeyMinimum] isKindOfClass: [NSNumber class]]) {
                    [builder setMinimum: json[ItemObjectParserKeyMinimum]];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"minimum is invalid: %@", json[ItemObjectParserKeyMinimum]]];
                    return nil;
                }
            }
            if (json[ItemObjectParserKeyExclusiveMaximum]) {
                BOOL exclusiveMaximum;
                if (![DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMaximum] outBoolValue:&exclusiveMaximum error: error]) {
                    return nil;
                }
                [builder setExclusiveMaximum: exclusiveMaximum];
            }
            if (json[ItemObjectParserKeyExclusiveMinimum]) {
                BOOL exclusiveMinimum;
                if (![DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMinimum] outBoolValue:&exclusiveMinimum error: error]) {
                    return nil;
                }
                [builder setExclusiveMinimum: exclusiveMinimum];
            }
            return [builder build];
        };
        
        // STRING_ITEMS_PARSER = new StringItemsObjectParser();
        self.STRING_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json, NSError **error) {
            DConnectStringDataSpecBuilder *builder = [[DConnectStringDataSpecBuilder alloc] init];
            if (json[ItemObjectParserKeyFormat]) {
                DConnectSpecDataFormat dataFormat;
                if (![DConnectSpecConstants parseDataFormat:json[ItemObjectParserKeyFormat] outDataFormat: &dataFormat error:error]) {
                    return nil;
                }
                [builder setFormat: dataFormat];
            }
            if (json[ItemObjectParserKeyMaxLength]) {
                if ([json[ItemObjectParserKeyMaxLength] isKindOfClass: [NSNumber class]]) {
                    [builder setMaxLength: json[ItemObjectParserKeyMaxLength]];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"maxlength is invalid: %@", json[ItemObjectParserKeyMaximum]]];
                    return nil;
                }
            }
            if (json[ItemObjectParserKeyMinLength]) {
                if ([json[ItemObjectParserKeyMinLength] isKindOfClass:[NSNumber class]]) {
                    [builder setMinLength: [NSNumber numberWithLong: [json[ItemObjectParserKeyMinLength] longValue]]];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"minlength is invalid: %@", json[ItemObjectParserKeyMinimum]]];
                    return nil;
                }
            }
            if (json[ItemObjectParserKeyEnum]) {
                NSArray *array = json[ItemObjectParserKeyEnum];
                if ([array isKindOfClass: [NSArray class]]) {
                    
                    NSMutableArray *enums = [NSMutableArray array];
                    for (int i = 0; i < [array count]; i ++) {
                        [enums addObject: array[i]];
                    }
                    [builder setEnums: enums];
                } else {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"enum is invalid: %@", json[ItemObjectParserKeyEnum]]];
                    return nil;
                }
            }
            return [builder build];
        };
        
        // ARRAY_PARAM_PARSER = new ArrayParameterParser();
        self.ARRAY_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json, NSError **error) {
            DConnectArrayDataSpec *dataSpec = (DConnectArrayDataSpec *) weakSelf.ARRAY_ITEMS_PARSER(json, error);
            if (!dataSpec) {
                return nil;
            }
            
            DConnectArrayParameterSpecBuilder *builder = [[DConnectArrayParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            
            if (json[ParameterObjectParserKeyRequied]) {
                BOOL required;
                if (![DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied] outBoolValue:&required error: error]) {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]]];
                    return nil;
                } else {
                    [builder setIsRequired: [json[ParameterObjectParserKeyRequied] boolValue]];
                }
            }
            
            [builder setItemSpec: [dataSpec itemsSpec]];
            [builder setMaxLength: [dataSpec maxLength]];
            [builder setMinLength: [dataSpec minLength]];
            return [builder build];
        };
        
        // BOOLEAN_PARAM_PARSER = new BooleanParameterParser();
        self.BOOLEAN_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json, NSError **error) {
            DConnectBooleanParameterSpecBuilder *builder = [[DConnectBooleanParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if (json[ParameterObjectParserKeyRequied]) {
                BOOL required;
                if (![DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied] outBoolValue:&required error: error]) {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]]];
                    return nil;
                }
                [builder setIsRequired: required];
            }
            return [builder build];
        };
        
        // FILE_PARAM_PARSER = new FileParameterParser();
        self.FILE_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json, NSError **error) {
            DConnectFileParameterSpecBuilder *builder = [[DConnectFileParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];

            if (json[ParameterObjectParserKeyRequied]) {
                BOOL required;
                if (![DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied] outBoolValue:&required error:error]) {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]]];
                    return nil;
                }
                [builder setIsRequired: required];
            }
            return [builder build];
        };

        // INTEGER_PARAM_PARSER = new IntegerParameterParser();
        self.INTEGER_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json, NSError **error) {
            DConnectIntegerDataSpec *dataSpec = (DConnectIntegerDataSpec *) weakSelf.INTEGER_ITEMS_PARSER(json, error);
            if (!dataSpec) {
                return nil;
            }
            
            DConnectIntegerParameterSpecBuilder *builder = [[DConnectIntegerParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if (json[ParameterObjectParserKeyRequied]) {
                BOOL required;
                if (![DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied] outBoolValue:&required error:error]) {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]]];
                    return nil;
                }
                [builder setIsRequired: required];
            }
            [builder setDataFormat: [dataSpec format]];
            [builder setMaximum: [dataSpec maximum]];
            [builder setMinimum: [dataSpec minimum]];
            [builder setExclusiveMaximum: [dataSpec exclusiveMaximum]];
            [builder setExclusiveMinimum: [dataSpec exclusiveMinimum]];
            [builder setEnumList: [dataSpec enumList]];
            return [builder build];
        };

        // NUMBER_PARAM_PARSER = new NumberParameterParser();
        self.NUMBER_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json, NSError **error) {
            DConnectNumberDataSpec *dataSpec = (DConnectNumberDataSpec *) weakSelf.NUMBER_ITEMS_PARSER(json, error);
            if (!dataSpec) {
                return nil;
            }
            
            DConnectNumberParameterSpecBuilder *builder = [[DConnectNumberParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if (json[ParameterObjectParserKeyRequied]) {
                BOOL required;
                if (![DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied] outBoolValue:&required error:error]) {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]]];
                    return nil;
                }
                [builder setIsRequired: required];
            }
            [builder setDataFormat: [dataSpec dataFormat]];
            [builder setMaximum: [dataSpec maximum]];
            [builder setMinimum: [dataSpec minimum]];
            [builder setExclusiveMaximum: [dataSpec exclusiveMaximum]];
            [builder setExclusiveMinimum: [dataSpec exclusiveMinimum]];
            return [builder build];
        };
        
        // STRING_PARAM_PARSER = new StringParameterParser();
        self.STRING_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json, NSError **error) {
            DConnectStringDataSpec *dataSpec = (DConnectStringDataSpec *) weakSelf.STRING_ITEMS_PARSER(json, error);
            if (!dataSpec) {
                return nil;
            }
            
            DConnectStringParameterSpecBuilder *builder = [[DConnectStringParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if (json[ParameterObjectParserKeyRequied]) {
                BOOL required;
                if (![DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied] outBoolValue:&required error:error]) {
                    *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]]];
                    return nil;
                }
                [builder setIsRequired: required];
            }
            [builder setDataFormat: [dataSpec dataFormat]];
            [builder setMaxLength: [dataSpec maxLength]];
            [builder setMinLength: [dataSpec minLength]];
            [builder setEnums: [dataSpec enums]];
            
            return [builder build];
        };
    }
    return self;
}


#pragma mark - DConnectProfileSpecJsonParser Methods.

- (DConnectProfileSpec *) parseJson: (NSDictionary *) json error:(NSError **) error {
    DConnectProfileSpecBuilder *builder = [[DConnectProfileSpecBuilder alloc] init];
    [builder setBundle: json];        // JSONパースでNSDictionary,NSArrayに変換されるのでtoBundle()処理は不要。そのままjsonを代入する。
    
    
    NSString *basePath = json[KEY_BASE_PATH];
    if (basePath) {
        NSArray *parts = [basePath componentsSeparatedByString:@"/"];
        if (parts.count != 3) {
            *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"basePath is invalid: %@", basePath]];
            return nil;
        }
        [builder setApi:parts[1]];
        [builder setProfile:parts[2]];
    }
    
    NSDictionary *pathsObj = json[KEY_PATHS];
    for (NSString *path in pathsObj.allKeys) {
        NSDictionary *pathObj = [pathsObj objectForKey: path];
        
        NSArray *strMethods = DConnectSpecMethods();
        for (NSString *strMethod in strMethods) {
            NSString *strMethodLow = [strMethod lowercaseString];
            NSDictionary *opObj = [pathObj objectForKey: strMethodLow];
            if (!opObj) {
                continue;
            }
            DConnectSpecMethod method;
            if (![DConnectSpecConstants parseMethod: strMethod outMethod:&method error: error]) {
                return nil;
            }
            DConnectApiSpec *apiSpec = self.OPERATION_OBJECT_PARSER(method, opObj, error);
            if (apiSpec) {
                [builder addApiSpec: path method: method apiSpec: apiSpec error: error];
            } else {
                return nil;
            }
        }
    }
    
    return [builder build];
}

#pragma mark - Private Methods.

- (ParameterObjectParser) getParameterParser: (NSDictionary *) json error: (NSError **) error {
    
    NSString *type = json[ParameterObjectParserKeyType];
    DConnectSpecDataType paramType;
    if (![DConnectSpecConstants parseDataType: type outDataType:&paramType error:error]) {
        return nil;
    }
    switch (paramType) {
        case BOOLEAN:
            return self.BOOLEAN_PARAM_PARSER;
        case INTEGER:
            return self.INTEGER_PARAM_PARSER;
        case NUMBER:
            return self.NUMBER_PARAM_PARSER;
        case STRING:
            return self.STRING_PARAM_PARSER;
        case FILE_:
            return self.FILE_PARAM_PARSER;
        case ARRAY:
            return self.ARRAY_PARAM_PARSER;
        default:
            *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"Invalid parameter type '%@' is specified.", type]];
            return nil;
    }
}

- (ParameterObjectParser) getItemsParser: (NSDictionary *) json error: (NSError **) error {
    NSString *type = json[ParameterObjectParserKeyType];

    DConnectSpecDataType paramType;
    if (![DConnectSpecConstants parseDataType: type outDataType: &paramType error:error]) {
        return nil;
    }

    switch (paramType) {
        case BOOLEAN:
            return self.BOOLEAN_PARAM_PARSER;
        case INTEGER:
            return self.INTEGER_PARAM_PARSER;
        case NUMBER:
            return self.NUMBER_PARAM_PARSER;
        case STRING:
            return self.STRING_PARAM_PARSER;
        case FILE_:
            return self.FILE_PARAM_PARSER;
        case ARRAY:
            return self.ARRAY_PARAM_PARSER;
        default:
            *error = [DConnectSpecErrorFactory createError: [NSString stringWithFormat: @"Invalid parameter type '%@' is specified.", type]];
            return nil;
    }
}
 
                 
                 
                 
                 
@end
