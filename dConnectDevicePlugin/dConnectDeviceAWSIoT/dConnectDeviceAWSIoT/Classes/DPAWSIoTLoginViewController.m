//
//  DPAWSIoTLoginViewController.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTLoginViewController.h"
#import "DPAWSIoTManager.h"
#import "DPAWSIoTUtils.h"

@interface DPAWSIoTLoginViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textAccessKey;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textSecretKey;
@property (weak, nonatomic) IBOutlet UIPickerView *regionPicker;
@end

@implementation DPAWSIoTLoginViewController

- (void)viewWillAppear:(BOOL)animated {
	// debug用
	_textAccessKey.text = @"AKIAJYDTLD4DPFGZ4PAQ";
	_textSecretKey.text = @"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";
}

// ログインボタンイベント
- (IBAction)loginButtonPressed:(id)sender {
	NSString *accessKey = _textAccessKey.text;
	NSString *secretKey = _textSecretKey.text;
	if (accessKey.length && secretKey.length) {
		// 保存
		NSInteger region = [_regionPicker selectedRowInComponent:0] +1;
		[DPAWSIoTUtils setAccount:accessKey secretKey:secretKey region:region];
		// ログイン
		[DPAWSIoTUtils loginWithHandler:^(NSError *error) {
			if (!error) {
				[self dismissViewControllerAnimated:YES completion:nil];
			}
		}];
	} else {
		// TODO: アラート
	}
}

#pragma mark - Picker

// Pickerコンポーネント数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

// Pickerデータ数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 13;
}

// Pickerデータ
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [DPAWSIoTManager regionNameFromType:row +1];
}

@end
