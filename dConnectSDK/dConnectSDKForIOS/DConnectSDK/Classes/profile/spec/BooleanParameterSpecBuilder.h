//
//  BooleanParameterSpecBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "BooleanParameterSpec.h"

@interface BooleanParameterSpecBuilder : DConnectParameterSpecBaseBuilder

- (BooleanParameterSpec *) build;

@end
