//
//  DConnectManagerServiceDiscoveryProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>
#import <DConnectSDK/DConnectProfile.h>
#import <DConnectSDK/GetApi.h>
#import <DConnectSDK/PutApi.h>
#import <DConnectSDK/DeleteApi.h>

/**
 * DConnectManager用のService Discoveryプロファイル.
 */
@interface DConnectManagerServiceDiscoveryProfile : DConnectServiceDiscoveryProfile
//<DConnectServiceDiscoveryProfileDelegate>

/*
- (BOOL) profile:(DConnectServiceDiscoveryProfile *)profile didReceiveGetServicesRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response;
*/

@end



/*!
 @class DConnectManagerServiceDiscoveryGetServicesRequestApi
 */
@interface DConnectManagerServiceDiscoveryGetServicesRequestApi : GetApi<DConnectApiDelegate>

@property (nonatomic, weak) DConnectManagerServiceDiscoveryProfile *managerServiceDiscoveryProfile;

/*!
 @brief DConnectManagerServiceDiscoveryProfileのdelegateを指定して本クラスのインスタンスを初期化する。
 
 @param[in] delegate DConnectManagerServiceDiscoveryProfileのdelegate
 
 @retval 本クラスのインスタンス
 */
- (id) initWithProfile: (DConnectManagerServiceDiscoveryProfile *)profile;

@end


/*!
 @class DConnectManagerServiceDiscoveryPutOnServiceChangeRequestApi
 */
@interface DConnectManagerServiceDiscoveryPutOnServiceChangeRequestApi : PutApi<DConnectApiDelegate>

@property (nonatomic, weak) DConnectManagerServiceDiscoveryProfile *managerServiceDiscoveryProfile;

/*!
 @brief DConnectManagerServiceDiscoveryProfileのdelegateを指定して本クラスのインスタンスを初期化する。
 
 @param[in] delegate DConnectManagerServiceDiscoveryProfileのdelegate
 
 @retval 本クラスのインスタンス
 */
- (id) initWithProfile: (DConnectManagerServiceDiscoveryProfile *)profile;

@end




/*!
 @class DConnectServiceDiscoveryDeleteOnServiceChangeRequestApi
 */
@interface DConnectManagerServiceDiscoveryDeleteOnServiceChangeRequestApi : DeleteApi<DConnectApiDelegate>

@property (nonatomic, weak) DConnectManagerServiceDiscoveryProfile *managerServiceDiscoveryProfile;

/*!
 @brief DConnectServiceDiscoveryProfileのdelegateを指定して本クラスのインスタンスを初期化する。
 
 @param[in] delegate DConnectServiceDiscoveryProfileのdelegate
 
 @retval 本クラスのインスタンス
 */
- (id) initWithProfile: (DConnectManagerServiceDiscoveryProfile *)profile;

@end
