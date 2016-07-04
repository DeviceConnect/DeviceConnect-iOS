//
//  DConnectRequestParamSpecJsonParser.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectRequestParamSpec.h"

@interface DConnectRequestParamSpecJsonParser : NSObject

+ (DConnectRequestParamSpec *)fromJson: (NSDictionary *) json;

@end
