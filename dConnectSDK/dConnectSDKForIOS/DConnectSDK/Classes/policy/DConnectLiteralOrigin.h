//
//  DConnectLiteralOrigin.h
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/10.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
//

#import "DConnectOrigin.h"

@interface DConnectLiteralOrigin : NSObject <DConnectOrigin>
- (id) initWithString:(NSString *) originExp;
@end