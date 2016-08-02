//
//  BooleanRequestParamSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "BooleanDataSpec.h"

@interface BooleanDataSpecBuilder : NSObject

- (id)init;

- (id)name: (NSString *) name;

- (id)isMandatory: (BOOL) isMandatory;

- (BooleanDataSpec *)build;

@end
