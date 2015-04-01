//
//  DPPebbleVibrationProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleVibrationProfile.h"
#import "DPPebbleManager.h"
#import "DPPebbleProfileUtil.h"


@interface DPPebbleVibrationProfile ()
@end


@implementation DPPebbleVibrationProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
		self.delegate = self;
	}
	return self;
	
}

- (BOOL)existNumberInArray:(NSArray*)pattern
{
    if (pattern) {
        for (NSNumber *pat in pattern) {
            if (![[DPPebbleManager sharedManager] existDigitWithString:pat.stringValue]
                || pat.intValue < 0) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - DConnectVibrationProfileDelegate

// バイブ鳴動開始リクエストを受け取った
- (BOOL)            profile:(DConnectVibrationProfile *)profile
didReceivePutVibrateRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                   serviceId:(NSString *)serviceId
                    pattern:(NSArray *) pattern
{
    NSString *patternString = [request stringForKey:DConnectVibrationProfileParamPattern];
    if ((patternString
               && ![[DPPebbleManager sharedManager] existCSVWithString:patternString]
               && ![[DPPebbleManager sharedManager] existDigitWithString:patternString])
        || (patternString
            && [[DPPebbleManager sharedManager] existCSVWithString:patternString]
            && ![self existNumberInArray:pattern])
        || (patternString
               && [[DPPebbleManager sharedManager] existCSVWithString:patternString]
               && ![[DPPebbleManager sharedManager] existDigitWithString:patternString]
               && ![self existNumberInArray:pattern])
        ) {
        [response setErrorToInvalidRequestParameter];
        return YES;        
    }
	// Pebbleに通知
	[[DPPebbleManager sharedManager] startVibration:serviceId
											pattern:pattern
										   callback:^(NSError *error)
	{
		// エラーチェック
		[DPPebbleProfileUtil handleErrorNormal:error response:response];
	}];
	return NO;
}

// バイブ鳴動停止リクエストを受け取った
- (BOOL)               profile:(DConnectVibrationProfile *)profile
didReceiveDeleteVibrateRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
	// Pebbleに通知
	[[DPPebbleManager sharedManager] stopVibration:serviceId
										  callback:^(NSError *error)
	 {
		 // エラーチェック
		 [DPPebbleProfileUtil handleErrorNormal:error response:response];
	 }];
	return NO;
}

@end
