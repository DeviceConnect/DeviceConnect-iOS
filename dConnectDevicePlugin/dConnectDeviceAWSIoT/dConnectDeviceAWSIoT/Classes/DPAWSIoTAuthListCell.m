//
//  DPAWSIoTAuthListCell.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTAuthListCell.h"
#import "DPAWSIoTController.h"
#import "DConnectMessage+Private.h"
#import "DPAWSIoTUtils.h"

@interface DPAWSIoTAuthListCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation DPAWSIoTAuthListCell

// Message設定
- (void)setMsg:(DConnectMessage *)msg {
	_msg = msg;
	_titleLabel.text = [msg stringForKey:@"name"];
}

// 認証ボタンイベント
- (IBAction)authButtonPressed:(id)sender {
    NSString *serviceId = [_msg stringForKey:@"id"];
    [DPAWSIoTUtils fetchServiceInformationWithId:serviceId callback:^(DConnectResponseMessage *response) {
        if (response.result == DConnectMessageResultTypeError) {
            // TODO エラー処理
        }
    }];
}

// Packege名取得
- (NSString *)packageName {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *package = [bundle bundleIdentifier];
	return package;
}

@end
