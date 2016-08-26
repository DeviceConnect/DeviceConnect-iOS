//
//  ApiIdentifier.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/07.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DConnectApiSpec.h"

@interface ApiIdentifier : NSObject

- (instancetype)initWithPath: (NSString *)path method: (DConnectApiSpecMethod) method;

- (instancetype)initWithPathAndMethodString: (NSString *)path method: (NSString *) method;

- (NSString *) apiIdentifierString;

@end