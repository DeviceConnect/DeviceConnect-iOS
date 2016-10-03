//
//  DConnectArrayDataSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectDataSpec.h"
#import "DConnectArrayDataSpec.h"

@interface DConnectArrayDataSpecBuilder : NSObject

@property(nonatomic, strong) DConnectDataSpec *itemsSpec;
@property(nonatomic, strong) NSNumber *maxLength;           // Interger値を格納
@property(nonatomic, strong) NSNumber *minLength;           // Interger値を格納

- (DConnectArrayDataSpec *) build;

@end
