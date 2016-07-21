//
//  DConnectApiEntity.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectRequestMessage.h>
#import <DConnectSDK/DConnectResponseMessage.h>
#import <DConnectSDK/DConnectApiSpec.h>

typedef BOOL (^DConnectApiFunction)(DConnectRequestMessage*, DConnectResponseMessage*);

@interface DConnectApiEntity : NSObject<NSCopying>
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) DConnectApiFunction api;
@property (nonatomic, strong) DConnectApiSpec *apiSpec;

@end
