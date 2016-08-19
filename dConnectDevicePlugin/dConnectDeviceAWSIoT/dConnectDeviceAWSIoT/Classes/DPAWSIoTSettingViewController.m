//
//  DPAWSIoTSettingViewController.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTSettingViewController.h"
#import "DPAWSIoTUtils.h"
#import "DPAWSIoTManager.h"
#import "DPAWSIoTController.h"

@interface DPAWSIoTSettingViewController () {
	
}
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@end


@implementation DPAWSIoTSettingViewController

// View表示時
- (void)viewWillAppear:(BOOL)animated {
	// 自分のデバイス情報を取得
	_nameLabel.text = [DPAWSIoTController managerName];
	[DPAWSIoTController fetchManagerInfoWithHandler:^(NSDictionary *managers, NSDictionary *myInfo, NSError *error) {
		if (myInfo) {
			NSLog(@"myInfo:%@", myInfo);
			_statusSwitch.on = [myInfo[@"online"] boolValue];
		}
	}];
}

// Statusスイッチイベント
- (IBAction)stateSwitchChanged:(id)sender {
	[DPAWSIoTController setManagerInfo:_statusSwitch.on handler:^(NSError *error) {
		if (error) {
			// TODO: エラー処理
			NSLog(@"%@", error);
			return;
		}
		// リクエストの購読/解除
		if (_statusSwitch.on) {
			[DPAWSIoTController subscribeRequest];
		} else {
			[DPAWSIoTController unsubscribeRequest];
		}
	}];
}

@end
