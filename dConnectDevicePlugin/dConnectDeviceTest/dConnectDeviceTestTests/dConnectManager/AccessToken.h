//
//  AccessToken.h
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (nonatomic) NSString *token;
@property (nonatomic) NSMutableDictionary *expirePeriods;

- (id) initWithResponse:(NSDictionary*)response;

@end
