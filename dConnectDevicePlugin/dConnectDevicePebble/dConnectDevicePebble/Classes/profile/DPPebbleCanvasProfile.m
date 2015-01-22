//
//  DPPebbleCanvasProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleCanvasProfile.h"
#import "DPPebbleManager.h"
#import "DPPebbleImage.h"
#import "DPPebbleProfileUtil.h"

@interface DPPebbleCanvasProfile ()
@end

@implementation DPPebbleCanvasProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
		self.delegate = self;
	}
	return self;
}


#pragma mark - DConnectCanvasProfileDelegate

// 画像描画リクエストを受け取った
- (BOOL) profile:(DConnectFileProfile *)profile didReceivePostDrawImageRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        deviceId:(NSString *)deviceId
        mimeType:(NSString *)mimeType
            data:(NSData *)data
               x:(double)x
               y:(double)y
            mode:(NSString *)mode
{
	// パラメータチェック
	if (data == nil) {
		[response setErrorToInvalidRequestParameterWithMessage:@"data is not specied to update a file."];
		return YES;
	}
	
	// 画像変換
    NSData *imgdata = [DPPebbleImage convertImage:data x:x y:y mode:mode];
	if (!imgdata) {
		[response setErrorToUnknown];
		return YES;
	}
	
	[[DPPebbleManager sharedManager] sendImage:deviceId data:imgdata callback:^(NSError *error) {
		// エラーチェック
		[DPPebbleProfileUtil handleErrorNormal:error response:response];
	}];
	return NO;
}

@end
