//
//  ArrayDataSpecBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/31.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DConnectDataSpec.h"
#import "ArrayDataSpec.h"

@interface ArrayDataSpecBuilder : NSObject

@property(nonatomic, strong) DConnectDataSpec *itemsSpec;
@property(nonatomic, strong) NSNumber *maxLength;           // Interger値を格納
@property(nonatomic, strong) NSNumber *minLength;           // Interger値を格納

- (ArrayDataSpec *) build;

@end
