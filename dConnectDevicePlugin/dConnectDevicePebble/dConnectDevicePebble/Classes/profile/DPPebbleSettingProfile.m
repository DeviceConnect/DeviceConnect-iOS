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
                                     NSString *rfc3339String = date;
                                     if ([rfc3339String characterAtIndex:date.length - 5] == '+'
                                         || [rfc3339String characterAtIndex:date.length - 5] == '-') {
                                         //ISO8601形式で日付データがくるので、「:」を入れRFC3339形式にする
                                         rfc3339String = [NSString stringWithFormat:@"%@:%@",
                                                          [rfc3339String substringWithRange:NSMakeRange(0, rfc3339String.length - 2)],
                                                          [rfc3339String substringWithRange:NSMakeRange(rfc3339String.length - 2, 2)]];
                                     }
                                     [DConnectSettingProfile setDate:rfc3339String target:response];
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
