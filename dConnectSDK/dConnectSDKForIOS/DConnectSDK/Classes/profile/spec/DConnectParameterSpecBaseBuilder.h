//
//  DConnectParameterSpecBaseBuilder.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DConnectParameterSpecBaseBuilder : NSObject

@property(nonatomic, weak) NSString *name;

@property(nonatomic) BOOL isRequired;

@end
