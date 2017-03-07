//
//  DConnectApiSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectMessage.h>
#import <DConnectSDK/DConnectRequestMessage.h>
#import <DConnectSDK/DConnectSpecConstants.h>

@interface DConnectApiSpec : NSObject<NSCopying>

@property(nonatomic) DConnectSpecType type;

@property(nonatomic) DConnectSpecMethod method;

@property(nonatomic, strong) NSString *apiName;

@property(nonatomic, strong) NSString *profileName;

@property(nonatomic, strong) NSString *interfaceName;

@property(nonatomic, strong) NSString *attributeName;

// DConnectParamSpecの配列
@property(nonatomic, strong) NSArray *requestParamSpecList;

- (NSString *) path;

- (void) setPath: (NSString *) path;

- (BOOL) validate: (DConnectRequestMessage *) request;

@end

