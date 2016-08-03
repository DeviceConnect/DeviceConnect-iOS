//
//  DPPebbleSettingsProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleSettingsProfile.h"
#import "DPPebbleManager.h"
#import "DPPebbleProfileUtil.h"

@interface DPPebbleSettingsProfile ()
@end


@implementation DPPebbleSettingsProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
		self.delegate = self;
        
        // API登録(didReceiveGetDateRequest相当)
        NSString *getDateRequestApiPath = [self apiPathWithProfile: self.profileName
                                                     interfaceName: nil
                                                     attributeName: DConnectSettingsProfileAttrDate];
        [self addGetPath: getDateRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         [[DPPebbleManager sharedManager] fetchDate:serviceId callback:^(NSString *date, NSError *error) {
                             
                             // エラーチェック
                             if ([DPPebbleProfileUtil handleError:error response:response]) {
                                 if (date) {
                                     [DConnectSettingsProfile setDate:date target:response];
                                     [response setResult:DConnectMessageResultTypeOk];
                                 } else {
                                     [response setErrorToUnknown];
                                 }
                             }
                             
                             // レスポンスを返却
                             [[DConnectManager sharedManager] sendResponse:response];
                         }];
                         return NO;
                     }];
	}
	return self;
	
}

@end
