//
//  DPAWSIoTDeviceListViewController.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTDeviceListViewController.h"
#import "DPAWSIoTUtils.h"
#import "DPAWSIoTManager.h"
#import "DPAWSIoTController.h"
#import "DPAWSIoTDeviceListCell.h"

@interface DPAWSIoTDeviceListViewController () <UITableViewDataSource> {
	NSDictionary *_devices;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation DPAWSIoTDeviceListViewController {
    BOOL _loginViewFlag;
}

// View表示時
- (void)viewWillAppear:(BOOL)animated {
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

	// アカウントの設定がない場合はログイン画面へ
	if (![DPAWSIoTUtils hasAccount]) {
        // ログイン画面から戻ってきた時には画面を閉じる
        if (_loginViewFlag) {
            _loginViewFlag = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            _loginViewFlag = YES;
            [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        }
	} else {
		// ローディング画面表示
		[DPAWSIoTUtils showLoadingHUD:self.storyboard];
		if ([DPAWSIoTManager sharedManager].isConnected) {
			// ログイン済みの場合はShadow取得
			[self syncShadow];
		} else {
			// ログイン
			[DPAWSIoTUtils loginWithHandler:^(NSError *error) {
				if (error) {
					// ローディング画面非表示
					[DPAWSIoTUtils hideLoadingHUD];
					return;
				}
				// Shadow取得
				[self syncShadow];
			}];
		}
	}
}

// View非表示時
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[DPAWSIoTController sharedManager] fetchManagerInfo];
}

// Shadowを同期
- (void)syncShadow {
	// Shadow取得
	[DPAWSIoTController fetchManagerInfoWithHandler:^(NSDictionary *managers, NSDictionary *myInfo, NSError *error) {
		// ローディング画面非表示
		[DPAWSIoTUtils hideLoadingHUD];
		if (error) {
			// エラー処理
			NSLog(@"Error on FetchManagerInfo: %@", error);
			NSString *msg = @"エラーが発生しました";
			[DPAWSIoTUtils showAlert:self title:@"Error" message:msg handler:^{
			}];
			return;
		}
		// テーブル再読み込み
		_devices = managers;
		[self.tableView reloadData];
	}];
}


#pragma mark - Events

// syncボタンイベント
- (IBAction)syncButtonPressed:(id)sender {
	// ローディング画面表示
	[DPAWSIoTUtils showLoadingHUD:self.storyboard];
	// Shadow取得
	[self syncShadow];
}

// 閉じるボタンイベント
- (IBAction)closeButtonPressed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

// メニューボタンイベント
- (IBAction)menuButtonPressed:(id)sender {
	NSString *menu1 = @"AWSIoT設定";
	NSString *menu2 = @"LocalOAuth認証";
	NSString *menu3 = @"ログアウト";
	UIAlertController *ac = [DPAWSIoTUtils createMenu:@[menu1, menu2, menu3] handler:^(int index) {
		switch (index) {
			case 0:
				[self performSegueWithIdentifier:@"SettingSegue" sender:self];
				break;
			case 1:
				[self performSegueWithIdentifier:@"AuthSegue" sender:self];
				break;
			case 2:
				[[DPAWSIoTController sharedManager] logout];
                [DPAWSIoTUtils clearAccount];
				[self performSegueWithIdentifier:@"LoginSegue" sender:self];
				break;
		}
	}];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		[ac setModalPresentationStyle:UIModalPresentationPopover];
		UIPopoverPresentationController *popPresenter = [ac popoverPresentationController];
		UIView *view = [sender valueForKey:@"view"];
		popPresenter.sourceView = view;
		popPresenter.sourceRect = [view bounds];
	}
	[self presentViewController:ac animated:YES completion:nil];
}


#pragma mark - UITableView

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _devices.count;
}

// テーブル内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DPAWSIoTDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	id key = [_devices.allKeys objectAtIndex:indexPath.row];
	[cell setName:_devices[key][@"name"] key:key];
	return cell;
}

@end
