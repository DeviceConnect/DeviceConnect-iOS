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

- (BOOL) testCharactorCode:(NSString *)text {
    if (!text || text.length == 0) {
        return NO;
    }
    return [text canBeConvertedToEncoding:NSASCIIStringEncoding];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ログインボタンイベント
- (IBAction)loginButtonPressed:(id)sender {
	NSString *accessKey = _textAccessKey.text;
	NSString *secretKey = _textSecretKey.text;
    if ([self testCharactorCode:accessKey] && [self testCharactorCode:secretKey]) {
		// 保存
		NSInteger region = [_regionPicker selectedRowInComponent:0] +1;
		[DPAWSIoTUtils setAccount:accessKey secretKey:secretKey region:region];
		// ログイン
		[DPAWSIoTUtils loginWithHandler:^(NSError *error) {
			if (error) {
				// 失敗したアカウントはクリアする
				[DPAWSIoTUtils clearAccount];
				// アラート
				NSString *msg = @"ログインに失敗しました";
				[DPAWSIoTUtils showAlert:self title:@"Error" message:msg handler:^{
				}];
			} else {
				[self dismissViewControllerAnimated:YES completion:nil];
			}
		}];
	} else {
		// アラート
        NSString *msg = @"入力値が不正です。";
		[DPAWSIoTUtils showAlert:self title:@"Error" message:msg handler:^{
		}];
	}
}

- (void)viewDidLoad
{
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //Title文字色指定
    self.navigationController.navigationBar.titleTextAttributes
    = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
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
