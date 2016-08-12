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

@interface DPAWSIoTDeviceListViewController ()

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
			// TODO: 処理
		}];
	}
}


@end
