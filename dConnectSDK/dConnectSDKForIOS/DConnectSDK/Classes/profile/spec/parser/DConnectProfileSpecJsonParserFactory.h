//
//  DConnectProfileSpecJsonParserFactory.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/29.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DConnectProfileSpecJsonParser.h"
#import "DConnectProfileSpecJsonParserFactory.h"

@interface DConnectProfileSpecJsonParserFactory : NSObject

- (DConnectProfileSpecJsonParser *) createParser;

+ (DConnectProfileSpecJsonParserFactory *) getDefaultFactory;

@end
