//
//  LocalOAuthClientData.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface LocalOAuthClientData : NSObject

/** クライアントID. */
@property NSString *clientId;

+ (id)init;

/*!
    コンストラクタ.

    @param[in] clientId クライアントID
    @return ClientDataオブジェクト
 */
+ (LocalOAuthClientData *) clientDataWithClientId: (NSString *)clientId;



@end
