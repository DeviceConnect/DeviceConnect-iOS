//
//  DConnectMessage_Private.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DConnectArray ()

- (NSMutableArray *) internalArray;

@end

@interface DConnectMessage ()

- (NSMutableDictionary *) internalDictionary;

@end
