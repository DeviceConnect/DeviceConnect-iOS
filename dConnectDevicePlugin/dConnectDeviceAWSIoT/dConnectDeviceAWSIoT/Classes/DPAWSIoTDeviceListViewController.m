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

// TODO: 名前を決める
#define kShadowName @"dconnect"

@interface DPAWSIoTDeviceListViewController () <UITableViewDataSource> {
	NSDictionary *_devices;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end


@implementation DPAWSIoTDeviceListViewController

//- (void)viewWillAppear:(BOOL)animated {
//	[DPAWSIoTUtils clearAccount];
//}

// View表示後
- (void)viewDidAppear:(BOOL)animated {
	// アカウントの設定がない場合はログイン画面へ
	if (![DPAWSIoTUtils hasAccount]) {
		[self performSegueWithIdentifier:@"LoginSegue" sender:self];
	} else {
		// ログイン
		[DPAWSIoTUtils loginWithHandler:^(NSError *error) {
			if (error) {
				return;
			}
			// Shadow取得
			[[DPAWSIoTManager sharedManager] fetchShadowWithName:kShadowName completionHandler:^(id json, NSError *error) {
				// TODO: 処理
				if (error) {
					// TODO: エラー処理
					return;
				}
				_devices = json[@"state"][@"reported"];
				[self.tableView reloadData];
				NSLog(@"%@", _devices);
			}];
		}];
	}
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
	id key = [_devices.allKeys objectAtIndex:indexPath.row];
	NSString *name = _devices[key][@"name"];
	label.text = name;
	return cell;
}

@end
