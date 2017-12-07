//
//  DPThetaFileProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaFileProfile.h"
#import "DPThetaManager.h"

@implementation DPThetaFileProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak DPThetaFileProfile *weakSelf = self;
        
        // API登録(didReceiveGetReceiveRequest相当)
        NSString *getReceiveRequestApiPath = [self apiPath: nil
                                             attributeName: nil];
        [self addGetPath: getReceiveRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *path = [DConnectFileProfile pathFromRequest:request];
                         
                         CONNECT_CHECK();
                         if (!path || path.length == 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
                             return YES;
                         }
                         
                         NSString *uri = [[DPThetaManager sharedManager] receiveImageFileWithFileName:path
                                                                                              fileMgr:[WEAKSELF_PLUGIN fileMgr]];
                         if (uri) {
                             [DConnectFileProfile setURI:uri target:response];
                             [DConnectFileProfile setMIMEType:@"image/jpeg" target:response];
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setErrorToInvalidRequestParameterWithMessage:@"Not exist path"];
                         }
                         return YES;
                     }];
        
        // API登録(didReceiveGetListRequest相当)
        NSString *getListRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectFileProfileAttrList];
        [self addGetPath: getListRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *path = [DConnectFileProfile pathFromRequest:request];
                         NSString *orderStr = [DConnectFileProfile orderFromRequest:request];
                         NSNumber *offset = [DConnectFileProfile offsetFromRequest:request];
                         NSNumber *limit = [DConnectFileProfile limitFromRequest:request];
//                         NSString *mimeType = [DConnectFileProfile mimeTypeFromRequest:request];
                         NSArray *order = nil;
                         
                         if (orderStr) {
                             order = [orderStr componentsSeparatedByString:@","];
                         }
                         
                         CONNECT_CHECK();
                         if (path && ![path isEqualToString:@"/"]) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }
                         
                         
                         NSString *sortTarget;
                         NSString *sortOrder;
                         if (![weakSelf checkParameters:request
                                               response:response
                                              sortOrder:&sortOrder
                                             sortTarget:&sortTarget
                                                  order:order]) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }
                         NSComparator comp;
                         [weakSelf compareOrderWithResponse:response sortTarget:sortTarget comp:&comp sortOrder:sortOrder];
                         if ([response integerForKey:DConnectMessageResult] == DConnectMessageResultTypeError) {
                             return YES;
                         }
                         
                         if (offset && offset.integerValue < 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"offset must be a non-negative value."];
                             return YES;
                         }
                         
                         if (limit && limit.integerValue < 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"limit must be a positive value."];
                             return YES;
                         }
                         
                         
                         NSMutableArray *fileArr = [weakSelf convertFileArrayFromPtpInfoArray:[[DPThetaManager sharedManager] getAllFiles]];
                         if (fileArr.count <= 0) {
                             [response setErrorToIllegalDeviceState];
                             return YES;
                         }
                         if (offset && offset.integerValue >= fileArr.count) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"offset exceeds the size of the media list."];
                             return YES;
                         }
                         
                         // 並び替えを実行
                         NSArray *tmpArr = fileArr;
                         if (comp) {
                             tmpArr = [fileArr sortedArrayUsingComparator:comp];
                         }
                         
                         // ページングのために配列の一部分だけ抜き出し
                         if (offset || limit) {
                             NSUInteger offsetVal = offset ? offset.unsignedIntegerValue : 0;
                             NSUInteger limitVal = limit ? limit.unsignedIntegerValue : fileArr.count;
                             tmpArr = [tmpArr subarrayWithRange:
                                       NSMakeRange(offset.unsignedIntegerValue,
                                                   MIN(fileArr.count - offsetVal, limitVal))];
                         }
                         
                         [DConnectFileProfile setCount:(int)tmpArr.count target:response];
                         [DConnectFileProfile setFiles:[DConnectArray initWithArray:tmpArr] target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteRemoveRequest相当)
        NSString *deleteRemoveRequestApiPath = [self apiPath: nil
                                               attributeName: nil];
        [self addDeletePath: deleteRemoveRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *path = [DConnectFileProfile pathFromRequest:request];
                            
                            CONNECT_CHECK();
                            if (!path || path.length == 0) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
                                return YES;
                            }
                            BOOL isSuccess = [[DPThetaManager sharedManager] removeFileWithName:path
                                                                                        fileMgr:[WEAKSELF_PLUGIN fileMgr]];
                            if (isSuccess) {
                                [response setResult:DConnectMessageResultTypeOk];
                            } else {
                                [response setErrorToIllegalDeviceStateWithMessage:@"Not Exist path"];
                            }
                            return YES;
                        }];

    }
    return self;
}

- (NSMutableArray*)convertFileArrayFromPtpInfoArray:(NSArray*)ptpInfoArray
{
    NSMutableArray *fileArr = [NSMutableArray array];
    for (PtpIpObjectInfo *ptp in ptpInfoArray) {
        DConnectMessage *file = [DConnectMessage new];
        [DConnectFileProfile setPath:ptp.filename target:file];
        [DConnectFileProfile setFileName:ptp.filename target:file];
        [DConnectFileProfile setFileType:0 target:file];
        [DConnectFileProfile setMIMEType:@"image/jpeg" target:file];
        [DConnectFileProfile setUpdateDate:[DConnectRFC3339DateUtils stringWithDate:ptp.capture_date]
                                   tareget:file];
        [DConnectFileProfile setFileSize:ptp.object_compressed_size target:file];
        [fileArr addObject:file];
    }
    return fileArr;
}

/*!
 @brief /file/listのパラメータチェック.
 */
- (BOOL)checkParameters:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    sortOrder:(NSString **)sortOrder
                   sortTarget:(NSString **)sortTarget
                        order:(NSArray *)order
{
    NSString *offsetString = [request stringForKey:DConnectFileProfileParamOffset];
    NSString *limitString = [request stringForKey:DConnectFileProfileParamLimit];
    if (offsetString && ![DPThetaManager existDigitWithString:offsetString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"offset is non-float"];
        return NO;
    }
    if (limitString && ![DPThetaManager existDigitWithString:limitString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"limit is non-float"];
        return NO;
    }
    
    if (order) {
        if (order.count != 2) {
            [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
            return NO;
        }
        
        *sortTarget = order[0];
        *sortOrder = order[1];
        
        if (!(*sortTarget) || !(*sortOrder)) {
            [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
            return NO;
        }
    } else {
        *sortTarget = DConnectFileProfileParamPath;
        *sortOrder = DConnectFileProfileOrderASC;
    }
    return YES;
}


// ソート要素を決める
- (void)compareOrderWithResponse:(DConnectResponseMessage *)response
                      sortTarget:(NSString *)sortTarget
                            comp:(NSComparator *)comp
                       sortOrder:(NSString *)sortOrder
{
    // ソート対象の文字列表現を返却するブロックを用意する。
    __block id (^accessor)(id);
    if ([sortTarget isEqualToString:DConnectFileProfileParamPath]) {
        accessor = ^id(id obj) {
            return [(DConnectMessage *)obj stringForKey:DConnectFileProfileParamPath];
        };
    } else if ([sortTarget isEqualToString:DConnectFileProfileParamFileName]) {
        accessor = ^id(id obj) {
            return [(DConnectMessage *)obj stringForKey:DConnectFileProfileParamFileName];
        };
    } else if ([sortTarget isEqualToString:DConnectFileProfileParamMIMEType]) {
        accessor = ^id(id obj) {
            return [(DConnectMessage *)obj stringForKey:DConnectFileProfileParamMIMEType];
        };
    } else if ([sortTarget isEqualToString:DConnectFileProfileParamUpdateDate]) {
        accessor = ^id(id obj) {
            return [(DConnectMessage *)obj stringForKey:DConnectFileProfileParamUpdateDate];
        };
    } else if ([sortTarget isEqualToString:DConnectFileProfileParamFileSize]) {
        accessor = ^id(id obj) {
            return [[(DConnectMessage *)obj objectForKey:DConnectFileProfileParamFileSize]
                    descriptionWithLocale:nil];
        };
    } else if ([sortTarget isEqualToString:DConnectFileProfileParamFileType]) {
        accessor = ^id(id obj) {
            return [[(DConnectMessage *)obj objectForKey:DConnectFileProfileParamFileType]
                    descriptionWithLocale:nil];
        };
    } else {
            [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
            return;
    }
    
    if ([sortOrder isEqualToString:DConnectFileProfileOrderASC]) {
        *comp = ^NSComparisonResult(id obj1, id obj2) {
            id obj1Tmp = accessor(obj1);
            id obj2Tmp = accessor(obj2);
            return [obj1Tmp localizedCaseInsensitiveCompare:obj2Tmp];
        };
    } else if ([sortOrder isEqualToString:DConnectFileProfileOrderDESC]) {
        *comp = ^NSComparisonResult(id obj1, id obj2) {
            id obj1Tmp = accessor(obj1);
            id obj2Tmp = accessor(obj2);
            return [obj2Tmp localizedCaseInsensitiveCompare:obj1Tmp];
        };
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
        return;
    }
}
@end
