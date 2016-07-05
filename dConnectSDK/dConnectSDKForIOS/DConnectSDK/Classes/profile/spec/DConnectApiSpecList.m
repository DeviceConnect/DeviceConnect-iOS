//
//  DConnectApiSpecList.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpecList.h"
#import "DConnectApiSpecJsonParser.h"

@interface DConnectApiSpecList()

// DConnectApiSpecの配列
@property NSMutableArray *mApiSpecList;


@end


@implementation DConnectApiSpecList

// 共有インスタンス
+ (DConnectApiSpecList *)shared {
    static DConnectApiSpecList *sharedApiSpecList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApiSpecList = [[DConnectApiSpecList alloc] init];
    });
    return sharedApiSpecList;
}

// 初期化
- (id) init {
    self = [super init];
    if (self) {
        
        // 初期値設定
        self.mApiSpecList = [NSMutableArray array];
    }
    return self;
}

- (DConnectApiSpec *) findApiSpec: (NSString *) method
                             path: (NSString *) path
{
    NSString *methodLow = [method lowercaseString];
    NSString *pathLow = [path lowercaseString];
    
    for (DConnectApiSpec *spec in self.mApiSpecList) {
        
        if ([[[DConnectApiSpec convertMethodToString: [spec method]] lowercaseString] isEqualToString: methodLow] &&
            [[[spec path] lowercaseString] isEqualToString: pathLow]) {
            return spec;
        }
    }
    return nil;
}

// プロファイル名を元にAPI仕様定義ファイル(JSON)を読み込み、mApiSpecListに格納する。エラーが発生したら例外をスローする。
- (void) addApiSpecList :(NSString *)profileName {
    
    NSString * jsonFilePath = [self jsonFilePathWithProfileName: profileName];
    if (!jsonFilePath) {
        @throw [NSString stringWithFormat: @"json file not found : %@", profileName];
    }
    
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile: (NSString *)jsonFilePath
                                                     encoding: NSUTF8StringEncoding
                                                        error: &error];
    if (error) {
        @throw [NSString stringWithFormat: @"json file open error : %@", error.localizedDescription];
        return;
    }
    
    // JSON文字列をNSArrayに変換(失敗したら例外スローする)
    id array = [self convertToJsonDataFromJsonString: jsonString];
    
    // NSArrayをApiSpecに変換して格納する
    if ([array isKindOfClass: [NSArray class]]) {
        NSArray *jsonArray = (NSArray *) array; // NSDictionaryの配列
        
        for (NSDictionary *jsonObj in jsonArray) {
            
            if ([jsonObj isKindOfClass: [NSDictionary class]]) {
                
                // ApcSpecに変換する
                DConnectApiSpec *apiSpec = [DConnectApiSpecJsonParser fromJson: jsonObj];
                if (apiSpec != nil) {
                    [self addApiSpec : apiSpec];
                }
            }
        }
    }
}

- (void) addApiSpec : (DConnectApiSpec *)apiSpec {
    [self.mApiSpecList addObject: apiSpec];
}

// JSON文字列をNSArray(配列の場合)またはNSDictionary(Objectの場合)に変換(失敗したら例外スローする)
- (id) convertToJsonDataFromJsonString: (NSString *) jsonString {
    
    // JSON文字列をNSDataに変換
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    // JSON を NSArray に変換する
    NSError *error;
    id array = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingAllowFragments
                                                 error:&error];
    if (error != nil) {
        @throw [NSString stringWithFormat: @"JSON parse error: %@", error];
    }
    
    return array;
}

#pragma mark - Private Method

// プロファイル名を元にDConnectSDK_resources.Bundleに格納されたAPI定義JSONファイル名(<プロファイル名>.json)のファイルパスを返す。存在しないときはnilを返す。
- (NSString *)jsonFilePathWithProfileName: (NSString *)jsonFilename {
    
    NSString *filetype = @"json";
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *pathName = [bundle pathForResource:jsonFilename ofType:filetype];
    
    return pathName;
}

@end
