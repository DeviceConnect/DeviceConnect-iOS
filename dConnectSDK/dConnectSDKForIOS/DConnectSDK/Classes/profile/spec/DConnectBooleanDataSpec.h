//
//  DConnectBooleanDataSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectDataSpec.h"

@interface DConnectBooleanDataSpec : DConnectDataSpec

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) obj;

@end
