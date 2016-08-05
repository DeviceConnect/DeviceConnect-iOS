//
//  SwaggerJsonParser.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SwaggerJsonParser.h"
#import "DConnectProfileSpecBuilder.h"
#import "DConnectApiSpecBuilder.h"
#import "DConnectParameterSpec.h"

#import "IntegerDataSpecBuilder.h"
#import "NumberDataSpecBuilder.h"
#import "StringDataSpecBuilder.h"
#import "BooleanDataSpecBuilder.h"
#import "ArrayDataSpecBuilder.h"

#import "IntegerParameterSpecBuilder.h"
#import "NumberParameterSpecBuilder.h"
#import "StringParameterSpecBuilder.h"
#import "BooleanParameterSpecBuilder.h"
#import "ArrayParameterSpecBuilder.h"
#import "FileParameterSpecBuilder.h"

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


typedef DConnectApiSpec * (^OperationObjectParser)(DConnectSpecMethod method, NSDictionary *jsonOpObj);
typedef DConnectDataSpec * (^ItemsObjectParser)(NSDictionary *json);
typedef DConnectParameterSpec * (^ParameterObjectParser)(NSDictionary *json);

@interface SwaggerJsonParser()
    
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


@implementation SwaggerJsonParser

- (instancetype) init {
    
    self = [super init];
    if (self) {
        __weak SwaggerJsonParser *weakSelf = self;
        
        // private static final OperationObjectParser OPERATION_OBJECT_PARSER = new OperationObjectParser();
        self.OPERATION_OBJECT_PARSER = ^ DConnectApiSpec * (DConnectSpecMethod method, NSDictionary *jsonOpObj) {
            
            DConnectSpecType type = [DConnectSpecConstants parseType: jsonOpObj[OperationObjectParserKeyXType]];
            NSArray *parameters = jsonOpObj[OperationObjectParserKeyParameters];
            
            NSMutableArray *paramSpecs = [NSMutableArray array]; // DConnectParameterSpecの配列
            
            for (NSDictionary *paramObj in parameters) {
                ParameterObjectParser parser = [weakSelf getParameterParser: paramObj];
                DConnectParameterSpec *paramSpec = parser(paramObj);
                [paramSpecs addObject: paramSpec];
            }
            
            DConnectApiSpecBuilder *builder = [[DConnectApiSpecBuilder alloc] init];
            [builder setType: type];
            [builder setMethod: method];
            [builder setParams: paramSpecs];
            return [builder build];
        };
        
        // private static final ItemsObjectParser ARRAY_ITEMS_PARSER = new ArrayItemsObjectParser();
        self.ARRAY_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            ArrayDataSpecBuilder *builder = [[ArrayDataSpecBuilder alloc] init];
            
            NSDictionary *itemsObj = json[ItemObjectParserKeyItems];
            ItemsObjectParser parser = [weakSelf getItemsParser: itemsObj];
            DConnectDataSpec *itemSpec = parser(itemsObj);
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
        self.BOOLEAN_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            return [[[BooleanDataSpecBuilder alloc] init] build];
        };
                 
        // INTEGER_ITEMS_PARSER = new IntegerItemsObjectParser();
        self.INTEGER_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            IntegerDataSpecBuilder *builder = [[IntegerDataSpecBuilder alloc] init];
            if (json[ItemObjectParserKeyFormat]) {
                DConnectSpecDataFormat format = [DConnectSpecConstants parseDataFormat:json[ItemObjectParserKeyFormat]];
                if (!format) {
                    @throw [NSString stringWithFormat: @"format is invalid: %@", json[ItemObjectParserKeyFormat]];
                }
                [builder setFormat: format];
            }
            if (json[ItemObjectParserKeyMaximum]) {
                if ([DConnectSpecConstants isDigit: json[ItemObjectParserKeyMaximum]]) {
                    [builder setMaximum: [NSNumber numberWithLong: [json[ItemObjectParserKeyMaximum] longValue]]];
                } else {
                    @throw [NSString stringWithFormat: @"maximum is invalid: %@", json[ItemObjectParserKeyMaximum]];
                }
            }
            if (json[ItemObjectParserKeyMinimum]) {
                if ([DConnectSpecConstants isDigit: json[ItemObjectParserKeyMinimum]]) {
                    [builder setMinimum: [NSNumber numberWithLong: [json[ItemObjectParserKeyMinimum] longValue]]];
                } else {
                    @throw [NSString stringWithFormat: @"minimum is invalid: %@", json[ItemObjectParserKeyMinimum]];
                }
            }
            if (json[ItemObjectParserKeyExclusiveMaximum]) {
                if ([DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMaximum]]) {
                    [builder setExclusiveMaximum: [DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMaximum]]];
                } else {
                    @throw [NSString stringWithFormat: @"exclusive maximum is invalid: %@", json[ItemObjectParserKeyExclusiveMaximum]];
                }
            }
            if (json[ItemObjectParserKeyExclusiveMinimum]) {
                if ([DConnectSpecConstants isDigit: json[ItemObjectParserKeyExclusiveMinimum]]) {
                    [builder setExclusiveMinimum: [DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMinimum]]];
                } else {
                    @throw [NSString stringWithFormat: @"exclusive minimum is invalid: %@", json[ItemObjectParserKeyExclusiveMinimum]];
                }
            }
            if (json[ItemObjectParserKeyEnum]) {
                NSArray *array = json[ItemObjectParserKeyEnum];
                if ([array isKindOfClass: [NSArray class]]) {
                    
                    NSMutableArray *enums = [NSMutableArray array];
                    for (int i = 0; i < [array count]; i ++) {
                        if ([DConnectSpecConstants isDigit: array[i]]) {
                            [enums addObject: [NSNumber numberWithLong:[array[i] longValue]]];
                        } else {
                            @throw [NSString stringWithFormat: @"enum is invalid: %@", json[ItemObjectParserKeyEnum]];
                        }
                    }
                    [builder setEnumList: enums];
                } else {
                    @throw [NSString stringWithFormat: @"enum is invalid: %@", json[ItemObjectParserKeyEnum]];
                }
            }
            return [builder build];
        };
        
        // NUMBER_ITEMS_PARSER = new NumberItemsObjectParser();
        self.NUMBER_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            NumberDataSpecBuilder *builder = [[NumberDataSpecBuilder alloc] init];
            if (json[ItemObjectParserKeyFormat]) {
                DConnectSpecDataFormat format = [DConnectSpecConstants parseDataFormat:json[ItemObjectParserKeyFormat]];
                if (!format) {
                    @throw [NSString stringWithFormat: @"format is invalid: %@", json[ItemObjectParserKeyFormat]];
                }
                [builder setDataFormat: format];
            }
            if (json[ItemObjectParserKeyMaximum]) {
                if ([DConnectSpecConstants isNumber: json[ItemObjectParserKeyMaximum]]) {
                    [builder setMaximum: [NSNumber numberWithDouble: [json[ItemObjectParserKeyMaximum] doubleValue]]];
                } else {
                    @throw [NSString stringWithFormat: @"maximum is invalid: %@", json[ItemObjectParserKeyMaximum]];
                }
            }
            if (json[ItemObjectParserKeyMinimum]) {
                if ([DConnectSpecConstants isNumber: json[ItemObjectParserKeyMinimum]]) {
                    [builder setMinimum: [NSNumber numberWithDouble: [json[ItemObjectParserKeyMinimum] doubleValue]]];
                } else {
                    @throw [NSString stringWithFormat: @"minimum is invalid: %@", json[ItemObjectParserKeyMinimum]];
                }
            }
            if (json[ItemObjectParserKeyExclusiveMaximum]) {
                if ([DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMaximum]]) {
                    [builder setExclusiveMaximum: [DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMaximum]]];
                } else {
                    @throw [NSString stringWithFormat: @"exclusive maximum is invalid: %@", json[ItemObjectParserKeyExclusiveMaximum]];
                }
            }
            if (json[ItemObjectParserKeyExclusiveMinimum]) {
                if ([DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMinimum]]) {
                    [builder setExclusiveMinimum: [DConnectSpecConstants parseBool: json[ItemObjectParserKeyExclusiveMinimum]]];
                } else {
                    @throw [NSString stringWithFormat: @"exclusive minimum is invalid: %@", json[ItemObjectParserKeyExclusiveMinimum]];
                }
            }
            return [builder build];
        };
        
        // STRING_ITEMS_PARSER = new StringItemsObjectParser();
        self.STRING_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            StringDataSpecBuilder *builder = [[StringDataSpecBuilder alloc] init];
            if (json[ItemObjectParserKeyFormat]) {
                DConnectSpecDataFormat format = [DConnectSpecConstants parseDataFormat:json[ItemObjectParserKeyFormat]];
                if (!format) {
                    @throw [NSString stringWithFormat: @"format is invalid: %@", json[ItemObjectParserKeyFormat]];
                }
                [builder setFormat: format];
            }
            if (json[ItemObjectParserKeyMaxLength]) {
                if ([DConnectSpecConstants isDigit: json[ItemObjectParserKeyMaxLength]]) {
                    [builder setMaxLength: [NSNumber numberWithLong: [json[ItemObjectParserKeyMaxLength] longValue]]];
                } else {
                    @throw [NSString stringWithFormat: @"maxlength is invalid: %@", json[ItemObjectParserKeyMaximum]];
                }
            }
            if (json[ItemObjectParserKeyMinLength]) {
                if ([DConnectSpecConstants isDigit: json[ItemObjectParserKeyMinLength]]) {
                    [builder setMinLength: [NSNumber numberWithLong: [json[ItemObjectParserKeyMinLength] longValue]]];
                } else {
                    @throw [NSString stringWithFormat: @"minlength is invalid: %@", json[ItemObjectParserKeyMinimum]];
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
                    @throw [NSString stringWithFormat: @"enum is invalid: %@", json[ItemObjectParserKeyEnum]];
                }
            }
            return [builder build];
        };
        
        // ARRAY_PARAM_PARSER = new ArrayParameterParser();
        self.ARRAY_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json) {
            ArrayDataSpec *dataSpec = (ArrayDataSpec *) weakSelf.ARRAY_ITEMS_PARSER(json);
            if (!dataSpec) {
                @throw [NSString stringWithFormat: @"dataspec is invalid"];
            }
            
            ArrayParameterSpecBuilder *builder = [[ArrayParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            
            if (json[ParameterObjectParserKeyRequied]) {
                if ([DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]) {
                    [builder setIsRequired: [json[ParameterObjectParserKeyRequied] boolValue]];
                } else {
                    @throw [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]];
                }
            }
            
            [builder setItemSpec: [dataSpec itemsSpec]];
            [builder setMaxLength: [dataSpec maxLength]];
            [builder setMinLength: [dataSpec minLength]];
            return [builder build];
        };
        
        // BOOLEAN_PARAM_PARSER = new BooleanParameterParser();
        self.BOOLEAN_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json) {
            BooleanParameterSpecBuilder *builder = [[BooleanParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if (json[ParameterObjectParserKeyRequied]) {
                if ([DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]) {
                    [builder setIsRequired: [json[ParameterObjectParserKeyRequied] boolValue]];
                } else {
                    @throw [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]];
                }
            }
            return [builder build];
        };
        
        // FILE_PARAM_PARSER = new FileParameterParser();
        self.FILE_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json) {
            FileParameterSpecBuilder *builder = [[FileParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if ([DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]) {
                [builder setIsRequired: [json[ParameterObjectParserKeyRequied] boolValue]];
            } else {
                @throw [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]];
            }
            return [builder build];
        };

        // INTEGER_PARAM_PARSER = new IntegerParameterParser();
        self.INTEGER_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json) {
            IntegerDataSpec *dataSpec = (IntegerDataSpec *) weakSelf.INTEGER_ITEMS_PARSER(json);
            
            IntegerParameterSpecBuilder *builder = [[IntegerParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if ([DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]) {
                [builder setIsRequired: [DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]];
            } else {
                @throw [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]];
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
        self.NUMBER_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json) {
            NumberDataSpec *dataSpec = (NumberDataSpec *) weakSelf.NUMBER_ITEMS_PARSER(json);
            
            NumberParameterSpecBuilder *builder = [[NumberParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if ([DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]) {
                [builder setIsRequired: [DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]];
            } else {
                @throw [NSString stringWithFormat: @"required is invalid: %@", json[ParameterObjectParserKeyRequied]];
            }
            [builder setDataFormat: [dataSpec dataFormat]];
            [builder setMaximum: [dataSpec maximum]];
            [builder setMinimum: [dataSpec minimum]];
            [builder setExclusiveMaximum: [dataSpec exclusiveMaximum]];
            [builder setExclusiveMinimum: [dataSpec exclusiveMinimum]];
            return [builder build];
        };
        
        // STRING_PARAM_PARSER = new StringParameterParser();
        self.STRING_PARAM_PARSER = ^ DConnectParameterSpec * (NSDictionary *json) {
            StringDataSpec *dataSpec = (StringDataSpec *) weakSelf.STRING_ITEMS_PARSER(json);
            
            NSLog(@"      STRING_PARAM_PARSER - StringParameterSpecBuilder init");
            StringParameterSpecBuilder *builder = [[StringParameterSpecBuilder alloc] init];
            [builder setName: json[ParameterObjectParserKeyName]];
            if (json[ParameterObjectParserKeyRequied]) {
                [builder setIsRequired: [DConnectSpecConstants parseBool: json[ParameterObjectParserKeyRequied]]];
            }
            [builder setDataFormat: [dataSpec dataFormat]];
            [builder setMaxLength: [[dataSpec maxLength] longValue]];
            [builder setMinLength: [[dataSpec minLength] longValue]];
            [builder setEnums: [dataSpec enums]];
            
            return [builder build];
        };
    }
    return self;
}


#pragma mark - DConnectProfileSpecJsonParser Methods.

- (DConnectProfileSpec *) parseJson: (NSDictionary *) json {
    DConnectProfileSpecBuilder *builder = [[DConnectProfileSpecBuilder alloc] init];
    [builder setBundle: json];        // JSONパースでNSDictionary,NSArrayに変換されるのでtoBundle()処理は不要。そのままjsonを代入する。
    
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
            DConnectSpecMethod method = [DConnectSpecConstants parseMethod: strMethod];
            DConnectApiSpec *apiSpec = self.OPERATION_OBJECT_PARSER(method, opObj);
            if (apiSpec) {
                [builder addApiSpec: path method: method apiSpec: apiSpec];
            }
        }
    }
    
    return [builder build];
}

#pragma mark - Private Methods.

- (ParameterObjectParser) getParameterParser: (NSDictionary *) json {
    
    NSString *type = json[ParameterObjectParserKeyType];
    DConnectSpecDataType paramType;
    @try {
    paramType = [DConnectSpecConstants parseDataType: type];
    }
    @catch (NSString *e) {
    }
//    if (!paramType) {
//         @throw [NSString stringWithFormat: @"Unknown parameter type '%@' is specified.", type];
//    }
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
            @throw [NSString stringWithFormat: @"Invalid parameter type '%@' is specified.", type];
    }
}

- (ParameterObjectParser) getItemsParser: (NSDictionary *) json {
    NSString *type = json[ParameterObjectParserKeyType];
    DConnectSpecDataType paramType = [DConnectSpecConstants parseDataType: type];
    if (!paramType) {
         @throw [NSString stringWithFormat: @"Unknown parameter type '%@' is specified.", type];
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
            @throw [NSString stringWithFormat: @"Invalid parameter type '%@' is specified.", type];
    }
}
 
                 
                 
                 
                 
@end
