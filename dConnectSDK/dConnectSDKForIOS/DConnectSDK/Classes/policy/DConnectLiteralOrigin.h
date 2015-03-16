//
//  DConnectLiteralOrigin.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectOrigin.h"

@interface DConnectLiteralOrigin : NSObject <DConnectOrigin>
- (id) initWithString:(NSString *) originExp;
@end