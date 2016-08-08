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
        
        __weak DPPebbleCanvasProfile *weakSelf = self;
        
        // API登録(didReceivePostDrawImageRequest相当)
        NSString *postDrawImageRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectCanvasProfileAttrDrawImage];
        [self addPostPath: postDrawImageRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          BOOL send = YES;
                          
                          NSData *data = [DConnectCanvasProfile dataFromRequest:request];
                          NSString *uri = [DConnectCanvasProfile uriFromRequest:request];
                          NSString *serviceId = [request serviceId];
                          NSString *mimeType = [DConnectCanvasProfile mimeTypeFromRequest:request];
                          NSString *strX = [DConnectCanvasProfile xFromRequest: request];
                          NSString *strY = [DConnectCanvasProfile yFromRequest: request];
                          
                          if (mimeType != nil && ![weakSelf isMimeTypeWithString: mimeType]) {
                              [response setErrorToInvalidRequestParameterWithMessage: @"mimeType format is incorrect."];
                              return send;
                          }
                          if (strX != nil && ![weakSelf isFloatWithString: strX]) {
                              [response setErrorToInvalidRequestParameterWithMessage: @"x is different type."];
                              return send;
                          }
                          if (strY != nil && ![weakSelf isFloatWithString: strY]) {
                              [response setErrorToInvalidRequestParameterWithMessage: @"y is different type."];
                              return send;
                          }
                          double imageX = strX.doubleValue;
                          double imageY = strY.doubleValue;
                          NSString *mode = [DConnectCanvasProfile modeFromRequest: request];
                          
                          
                          if (serviceId == nil || [serviceId length] <= 0) {
                              [response setErrorToEmptyServiceId];
                              return YES;
                          }
                          
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
                      }];
        
        // API登録(didReceiveDeleteDrawImageRequest相当)
        NSString *deleteDrawImageRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectCanvasProfileAttrDrawImage];
        [self addDeletePath: deleteDrawImageRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            [[DPPebbleManager sharedManager] deleteImage:serviceId callback:^(NSError *error) {
                                // エラーチェック
                                [DPPebbleProfileUtil handleErrorNormal:error response:response];
                            }];
                            return NO;
                        }];
	}
	return self;
}

@end
