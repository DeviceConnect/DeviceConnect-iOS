//
//  NumberRequestParamSpecJsonParser.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "NumberRequestParamSpec.H"

@interface NumberRequestParamSpecJsonParser : NSObject

+ (NumberRequestParamSpec *)fromJson: (NSDictionary *) json;

@end
