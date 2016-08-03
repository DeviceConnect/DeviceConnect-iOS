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
#import "ArrayDataSpecBuilder.h"

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

@interface SwaggerJsonParser() {
    
    OperationObjectParser OPERATION_OBJECT_PARSER;
    
    ItemsObjectParser ARRAY_ITEMS_PARSER;
    ItemsObjectParser BOOLEAN_ITEMS_PARSER;
    ItemsObjectParser INTEGER_ITEMS_PARSER;
    ItemsObjectParser NUMBER_ITEMS_PARSER;
    ItemsObjectParser STRING_ITEMS_PARSER;
    
    ParameterObjectParser ARRAY_PARAM_PARSER;
    ParameterObjectParser BOOLEAN_PARAM_PARSER;
    ParameterObjectParser FILE_PARAM_PARSER;
    ParameterObjectParser INTEGER_PARAM_PARSER;
    ParameterObjectParser NUMBER_PARAM_PARSER;
    ParameterObjectParser STRING_PARAM_PARSER;
    
}

@end


@implementation SwaggerJsonParser

- (instancetype) init {
    
    self = [super init];
    if (self) {
        __weak SwaggerJsonParser *weakSelf = self;
        
        // private static final OperationObjectParser OPERATION_OBJECT_PARSER = new OperationObjectParser() {
        OPERATION_OBJECT_PARSER = ^ DConnectApiSpec * (DConnectSpecMethod method, NSDictionary *jsonOpObj) {
            
            DConnectSpecType type = [DConnectSpecConstants parseType: jsonOpObj[OperationObjectParserKeyXType]];
            NSArray *parameters = jsonOpObj[OperationObjectParserKeyParameters];
            
            NSMutableArray *paramSpecList = [NSMutableArray array]; // DConnectParameterSpecの配列
            
            for (NSDictionary *paramObj in parameters) {
                ParameterObjectParser parser = [weakSelf getParameterParser: paramObj];
                DConnectParameterSpec *paramSpec = parser(paramObj);
                [paramSpecList addObject: paramSpec];
            }
            
            DConnectApiSpecBuilder *builder = [[DConnectApiSpecBuilder alloc] init];
            [builder setType: type];
            [builder setMethod: method];
            [builder setParamList: paramSpecList];
            return [builder build];
        };
        
        // private static final ItemsObjectParser ARRAY_ITEMS_PARSER = new ArrayItemsObjectParser();
        ARRAY_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
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
        BOOLEAN_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            return nil;
        };
                 
        // INTEGER_ITEMS_PARSER = new IntegerItemsObjectParser();
        INTEGER_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            return nil;
        };
        
        // NUMBER_ITEMS_PARSER = new NumberItemsObjectParser();
        NUMBER_ITEMS_PARSER = ^ DConnectDataSpec * (NSDictionary *json) {
            return nil;
        };
        
        // STRING_ITEMS_PARSER = new StringItemsObjectParser();
        
        // ARRAY_PARAM_PARSER = new ArrayParameterParser();
        // BOOLEAN_PARAM_PARSER = new BooleanParameterParser();
        // FILE_PARAM_PARSER = new FileParameterParser();
        // INTEGER_PARAM_PARSER = new IntegerParameterParser();
        // NUMBER_PARAM_PARSER = new NumberParameterParser();
        // STRING_PARAM_PARSER = new StringParameterParser();

        
    }
    return self;
}



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
            DConnectApiSpec *apiSpec = OPERATION_OBJECT_PARSER(method, opObj);
            if (apiSpec) {
                [builder addApiSpec: path method: method apiSpec: apiSpec];
            }
        }
    }
    
    return [builder build];
}

 
- (ParameterObjectParser) getParameterParser: (NSDictionary *) json {
    
    NSString *type = json[ParameterObjectParserKeyType];
    DConnectSpecDataType paramType = [DConnectSpecConstants parseDataType: type];
    if (!paramType) {
         @throw [NSString stringWithFormat: @"Unknown parameter type '%@' is specified.", type];
    }
    switch (paramType) {
        case BOOLEAN:
            return BOOLEAN_PARAM_PARSER;
        case INTEGER:
            return INTEGER_PARAM_PARSER;
        case NUMBER:
            return NUMBER_PARAM_PARSER;
        case STRING:
            return STRING_PARAM_PARSER;
        case FILE_:
            return FILE_PARAM_PARSER;
        case ARRAY:
            return ARRAY_PARAM_PARSER;
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
            return BOOLEAN_PARAM_PARSER;
        case INTEGER:
            return INTEGER_PARAM_PARSER;
        case NUMBER:
            return NUMBER_PARAM_PARSER;
        case STRING:
            return STRING_PARAM_PARSER;
        case FILE_:
            return FILE_PARAM_PARSER;
        case ARRAY:
            return ARRAY_PARAM_PARSER;
        default:
            @throw [NSString stringWithFormat: @"Invalid parameter type '%@' is specified.", type];
    }
}
 
                 
                 
                 
                 
@end
