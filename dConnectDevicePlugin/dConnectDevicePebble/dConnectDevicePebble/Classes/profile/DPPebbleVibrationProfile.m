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
        __weak DPPebbleVibrationProfile *weakSelf = self;
        
        // API登録(didReceivePutVibrateRequest相当)
        NSString *putVibrateRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectVibrationProfileAttrVibrate];
        [self addPutPath: putVibrateRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *patternStr = [DConnectVibrationProfile patternFromRequest:request];
                         NSArray *pattern = patternStr ? [weakSelf parsePattern:patternStr] : nil;
                         
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
                     }];
        
        // API登録(didReceiveDeleteVibrateRequest相当)
        NSString *deleteVibrateRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectVibrationProfileAttrVibrate];
        [self addDeletePath: deleteVibrateRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            
                            // Pebbleに通知
                            [[DPPebbleManager sharedManager] stopVibration:serviceId
                                                                  callback:^(NSError *error)
                             {
                                 // エラーチェック
                                 [DPPebbleProfileUtil handleErrorNormal:error response:response];
                             }];
                            return NO;
                        }];
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

@end
