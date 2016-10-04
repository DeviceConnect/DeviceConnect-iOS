//
//  DConnectSwaggerJsonParser.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectProfileSpecJsonParser.h"
#import "DConnectProfileSpec.h"


extern NSString * const OperationObjectParserKeyXType;
extern NSString * const OperationObjectParserKeyParameters;

extern NSString * const ParameterObjectParserKeyName;
extern NSString * const ParameterObjectParserKeyRequied;
extern NSString * const ParameterObjectParserKeyType;




@interface DConnectSwaggerJsonParser : DConnectProfileSpecJsonParser

@end
