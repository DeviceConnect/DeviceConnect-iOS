//
//  DPPebbleCanvasProfile.m
//  dConnectDevicePebble
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
- (BOOL) profile:(DConnectCanvasProfile *)profile didReceivePostDrawImageRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
       serviceId:(NSString *)serviceId
        mimeType:(NSString *)mimeType
            data:(NSData *)data
             uri:(NSString *)uri
          imageX:(double)imageX
          imageY:(double)imageY
            mode:(NSString *)mode
{
    NSData *canvas = data;
    if (uri || [uri length] > 0) {
        canvas = [NSData dataWithContentsOfURL:[NSURL URLWithString:uri]];
    }
    if (!canvas) {
        canvas = data;
    }
    if (canvas == nil || [canvas length] <= 0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"data is not specied to update a file."];
        return YES;
    }

	// 画像変換
    NSData *imgdata = [DPPebbleImage convertImage:canvas imageX:imageX imageY:imageY mode:mode];
	if (!imgdata) {
		[response setErrorToUnknown];
		return YES;
	}
	
	[[DPPebbleManager sharedManager] sendImage:serviceId data:imgdata callback:^(NSError *error) {
		// エラーチェック
		[DPPebbleProfileUtil handleErrorNormal:error response:response];
	}];
	return NO;
}

- (BOOL)                 profile:(DConnectCanvasProfile *)profile
didReceiveDeleteDrawImageRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
{
    [[DPPebbleManager sharedManager] deleteImage:serviceId callback:^(NSError *error) {
        // エラーチェック
        [DPPebbleProfileUtil handleErrorNormal:error response:response];
    }];
    return NO;
}

@end
