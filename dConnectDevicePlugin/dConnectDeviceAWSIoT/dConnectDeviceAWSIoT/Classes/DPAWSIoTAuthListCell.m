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

@interface DPAWSIoTAuthListCell () {
}
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
	DConnectResponseMessage *response = [[DPAWSIoTController sharedManager] fetchServiceInformationWithId:serviceId];
	if (response.result == DConnectMessageResultTypeOk) {
		DConnectArray *supports = response.internalDictionary[@"supports"];
		//NSLog(@"supports:%@", supports.internalArray);
		[DConnectUtil asyncAuthorizeWithOrigin:[self packageName]
									   appName:@"AWSIoT"
										scopes:supports.internalArray
									   success:^(NSString *clientId, NSString *accessToken)
		{
			//NSLog(@"clientId:%@", clientId);
			//NSLog(@"accessToken:%@", accessToken);
			[DPAWSIoTUtils addAccessToken:accessToken serviceId:serviceId];
		} error:^(DConnectMessageErrorCodeType errorCode) {
			// TDDO: エラー処理
			NSLog(@"Error on Authorize:%zd", errorCode);
		}];
	}
}

// Packege名取得
- (NSString *)packageName {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *package = [bundle bundleIdentifier];
	return package;
}

@end
