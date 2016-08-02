//
//  DConnectDataSpec.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/30.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DConnectSpecConstants.h"

@interface DConnectDataSpec : NSObject

@property(nonatomic) DConnectSpecDataType dataType;

- (instancetype) initWithDataType: (DConnectSpecDataType) dataType;

#pragma mark - Abstruct Methods.

- (BOOL) validate: (id) param;

@end
