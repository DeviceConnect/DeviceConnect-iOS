//
//  DConnectAvailabilityProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*!
 @file
 @brief Availabilityプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectAvailabilityProfileName;

extern NSString *const DConnectAvailabilityProfileParamName;

/*!
 @class DConnectAvailabilityProfile
 @brief Availabilityプロファイル。
 
 Managerと通信可能であることを確認するためのプロファイル。
 プラグイン側では実装する必要はない。
 */
@interface DConnectAvailabilityProfile : DConnectProfile

- (id) init;

@end
