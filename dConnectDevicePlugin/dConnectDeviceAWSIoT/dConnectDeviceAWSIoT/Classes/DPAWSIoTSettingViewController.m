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

@interface DPAWSIoTSettingViewController () {
	
}
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *statusSwitch;
@end


@implementation DPAWSIoTSettingViewController

// View表示時
- (void)viewWillAppear:(BOOL)animated {
	// 自分のデバイス情報を取得
	_nameLabel.text = [DPAWSIoTUtils managerName];
	[DPAWSIoTUtils fetchManagerInfoWithHandler:^(NSDictionary *managers, NSDictionary *myInfo, NSError *error) {
		if (myInfo) {
			NSLog(@"myInfo:%@", myInfo);
			_statusSwitch.on = [myInfo[@"online"] boolValue];
		}
	}];
}

// Statusスイッチイベント
- (IBAction)stateSwitchChanged:(id)sender {
	[DPAWSIoTUtils setManagerInfo:_statusSwitch.on handler:^(NSError *error) {
		if (error) {
			// TODO: エラー処理
			NSLog(@"%@", error);
		}
	}];
}

@end
