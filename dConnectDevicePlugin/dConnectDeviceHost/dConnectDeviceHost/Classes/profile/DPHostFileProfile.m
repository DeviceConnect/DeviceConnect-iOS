//
//  DPHostFileProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectFileManager.h>
#import "DPHostFileProfile.h"
#import "DPHostDevicePlugin.h"
#import "DPHostUtils.h"

@interface DPHostFileProfile ()

//@property NSMutableDictionary *mimeExtDict;
@property NSMutableDictionary *mediaIdUriDict;

@end

@implementation DPHostFileProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak DPHostFileProfile *weakSelf = self;
        
        // API登録(didReceiveGetReceiveRequest相当)
        NSString *getReceiveRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectFileProfileAttrReceive];
        [self addGetPath: getReceiveRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *path = [DConnectFileProfile pathFromRequest:request];
                         
                         if (!path || path.length == 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
                             return YES;
                         }
                         
                         // pathが絶対であれ相対であれベースURLに追加する。
                         NSString *dstPath = [WEAKSELF_PLUGIN pathByAppendingPathComponent:path];
                         if ([weakSelf checkPath:dstPath]) {
                             dstPath = path;
                         }
                         NSFileManager *sysFileMgr = [NSFileManager defaultManager];
                         BOOL isDirectory;
                         if (![sysFileMgr fileExistsAtPath:dstPath isDirectory:&isDirectory]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"File does not exists."];
                             return YES;
                         } else if (isDirectory) {
                             [response setErrorToUnknownWithMessage:@"Directory can not be specified."];
                             return YES;
                         }
                         
                         [DConnectFileProfile setURI:[[NSURL fileURLWithPath:dstPath] absoluteString] target:response];
                         NSString *mimeType = [DConnectFileManager searchMimeTypeForExtension:[dstPath pathExtension]];
                         if (!mimeType) {
                             mimeType = [DConnectFileManager mimeTypeForArbitraryData];
                         }
                         [DConnectFileProfile setMIMEType:mimeType target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         
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
                         NSString *mimeType = [DConnectFileProfile mimeTypeFromRequest:request];
                         NSArray *order = nil;
                         
                         if (orderStr) {
                             order = [orderStr componentsSeparatedByString:@","];
                         }
                         
                         DConnectFileManager *fileMgr = [WEAKSELF_PLUGIN fileMgr];
                         NSFileManager *sysFileMgr = [NSFileManager defaultManager];
                         
                         NSString *listPath;
                         NSString *sortTarget;
                         NSString *sortOrder;
                         listPath = [self checkParameters:request
                                                 response:response
                                                     path:path
                                                  fileMgr:fileMgr
                                               sysFileMgr:sysFileMgr
                                                sortOrder:&sortOrder
                                               sortTarget:&sortTarget
                                                    order:order];
                         if (!listPath) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }
                         NSComparator comp;
                         [weakSelf compareOrderWithResponse:response sortTarget:sortTarget comp:&comp sortOrder:sortOrder];
                         if ([response integerForKey:DConnectMessageResult] == DConnectMessageResultTypeError) {
                             [response setErrorToInvalidRequestParameter];
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
                         
                         NSMutableArray *fileArr;
                         fileArr = [self searchFilesWithFileManager:fileMgr listPath:listPath sysFileMgr:sysFileMgr mimeType:mimeType];
                         
                         if (offset && offset.integerValue >= fileArr.count) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"offset exceeds the size of the media list."];
                             return YES;
                         }
                         
                         // 並び替えを実行
                         NSArray *tmpArr = [fileArr sortedArrayUsingComparator:comp];
                         
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
        
        // API登録(didReceivePostSendRequest相当)
        NSString *postSendRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectFileProfileAttrSend];
        [self addPostPath: postSendRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                          NSData *data = [DConnectFileProfile dataFromRequest:request];
                          NSString *uri = [DConnectFileProfile uriFromRequest:request];
                          NSString *path = [DConnectFileProfile pathFromRequest:request];

                          NSData *fileData = nil;
                          if (data && data.length > 0) {
                              fileData = data;
                          } else if (uri) {
                              fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:uri]];
                          }
                          
                          if (!fileData || fileData.length <= 0) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"No file data"];
                              return YES;
                          }
                          
                          if (!path || path.length == 0) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
                              return YES;
                          }
                          
                          DConnectFileManager *fileMgr = [WEAKSELF_PLUGIN fileMgr];
                          NSFileManager *sysFileMgr = [NSFileManager defaultManager];
                          
                          // pathが絶対であれ相対であれベースURLに追加する。
                          NSString *dstPath = [WEAKSELF_PLUGIN pathByAppendingPathComponent:path];
                          if ([weakSelf checkPath:dstPath]) {
                              dstPath = path;
                          }
                          if ([sysFileMgr fileExistsAtPath:dstPath]) {
                              // ファイルが既に存在している
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"File already exists at the specified path."];
                          } else {
                              NSString *resultPath = [fileMgr createFileForPath:dstPath contents:fileData];
                              if (resultPath) {
                                  [DConnectFileProfile setPath:dstPath target:response];
                                  [response setResult:DConnectMessageResultTypeOk];
                              } else {
                                  [response setErrorToUnknownWithMessage:@"File creation failed"];
                              }
                          }
                          
                          return YES;
                      }];
        
        // API登録(didReceivePostMkdirRequest相当)
        NSString *postMkdirRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectFileProfileAttrMkdir];
        [self addPostPath: postMkdirRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                          NSString *path = [DConnectFileProfile pathFromRequest:request];
                          
                          if (!path) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
                              return YES;
                          }
                          
                          NSFileManager *sysFileMgr = [NSFileManager defaultManager];
                          
                          // pathが絶対であれ相対であれベースURLに追加する。
                          NSString *dstPath = [WEAKSELF_PLUGIN pathByAppendingPathComponent:path];
                          if ([weakSelf checkPath:dstPath]) {
                              dstPath = path;
                          }
                          if ([sysFileMgr fileExistsAtPath:dstPath]) {
                              // ディレクトリが既に存在している
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"File/directory already exists at the specified path."];
                          } else {
                              BOOL result = [sysFileMgr createDirectoryAtPath:dstPath
                                                  withIntermediateDirectories:YES attributes:nil error:nil];
                              if (result) {
                                  [response setResult:DConnectMessageResultTypeOk];
                              } else {
                                  [response setErrorToUnknownWithMessage:@"File creation failed"];
                              }
                          }
                          
                          return YES;
                      }];

        // API登録(didReceiveDeleteRemoveRequest相当)
        NSString *deleteRemoveRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectFileProfileAttrRemove];
        [self addDeletePath: deleteRemoveRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *path = [DConnectFileProfile pathFromRequest:request];
                            
                            if (!path || path.length == 0) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
                                return YES;
                            }
                            
                            NSFileManager *sysFileMgr = [NSFileManager defaultManager];
                            NSError *error;
                            
                            // pathが絶対であれ相対であれベースURLに追加する。
                            NSString *dstPath = [WEAKSELF_PLUGIN pathByAppendingPathComponent:path];
                            if ([weakSelf checkPath:dstPath]) {
                                dstPath = path;
                            }
                            BOOL isDirectory;
                            if (![sysFileMgr fileExistsAtPath:dstPath isDirectory:&isDirectory]) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"File does not exist."];
                                return YES;
                            } else if (isDirectory) {
                                [response setErrorToUnknownWithMessage:@"Directory can not be specified; use Remove Directory API instead."];
                                return YES;
                            }
                            
                            [sysFileMgr removeItemAtPath:dstPath error:&error];
                            if ([sysFileMgr fileExistsAtPath:dstPath] || error) {
                                [response setErrorToUnknownWithMessage:@"File operation failed."];
                            } else {
                                [response setResult:DConnectMessageResultTypeOk];
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteRmdirRequest相当)
        NSString *deleteRmdirRequestApiPath = [self apiPath: nil
                                              attributeName: DConnectFileProfileAttrRmdir];
        [self addDeletePath: deleteRmdirRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *path = [DConnectFileProfile pathFromRequest:request];
                            BOOL force = [DConnectFileProfile forceFromRequest:request];
                            
                            if (!path) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"path must be specified."];
                                return YES;
                            }
                            
                            NSFileManager *sysFileMgr = [NSFileManager defaultManager];
                            
                            // pathが絶対であれ相対であれベースURLに追加する。
                            NSString *dstPath = [WEAKSELF_PLUGIN pathByAppendingPathComponent:path];
                            if ([weakSelf checkPath:dstPath]) {
                                dstPath = path;
                            }
                            BOOL isDirectory;
                            if (![sysFileMgr fileExistsAtPath:dstPath isDirectory:&isDirectory]) {
                                // ディレクトリが存在しない
                                [response setErrorToUnknownWithMessage:
                                 @"Directory does not exist at the specified path."];
                            } else {
                                if (isDirectory) {
                                    NSArray *contents = [sysFileMgr contentsOfDirectoryAtPath:dstPath error:nil];
                                    if (contents.count != 0 && !force) {
                                        [response setErrorToIllegalDeviceStateWithMessage:
                                         @"Could not delete a directory containing files; set force to YES for a recursive deletion."];
                                    } else {
                                        BOOL result = [sysFileMgr removeItemAtPath:dstPath error:nil];
                                        if (result) {
                                            [response setResult:DConnectMessageResultTypeOk];
                                        } else {
                                            [response setErrorToUnknownWithMessage:@"Failed to remove the speficified directory."];
                                        }
                                    }
                                } else {
                                    // パスでしていされた項目がディレクトリではない
                                    [response setErrorToInvalidRequestParameterWithMessage:
                                     @"File specified by path is not a directory."];
                                }
                            }
                            
                            return YES;
                        }];
    }
    return self;
}

#pragma mark - Private Methods

/*!
 @brief /file/listのパラメータチェック.
 */
- (NSString *)checkParameters:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                         path:(NSString *)path
                      fileMgr:(DConnectFileManager *)fileMgr
                   sysFileMgr:(NSFileManager *)sysFileMgr
                    sortOrder:(NSString **)sortOrder
                   sortTarget:(NSString **)sortTarget
                        order:(NSArray *)order
{
    NSString *offsetString = [request stringForKey:DConnectFileProfileParamOffset];
    NSString *limitString = [request stringForKey:DConnectFileProfileParamLimit];
    if (offsetString && ![DPHostUtils existDigitWithString:offsetString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"offset is non-float"];
        return nil;
    }
    if (limitString && ![DPHostUtils existDigitWithString:limitString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"limit is non-float"];
        return nil;
    }
    
    NSString* listPath = path;
    if (listPath) {
        // pathが絶対であれ相対であれベースURLに追加する。
        if ([listPath isEqualToString:@".."]) {
            listPath = @"/";
        }
        NSString *dstPath = [SELF_PLUGIN pathByAppendingPathComponent:listPath];
        if (![self checkPath:dstPath]) {
            listPath = dstPath;
        }
        if (![sysFileMgr fileExistsAtPath:listPath]) {
            [response setErrorToInvalidRequestParameterWithMessage:@"path is invalid"];
            return nil;
        }
    } else {
        listPath = fileMgr.URL.path;
    }
    
    
    if (order) {
        if (order.count != 2) {
            [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
            return nil;
        }
        
        *sortTarget = order[0];
        *sortOrder = order[1];
        
        if (!(*sortTarget) || !(*sortOrder)) {
            [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
            return nil;
        }
    } else {
        *sortTarget = DConnectFileProfileParamPath;
        *sortOrder = DConnectFileProfileOrderASC;
    }
    return listPath;
}

/**!
 @brief Fileの検索.
 */
- (NSMutableArray *)searchFilesWithFileManager:(DConnectFileManager *)fileMgr
                                      listPath:(NSString *)listPath
                                    sysFileMgr:(NSFileManager *)sysFileMgr
                                      mimeType:(NSString *)mimeType
{
    NSMutableArray *fileArr = [NSMutableArray array];
    
    // # NSDirectoryEnumeratorからプロパティを取得する方法
    // 「- enumeratorAtURL:includingPropertiesForKeys:options:errorHandler:」で返ってきたNSDirectoryEnumerator
    // の「- directoryAttributes」や「- fileAttributes」はnilを返す。
    // 代わりにNSURLの「- resourceValuesForKeys:error:」などで取得すること。
    NSString *rootPath = [@"/private" stringByAppendingString:fileMgr.URL.path];
    BOOL mkBackRoot = NO;
    NSDirectoryEnumerator *dirIter =
    [fileMgr enumeratorWithOptions:NSDirectoryEnumerationSkipsSubdirectoryDescendants dirPath:listPath];
    NSURL *url;
    while ((url = dirIter.nextObject)) {
        NSString *pathItr = url.path;
        // MIMEタイプ検索
        if (mimeType) {
            NSString *thisMimeType = [DConnectFileManager searchMimeTypeForExtension:url.pathExtension];
            NSRange result = [thisMimeType rangeOfString:mimeType.lowercaseString];
            if (result.location == NSNotFound && result.length == 0) {
                // MIMEタイプにマッチせず；スキップ。
                continue;
            }
        }
        
        DConnectMessage *file = [DConnectMessage message];
        
        [DConnectFileProfile setPath:pathItr target:file];
        [DConnectFileProfile setFileName:url.lastPathComponent target:file];
        
        NSDate *modifiedDate;
        [url getResourceValue:&modifiedDate forKey:NSURLAttributeModificationDateKey error:nil];
        NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
        [rfc3339DateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
        [rfc3339DateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [DConnectFileProfile setUpdateDate:[rfc3339DateFormatter stringFromDate:modifiedDate] tareget:file];
        
        NSNumber *fileSize;
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        [DConnectFileProfile setFileSize:[fileSize longLongValue] target:file];
        
        NSString *pluginRootPath = [pathItr stringByReplacingOccurrencesOfString:rootPath withString:@""];
        NSArray *dirCount = [pluginRootPath componentsSeparatedByString:@"/"];
        
        if (dirCount.count > 2 && !mkBackRoot) {
            DConnectMessage *upDir = [DConnectMessage message];
            [DConnectFileProfile setPath:[self removeLastDirectoryNameWithRoot:listPath] target:upDir];
            [DConnectFileProfile setFileName:@".." target:upDir];
            [DConnectFileProfile setUpdateDate:[rfc3339DateFormatter stringFromDate:modifiedDate] tareget:upDir];
            [DConnectFileProfile setMIMEType:@"dir/folder" target:upDir];
            [DConnectFileProfile setFileType:1 target:upDir];
            [DConnectFileProfile setFileSize:0 target:upDir];
            [fileArr addObject:upDir];
            mkBackRoot = YES;
        }
        BOOL isDirectory;
        
        [sysFileMgr fileExistsAtPath:pathItr isDirectory:&isDirectory];
        if (isDirectory) {
            [DConnectFileProfile setMIMEType:@"dir/folder" target:file];
            [DConnectFileProfile setFileType:1 target:file];
        } else {
            NSString *mimeTypes = [DConnectFileManager searchMimeTypeForExtension:url.pathExtension.lowercaseString];
            if (!mimeTypes) {
                mimeTypes = [DConnectFileManager mimeTypeForArbitraryData];
            }
            [DConnectFileProfile setMIMEType:mimeTypes target:file];
            [DConnectFileProfile setFileType:0 target:file];
        }
        
        [fileArr addObject:file];
    }
    NSArray *names = [listPath componentsSeparatedByString:@"/"];
    // DPHostDevicePluginのルートディレクトリかどうか
    if (![names[names.count - 1] isEqualToString:@"DPHostDevicePlugin"]
        && !mkBackRoot) {
        DConnectMessage *upDir = [DConnectMessage message];
        [DConnectFileProfile setPath:[self removeLastDirectoryNameWithRoot:listPath] target:upDir];
        [DConnectFileProfile setFileName:@".." target:upDir];
        [DConnectFileProfile setMIMEType:@"dir/folder" target:upDir];
        [DConnectFileProfile setFileType:1 target:upDir];
        [DConnectFileProfile setFileSize:0 target:upDir];
        [fileArr addObject:upDir];
    }
    return fileArr;
}

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

//一つ上の絶対ディレクトリパスを返す
- (NSString*)removeLastDirectoryNameWithRoot:(NSString*)listPath
{
    NSString *lastPath = listPath;
    NSArray *names = [lastPath componentsSeparatedByString:@"/"];
    NSRange lastDirectory = [lastPath rangeOfString:[@"/" stringByAppendingString:names[names.count - 1]]
                                            options:NSBackwardsSearch];
    //ルートディレクトリ（DPHostDevicePlugin)の場合は、そのまま返す
    if(lastDirectory.location != NSNotFound
       && ![lastPath hasSuffix:@"/Application Support/DPHostDevicePlugin"]) {
        lastPath = [lastPath stringByReplacingCharactersInRange:lastDirectory
                                                     withString:@""];
    }
    return lastPath;
}



//不正なパスかどうかを検査する
-(BOOL)checkPath:(NSString*)dstPath {
    NSMutableArray *results = [NSMutableArray array];
    NSRange target = NSMakeRange(0, [dstPath length]);
    NSString *word = @"/var/mobile";
    
    // 全件検索
    while (target.location != NSNotFound) {
        
        // 検索
        target = [dstPath rangeOfString:word options:0 range:target];
        if (target.location != NSNotFound) {
            
            // 結果格納
            [results addObject:[NSValue valueWithRange:target]];
            
            // 次の検索範囲を設定
            int from = (int) (target.location + [word length]);
            int end = (int) ([dstPath length] - from);
            target = NSMakeRange(from, end);
        }
    }
    return ([results count] >= 2);
}
@end
