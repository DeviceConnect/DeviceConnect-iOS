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
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestTopicLabel;
@property (weak, nonatomic) IBOutlet UILabel *responseTopicLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTopicLabel;
@property (weak, nonatomic) IBOutlet UITextField *syncText;
@end


@implementation DPAWSIoTSettingViewController

// View表示時
- (void)viewWillAppear:(BOOL)animated {
	// 自分のデバイス情報を取得
	_nameLabel.text = [DPAWSIoTController managerName];
	_regionLabel.text = [[DPAWSIoTManager sharedManager] regionName];
	_requestTopicLabel.text = [DPAWSIoTController myTopic:@"request"];
	_responseTopicLabel.text = [DPAWSIoTController myTopic:@"response"];
	_eventTopicLabel.text = [DPAWSIoTController myTopic:@"event"];
	_syncText.text = [@([DPAWSIoTUtils eventSyncInterval]) stringValue];
	[DPAWSIoTController fetchManagerInfoWithHandler:^(NSDictionary *managers, NSDictionary *myInfo, NSError *error) {
		if (myInfo) {
			_statusSwitch.on = [myInfo[@"online"] boolValue];
			_syncText.enabled = !_statusSwitch.on;
		}
	}];
}

// Statusスイッチイベント
- (IBAction)stateSwitchChanged:(id)sender {
	_syncText.enabled = !_statusSwitch.on;
	if (_statusSwitch.on) {
		[DPAWSIoTUtils setEventSyncInterval:[_syncText.text integerValue]];
	}
    [DPAWSIoTUtils setOnline:_statusSwitch.on];
	[DPAWSIoTController setManagerInfo:_statusSwitch.on handler:^(NSError *error) {
		if (error) {
			// アラート
			NSString *msg = @"状態の同期に失敗しました";
			[DPAWSIoTUtils showAlert:self title:@"Error" message:msg handler:^{
			}];
			return;
		}
		// リクエストの購読/解除はThings経由
	}];
}

@end
