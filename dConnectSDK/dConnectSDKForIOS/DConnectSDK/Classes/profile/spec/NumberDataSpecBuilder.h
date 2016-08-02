//
//  NumberDataSpecBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DConnectSpecConstants.h"

@interface NumberDataSpecBuilder : NSObject

@property(nonatomic) DConnectSpecDataFormat format;

@property(nonatomic, strong) NSNumber *maximum;

@property(nonatomic, strong) NSNumber *minimum;

@property(nonatomic) BOOL exclusiveMaximum;

@property(nonatomic) BOOL exclusiveMinimum;

@end
