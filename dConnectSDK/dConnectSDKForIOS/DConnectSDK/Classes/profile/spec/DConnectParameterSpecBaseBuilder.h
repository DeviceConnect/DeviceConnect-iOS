//
//  DConnectParameterSpecBaseBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DConnectParameterSpecBaseBuilder : NSObject

@property(nonatomic, weak) NSString *name;

@property(nonatomic) BOOL isRequired;

@end
