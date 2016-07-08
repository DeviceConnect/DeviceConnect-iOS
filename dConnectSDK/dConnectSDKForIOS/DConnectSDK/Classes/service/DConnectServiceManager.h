//
//  DConnectServiceManager.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectApiSpecList.h"
#import "DConnectService.h"
#import "DConnectServiceProvider.h"



@interface DConnectServiceManager : NSObject<DConnectServiceProvider>

@property (nonatomic, weak) DConnectApiSpecList *mApiSpecs;

/*!
 @brief 接続サービス配列(key:サービスID value: DConnectService *)]
 */
@property (nonatomic, weak) NSMutableDictionary *mDConnectServices;


- (void) setApiSpecDictionary: (DConnectApiSpecList *) dictionary;


@end
