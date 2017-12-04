//
//  dConnectDeviceChromeCastCanvasProfile.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastCanvasProfile.h"
#import "DPChromecastManager.h"

@implementation DPChromecastCanvasProfile

- (id)init
{
    self = [super init];
    if (self) {
        __weak DPChromecastCanvasProfile *weakSelf = self;
        
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
                          NSString *xString = [request stringForKey:DConnectCanvasProfileParamX];
                          NSString *yString = [request stringForKey:DConnectCanvasProfileParamY];
                          
                          if (![[DPChromecastManager sharedManager] existDecimalWithString:xString]) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"x is Invalid."];
                              return YES;
                          }
                          if (![[DPChromecastManager sharedManager] existDecimalWithString:yString]) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"y is Invalid."];
                              return YES;
                          }
                          if (mimeType && ![[DPChromecastManager sharedManager] existMimeTypeWithString:mimeType]) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"MimeType is Invalid."];
                              return YES;
                          }
                          
                          NSString *modeString = mode;
                          if (!mode) {
                              modeString = @"same";
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
                          
                          NSString *url = [weakSelf saveImage:canvas];
                          // リクエスト処理
                          return [weakSelf handleRequest:request
                                                response:response
                                               serviceId:serviceId
                                                callback:^{
                                      // メッセージ送信
                                      DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                                      [mgr sendCanvasWithID:serviceId
                                                   imageURL:url
                                                     imageX:imageX
                                                     imageY:imageY
                                                       mode:modeString];
                                  }];
                      }];
        
        
        // API登録(didReceiveDeleteDrawImageRequest相当)
        NSString *deleteDrawImageRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectCanvasProfileAttrDrawImage];
        [self addDeletePath: deleteDrawImageRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentsDirectory = [paths objectAtIndex:0];
                            [[DPChromecastManager sharedManager] removeFileForfileNamesAtDirectoryPath:documentsDirectory
                                                                                             extension:@"jpg"];
                            
                            // リクエスト処理
                            return [weakSelf handleRequest:request
                                                  response:response
                                                 serviceId:serviceId
                                                  callback: ^{
                                        // メッセージクリア
                                        DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                                        [mgr clearCanvasWithID:serviceId];
                                    }];
                        }];
        
    }
    return self;
}

// 共通リクエスト処理
- (BOOL)handleRequest:(DConnectRequestMessage *)request
             response:(DConnectResponseMessage *)response
            serviceId:(NSString *)serviceId
             callback:(void(^)(void))callback
{
    // パラメータチェック
    if (serviceId == nil) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    // 接続＆メッセージクリア
    DPChromecastManager *mgr = [DPChromecastManager sharedManager];
    [mgr connectToDeviceWithID:serviceId completion:^(BOOL success, NSString *error) {
        if (success) {
            callback();
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            // エラー
            [response setErrorToNotFoundService];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    return NO;
}

- (NSString*)saveImage:(NSData *)data
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [@"dConnectDeviceChromecast_" stringByAppendingFormat:@"%@.jpg", formattedDateString];

    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL success = [fileManager fileExistsAtPath:dataPath];
    if (success) {
        data = [NSData dataWithContentsOfFile:dataPath];
    } else {
        [data writeToFile:dataPath atomically:YES];
    }
    
    
    NSString* url = [@"http://" stringByAppendingFormat:@"%@/%@",
                     [[DPChromecastManager sharedManager] getIPString],
                     fileName];
    return url;
}

@end
