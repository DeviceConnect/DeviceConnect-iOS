//
//  DConnectProfileSpecJsonParserFactory.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectProfileSpecJsonParser.h"
#import "DConnectProfileSpecJsonParserFactory.h"

@interface DConnectProfileSpecJsonParserFactory : NSObject

- (DConnectProfileSpecJsonParser *) createParser;

+ (DConnectProfileSpecJsonParserFactory *) getDefaultFactory;

@end
