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

@interface DPAWSIoTDeviceListViewController () <UITableViewDataSource> {
	NSDictionary *_devices;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation DPAWSIoTDeviceListViewController

// View表示後
- (void)viewDidAppear:(BOOL)animated {
	// アカウントの設定がない場合はログイン画面へ
	if (![DPAWSIoTUtils hasAccount]) {
		[self performSegueWithIdentifier:@"LoginSegue" sender:self];
	} else {
		// ローディング画面表示
		[DPAWSIoTUtils showLoadingHUD:self.storyboard];
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
}


// Shadowを同期
- (void)syncShadow {
	// Shadow取得
	[DPAWSIoTUtils fetchShadowWithHandler:^(id json, NSError *error) {
		// ローディング画面非表示
		[DPAWSIoTUtils hideLoadingHUD];
		// TODO: 処理
		if (error) {
			// TODO: エラー処理
			return;
		}
		// テーブル再読み込み
		_devices = json[@"state"][@"reported"];
		[self.tableView reloadData];
		NSLog(@"%@", _devices);
	}];
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
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	UILabel *label = [cell viewWithTag:1];
	UISwitch *sw = [cell viewWithTag:2];
	id key = [_devices.allKeys objectAtIndex:indexPath.row];
	label.text = _devices[key][@"name"];
	[sw setOn:[_devices[key][@"online"] boolValue]];
	return cell;
}

@end
