//
//  BooleanRequestParamSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectRequestParamSpec.h"

extern NSString *const BooleanRequestParamSpecJsonKeyName;
extern NSString *const BooleanRequestParamSpecJsonKeyIsMandatory;

extern NSString *const BooleanRequestParamSpecJsonValTrue;
extern NSString *const BooleanRequestParamSpecJsonValFalse;

@interface BooleanRequestParamSpec : DConnectRequestParamSpec

- (instancetype)init;

- (BOOL) validate: (id) obj;

- (NSString *) name;

- (BOOL) isMandatory;

- (void) setName: (NSString *) name;

- (void) setIsMandatory: (BOOL) isMandatory ;



@end
