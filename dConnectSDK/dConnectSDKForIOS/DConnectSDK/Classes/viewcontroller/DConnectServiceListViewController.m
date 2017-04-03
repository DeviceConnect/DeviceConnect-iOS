//
//  DConnectServiceListViewController.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceListViewController.h>
#import <DConnectSDK/DConnectService.h>
#import "DConnectServiceListener.h"
#import "DConnectServiceListViewCell.h"

@interface DConnectServiceListViewController()

@property(nonatomic, strong) NSString *localizeStatusOnline;

@property(nonatomic, strong) NSString *localizeStatusOffline;

@property(nonatomic, strong) NSString *addButtonTitle;

@property(nonatomic, strong) NSString *finishButtonTitle;

@end

@implementation DConnectServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // ローカライズ文字列取得
    NSBundle *bundle = DCBundle();
    self.localizeStatusOnline = DCLocalizedString(bundle, @"status_online");
    self.localizeStatusOffline = DCLocalizedString(bundle, @"status_offline");
    
    // ボタンタイトル名を保存
    self.addButtonTitle = self.addButton.title;
    self.finishButtonTitle = self.finishButton.title;
    
    // ボタン状態更新
    [self setButtonLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    // 他のデバイスプラグインで全てのナビゲーションバーの色が変えられた時のために色を設定する
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    // 再表示(バックグラウンド中に通知されたDConnectServiceListener(サービス追加／削除／状態変化)がTableViewに適用されていないので再表示する)
    [self.tableView reloadData];
    
    // ボタン状態更新
    [self setButtonLayout];
    
    if (self.delegate) {
        [self.delegate.serviceProvider addServiceListener:self];
        
        if ([self.delegate respondsToSelector:@selector(serviceListViewControllerDidWillAppear)]) {
            [self.delegate serviceListViewControllerDidWillAppear];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.delegate) {
        [self.delegate.serviceProvider removeServiceListener: self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // ServiceProviderに格納されているサービス数分、行を表示する
    NSInteger rows = 0;
    if (self.delegate) {
        DConnectServiceProvider *serviceProvider = [self.delegate serviceProvider];
        if (serviceProvider) {
            rows = [[self serviceFilter: serviceProvider.services] count];
        }
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DConnectServiceListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell) {
        
        NSString *serviceName = @"";
        NSString *onlineStatus = @"";
        UIColor *backgroundColor = [UIColor whiteColor];
        
        if (self.delegate) {
            DConnectServiceProvider *serviceProvider = [self.delegate serviceProvider];
            if (serviceProvider) {
                DConnectService *service = [self serviceFilter: serviceProvider.services][indexPath.row];
                if (service) {
                    serviceName = [service name];
                    if ([service online]) {
                        onlineStatus = self.localizeStatusOnline;
                        backgroundColor = [UIColor whiteColor];
                    } else {
                        onlineStatus = self.localizeStatusOffline;
                        backgroundColor = [UIColor lightGrayColor];
                    }
                }
            }
        }
        
        cell.serviceNameLabel.text = serviceName;
        cell.onlineStatusLabel.text = onlineStatus;
        cell.backgroundColor  = backgroundColor;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate) {
        DConnectServiceProvider *serviceProvider = [self.delegate serviceProvider];
        if (serviceProvider) {
            DConnectService *service = [self serviceFilter: serviceProvider.services][indexPath.row];
            if (service) {
                if ([self.delegate respondsToSelector:@selector(didSelectService:)]) {
                    [self.delegate didSelectService: service];
                }
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 削除可能か判定(オフラインなら削除可能)
    if (indexPath.row < [self serviceFilter: self.delegate.serviceProvider.services].count) {
        DConnectService *service = [[self serviceFilter: self.delegate.serviceProvider.services] objectAtIndex: indexPath.row];
        if (!service.online) {
            return YES;
        }
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // データ削除
        NSArray *services = [self serviceFilter: self.delegate.serviceProvider.services];
        if (indexPath.row < services.count) {
            DConnectService *service = [services objectAtIndex: indexPath.row];
            if (!service.online) {
                
                // サービスを削除し、対応するtableViewの行も削除する
                [tableView beginUpdates];
                [self.delegate.serviceProvider removeService: service];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                
                // 削除後にオフラインのサービスが1件以上あればRemoveボタンを有効にする
                [self setButtonLayout];
            }
        }
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapAddButton:(id)sender {
    if (![self isEditing]) {
        // サービス追加画面を表示する
        UIViewController *setting = self.delegate.settingViewController;
        if (setting) {
            [self presentViewController:setting animated:YES completion:nil];
        }
    }
}

- (IBAction)tapFinishButton:(id)sender {
    if ([self isEditing]) {
        
        // 削除モードを終了する
        [self setEditing:NO animated:YES];
        
        // ボタンを[Add][Remove]に変更する
        [self setButtonLayout];
        
    }
}

- (IBAction)tapRemoveButton:(id)sender {
    
    if ([self isEditing]) {

        // チェックしたサービスを削除する
        
        // 削除モードを終了する
        [self setEditing:NO animated:YES];

        // ボタンを[Add][Remove]に変更する
        [self setButtonLayout];
        
    } else {
    
        // 削除モードへ遷移
        [self setEditing:YES animated:YES];
        
        // ボタンを[完了][削除]に変更する
        [self setButtonLayout];
        
        // 削除チェックが1件以上なら[削除]ボタンを使用可能にし、0件なら使用不可にする
        
    }
    
}

- (IBAction)tapCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DConnectServiceListener

- (void)didServiceAdded:(DConnectService *)service {
    
    // 編集モードなら標準モードに戻す
    if ([self isEditing]) {
        [self setEditing:NO animated:YES];
    }
    
    // サービスが追加されたらtableViewを更新する
    [self.tableView reloadData];
    
    // ボタン状態更新
    [self setButtonLayout];
}

- (void)didServiceRemoved:(DConnectService *)service {

    // 編集モードなら標準モードに戻す
    if ([self isEditing]) {
        [self setEditing:NO animated:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(didRemovedService:)]) {
        [self.delegate didRemovedService:service];
    }
    
    // サービスが追加されたらtableViewを更新する
    [self.tableView reloadData];
    
    // ボタン状態更新
    [self setButtonLayout];
}

- (void)didStatusChange:(DConnectService *)service {

    // 編集モードなら標準モードに戻す
    if ([self isEditing]) {
        [self setEditing:NO animated:YES];
    }
    
    // サービスのインデックスを取得し、サービスのセルを更新する
    if (self.delegate) {
        DConnectServiceProvider *serviceProvider = [self.delegate serviceProvider];
        if (serviceProvider) {
            NSIndexPath *indexPath = [self tableIndexPathByServiceId: service.serviceId];
            if (indexPath) {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
    
    // ボタン状態更新
    [self setButtonLayout];
}

/*!
 @brief 表示するserviceをフィルタリングする
 @param[in] serviceProviderから取得したservices
 @retval 表示するserviceだけを抽出したservices
 */
- (NSArray *) serviceFilter: (NSArray *) services {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(displayServiceFilter:)]) {
            return [self.delegate displayServiceFilter: services];
        }
    }
    return services;
}

#pragma mark - private methods.

- (NSIndexPath *) tableIndexPathByServiceId: (NSString *) serviceId {
    int index = 0;

    for (DConnectService *service in [self serviceFilter: self.delegate.serviceProvider.services]) {
        if (service.serviceId && [serviceId localizedCaseInsensitiveCompare: service.serviceId] == NSOrderedSame) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            return indexPath;
        }
        index ++;
    }
    return nil;
}

- (void) setButtonLayout {
    if (self.isEditing) {
        // Finishボタンを表示し、Addボタンを非表示にする
        self.finishButton.enabled = YES;
        self.finishButton.title = self.finishButtonTitle;
        self.addButton.enabled = NO;
        self.addButton.title = @"";
        
        // Removeボタンを無効にする
        self.removeButton.enabled = NO;
        
    } else {
        // Finishボタンを非表示にし、Addボタンを表示する
        self.finishButton.enabled = NO;
        self.finishButton.title = @"";
        self.addButton.enabled = YES;
        self.addButton.title = self.addButtonTitle;
        
        // オフラインのサービスが1件以上存在する場合はRemoveボタンを有効にする
        if ([self isExistOfflineService]) {
            self.removeButton.enabled = YES;
        } else {
            self.removeButton.enabled = NO;
        }
    }
}

- (BOOL) isExistOfflineService {
    for (DConnectService *service in [self serviceFilter: self.delegate.serviceProvider.services]) {
        if (!service.online) {
            return YES;
        }
    }
    return NO;
}

@end
