//
//  StringRequestParamSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "StringRequestParamSpecBuilder.h"
#import "StringRequestParamSpec.h"

@interface StringRequestParamSpecBuilder : NSObject

- (id)init;

- (id)name: (NSString *) name;
 
- (id)isMandatory: (BOOL) isMandatory;

- (id)format:(StringRequestParamSpecFormat)format;

- (id)maxLength:(NSNumber *)maxLength;

- (id)minLength:(NSNumber *)minLength;

- (id)enumList:(NSArray *)enumList;

- (StringRequestParamSpec *)build;

@end
