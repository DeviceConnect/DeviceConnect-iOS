//
//  DConnectDataSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectSpecConstants.h"

@interface DConnectDataSpec : NSObject

@property(nonatomic) DConnectSpecDataType dataType;

- (instancetype) initWithDataType: (DConnectSpecDataType) dataType;

#pragma mark - Abstruct Methods.

- (BOOL) validate: (id) param;

@end
