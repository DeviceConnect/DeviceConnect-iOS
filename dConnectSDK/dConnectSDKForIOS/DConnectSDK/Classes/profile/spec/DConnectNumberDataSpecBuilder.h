//
//  DConnectNumberDataSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectSpecConstants.h"
#import "DConnectNumberDataSpec.h"

@interface DConnectNumberDataSpecBuilder : NSObject

@property(nonatomic) DConnectSpecDataFormat dataFormat;

@property(nonatomic, strong) NSNumber *maximum;

@property(nonatomic, strong) NSNumber *minimum;

@property(nonatomic) BOOL exclusiveMaximum;

@property(nonatomic) BOOL exclusiveMinimum;

- (DConnectNumberDataSpec *) build;

@end
