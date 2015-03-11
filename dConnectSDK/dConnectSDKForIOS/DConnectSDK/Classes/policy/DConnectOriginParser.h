//
//  DConnectOriginParser.h
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/10.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectOrigin.h"

@interface DConnectOriginParser : NSObject

+ (id<DConnectOrigin>) parse:(NSString *)originExp;

@end
