//
//  DConnectServiceListViewController.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSystemProfile.h>
#import <DConnectSDK/DConnectServiceListener.h>

/*!
 @class DConnectServiceListViewController
 @brief DeviceConnectサービス一覧を表示するUI。
 */
@interface DConnectServiceListViewController : UITableViewController<DConnectServiceListener>

/*!
 @brief Systemプロファイルのデリゲート。
 */
@property (nonatomic, weak) id<DConnectSystemProfileDelegate> delegate;

/*!
 @brief サービス追加ボタン。
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

/*!
 @brief サービス追加または削除の完了ボタン。
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishButton;

/*!
 @brief サービス削除ボタン。
 */
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeButton;

@end
