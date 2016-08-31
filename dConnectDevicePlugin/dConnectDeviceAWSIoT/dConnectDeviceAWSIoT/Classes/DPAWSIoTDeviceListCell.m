//
//  DPAWSIoTDeviceListCell.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTDeviceListCell.h"
#import "DPAWSIoTUtils.h"
#import "DPAWSIoTController.h"

@interface DPAWSIoTDeviceListCell () {
	NSString *_key;
}
@property (weak, nonatomic) IBOutlet UISwitch *stateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation DPAWSIoTDeviceListCell

// 名前とキーを設定
- (void)setName:(NSString*)name key:(NSString*)key {
	_titleLabel.text = name;
	_key = key;
	_stateSwitch.on = [DPAWSIoTUtils hasAllowedManager:key];
}

// 状態スイッチイベント
- (IBAction)switchChanged:(id)sender {
	if (_stateSwitch.on) {
		[DPAWSIoTUtils addAllowManager:_key];
	} else {
		[DPAWSIoTUtils removeAllowManager:_key];
	}
}

@end
