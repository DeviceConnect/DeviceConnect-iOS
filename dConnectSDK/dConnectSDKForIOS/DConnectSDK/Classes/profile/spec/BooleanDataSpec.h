//
//  BooleanRequestParamSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectDataSpec.h"

@interface BooleanDataSpec : DConnectDataSpec

- (BOOL) validate: (id) obj;

- (NSString *) name;

- (BOOL) isMandatory;

- (void) setName: (NSString *) name;

- (void) setIsMandatory: (BOOL) isMandatory ;

- (NSDictionary *) toDictionary;

@end
