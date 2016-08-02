//
//  ArrayParameterSpecBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/03.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectDataSpec.h"

@interface ArrayParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic, strong) DConnectDataSpec *itemSpec;
@property(nonatomic) int maxLength;
@property(nonatomic) int minLength;

@end
