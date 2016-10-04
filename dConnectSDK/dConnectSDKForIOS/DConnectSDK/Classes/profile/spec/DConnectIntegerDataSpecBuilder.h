//
//  DConnectIntegerDataSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectIntegerDataSpec.h"

@interface DConnectIntegerDataSpecBuilder : NSObject

@property (nonatomic) DConnectSpecDataFormat format;

@property (nonatomic, strong) NSNumber * maximum;

@property (nonatomic, strong) NSNumber * minimum;

@property (nonatomic) BOOL exclusiveMaximum;

@property (nonatomic) BOOL exclusiveMinimum;

@property (nonatomic, strong) NSArray * enumList;


- (DConnectIntegerDataSpec *)build;

@end
