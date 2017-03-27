//
//  DPPebbleSettingProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleSettingProfile.h"
#import "DPPebbleManager.h"
#import "DPPebbleProfileUtil.h"

@interface DPPebbleSettingProfile ()
@end


@implementation DPPebbleSettingProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
        
        // API登録(didReceiveGetDateRequest相当)
        NSString *getDateRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectSettingProfileAttrDate];
        [self addGetPath: getDateRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         [[DPPebbleManager sharedManager] fetchDate:serviceId callback:^(NSString *date, NSError *error) {
                             
                             // エラーチェック
                             if ([DPPebbleProfileUtil handleError:error response:response]) {
                                 if (date) {
                                     [DConnectSettingProfile setDate:date target:response];
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
