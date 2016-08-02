//
//  StringParameterSpecBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/03.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectSpecConstants.h"

@interface StringParameterSpecBuilder : DConnectParameterSpecBaseBuilder

@property(nonatomic) DConnectSpecDataFormat dataFormat;
@property(nonatomic) int maxLength;
@property(nonatomic) int minLength;
@property(nonatomic, strong) NSArray *enumList;

@end
