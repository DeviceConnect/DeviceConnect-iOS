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
+ (instancetype)shared
{
    static id sharedInstance;
    static dispatch_once_t onceSpheroToken;
    dispatch_once(&onceSpheroToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
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

- (void) addApiSpecList :(NSString *)jsonFilePath {
    
    NSString *jsonString = [NSString stringWithContentsOfFile: (NSString *)jsonFilePath
                                                     encoding: NSUTF8StringEncoding
                                                        error: nil];
    
    if (!jsonString) {
        NSLog(@"loadApiSpecDebug Failed");
        return;
    }
    
    // JSON文字列をNSDataに変換
    NSData *jsonData = [jsonString dataUsingEncoding:NSUnicodeStringEncoding];
    
    // JSON を NSArray に変換する
    NSError *error;
    id array = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingAllowFragments
                                                 error:&error];
    if (error != nil) {
        NSLog(@"JSON parse error: %@", error);
        return;
    }
    
    // NSArrayをApiSpecに変換して格納する
    if ([array isKindOfClass: [NSArray class]]) {
        NSArray *jsonArray = (NSArray *) array; // NSDictionaryの配列
        
        for (NSDictionary *jsonObj in jsonArray) {
            NSLog(@"jsonObj class: %@", [[jsonObj class] description]);
            
            if ([jsonObj isKindOfClass: [NSDictionary class]]) {
                NSLog(@"jsonObj is NSDictionary");
                DConnectApiSpec *apiSpec = [DConnectApiSpecJsonParser fromJson: jsonObj];
                
                if (apiSpec != nil) {
                    [self addApiSpec : apiSpec];
                }
            }
        }
        
        
        
        
        // DEBUG
        [self debugJsonArray: array];
    }
}
/*
 public void addApiSpecList(final InputStream json) throws IOException, JSONException {
 String file = loadFile(json);
 JSONArray array = new JSONArray(file);
 for (int i = 0; i < array.length(); i++) {
 JSONObject apiObj = array.getJSONObject(i);
 DConnectApiSpec apiSpec = DConnectApiSpec.fromJson(apiObj);
 if (apiSpec != null) {
 addApiSpec(apiSpec);
 }
 }
 }
 */

- (void) addApiSpec : (DConnectApiSpec *)apiSpec {
    [self.mApiSpecList addObject: apiSpec];
}





// ------------------------------------------------------------------------------------------------------------
// Debug用
// ------------------------------------------------------------------------------------------------------------

- (void) loadApiSpecDebug {
    
    NSString *jsonFilename = @"battery";
    NSString *jsonFilePath = [self jsonFilePathWithJsonFilename: jsonFilename];
    
    [self addApiSpecList: jsonFilePath];
}

- (NSString *)jsonFilePathWithJsonFilename: (NSString *)jsonFilename {
    
    NSString *filetype = @"json";
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *pathName = [bundle pathForResource:jsonFilename ofType:filetype];
    
    return pathName;
}


- (void) loadApiSpecDebug_bak {
    
    NSString *filename = @"battery";
    NSString *filetype = @"json";
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *pathName = [bundle pathForResource:filename ofType:filetype];
    
    //    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:pathName encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    NSString *jsonString = [NSString stringWithContentsOfFile:pathName encoding:NSUTF8StringEncoding error:nil];
    
    if (!jsonString) {
        NSLog(@"loadApiSpecDebug Failed");
        return;
    }
    
    [self loadApiSpec: jsonString];
    
}


- (void) loadApiSpec: (NSString *)jsonString {
    
    // JSON文字列をNSDataに変換
    NSData *jsonData = [jsonString dataUsingEncoding:NSUnicodeStringEncoding];
    
    // JSON を NSArray に変換する
    NSError *error;
    NSObject *result = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingAllowFragments
                                                         error:&error];
    if (error != nil) {
        NSLog(@"JSON parse error: %@", error);
        return;
    }
    if (result == nil) {
        NSLog(@"result nil.");
        return;
    }
    
    if ([result isKindOfClass: [NSArray class]]) {
        NSArray *array = (NSArray *)result;
        NSLog(@"array count: %d", (int)[array count]);
        [self debugJsonArray:array];
    }
    else if ([result isKindOfClass: [NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)result;
        NSLog(@"dic count: %d", (int)[dic count]);
        // DEBUG
        [self debugJsonDictionary: dic];
    }
    else {
        NSLog(@"result is not NSArray or NSDictionary.");
        return;
    }
    
    
    
    
}


- (void)debugJsonArray : (NSArray *)array {
    
    for (NSObject *record in array) {
        NSLog(@"array [] description: %@", [[record class] description]);
        
        if ([record isKindOfClass: [NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)record;
            [self debugJsonDictionary: dic];
        }
    }
}

- (void)debugJsonDictionary: (NSDictionary *)dic {
    
    NSLog(@"  dic count: %d", [dic count]);
    NSArray *keys = [dic allKeys];
    NSArray *vals = [dic allValues];
    for(int i=0;i<[keys count];i++){
        NSLog(@"  dic[%d] - key：%@　value：%@", i, [keys objectAtIndex:i], [vals objectAtIndex:i]);
    }
}

@end
