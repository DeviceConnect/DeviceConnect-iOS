//
//  ArrayParameterSpec.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/31.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectParameterSpec.h"
#import "ArrayDataSpec.h"
#import "DConnectDataSpec.h"

@interface ArrayParameterSpec : ArrayDataSpec

- (instancetype) initWithDataSpec: (DConnectDataSpec *) itemSpec;

- (DConnectDataSpec *) itemSpec;

-(NSNumber *) maxLength;

- (void) setMinLength: (NSNumber *) minLength;

- (NSNumber *) minLength;

- (void) setMaxLength: (NSNumber *) maxLength;

@end
