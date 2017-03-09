//
//  DConnectPluginSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectPluginSpec.h>
#import "DConnectProfileSpecJsonParserFactory.h"

static NSString * const dConnectSDKBundleName = @"DConnectSDK_resources";

#define DConnectSDKBundle() ([NSBundle bundleWithPath: [[NSBundle mainBundle] pathForResource:dConnectSDKBundleName ofType:@"bundle"]])

@interface DConnectPluginSpec()

@property(nonatomic, strong) DConnectProfileSpecJsonParser *jsonParser;

@property(nonatomic, strong) NSMutableDictionary *profileSpecs_; // Map<String, DConnectProfileSpec>

@end


@implementation DConnectPluginSpec

+ (DConnectPluginSpec *) shared {
    static DConnectPluginSpec *sharedPluginSpec = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPluginSpec = [[DConnectPluginSpec alloc] init];
    });
    return sharedPluginSpec;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setJsonParser: [[DConnectProfileSpecJsonParserFactory getDefaultFactory] createParser]];
        [self setProfileSpecs: [NSMutableDictionary dictionary]];
    }
    return self;
}



/*!
 @brief 入力ファイルからDevice Connectプロファイルの仕様定義を追加する.
 
 @param[in] profileName プロファイル名
 @param[in] selfBundle 独自拡張プロファイル用SwaggerJsonファイルが含まれるBundle。渡す必要がない場合はnilを渡す。
 @retval YES 追加成功。
 @retval NO 追加失敗。API仕様定義JSONファイル解析に失敗等。
 */
- (BOOL) addProfileSpec: (NSString *) profileName bundle: (NSBundle *) selfBundle error: (NSError **) error {

    NSString *profileNameLow = [profileName lowercaseString];
    
    // 読み込み済みなら再読み込みしないで成功を返す
    if ([self findProfileSpec: profileNameLow]) {
        return YES;
    }
    
    // プロファイル名を元にBundle内のJSONファイルを読み込みファイル内容(JSON文字列)を返す。
    NSString *json = nil;
    
    // selfBundleが指定されている場合はselfBundleから読み込む
    if (selfBundle) {
        json = [self loadFile: profileNameLow bundle: selfBundle];
    }
    
    // DConnectSDKのBundleから読み込む
    if (!json) {
        json = [self loadFile: profileNameLow bundle: DCBundle()];
    }
    
    // 読み込めなかったらNOを返す
    if (!json) {
        return NO;
    }
    
    // JSON文字列をパースしてNSDictionaryに変換
    id jsonObj_ = [self convertToJsonDataFromJsonString: json];
    if (!jsonObj_) {
        return NO;
    }
    if (![jsonObj_ isKindOfClass: [NSDictionary class]]) {
        return NO;
    }
    NSDictionary *jsonObj = (NSDictionary *) jsonObj_;
    
    // NSDictionaryをDConnectProfileSpecに変換して格納
    DConnectProfileSpec *profileSpec =[[self jsonParser] parseJson: jsonObj error: error];
    if (!profileSpec.profile) {
        [profileSpec setProfile:profileName];
    }
    for (DConnectApiSpec *apiSpec in [profileSpec apiSpecList]) {
        [apiSpec setApiName:profileSpec.api];
        [apiSpec setProfileName:profileSpec.profile];
    }
    [self profileSpecs_][profileNameLow] = profileSpec;
    return YES;
}

- (NSString *) loadFile: (NSString *) profileName bundle: (NSBundle *) bundle {
    
    // プロファイル名とJSONファイル名は大文字小文字が区別されるので、一致するよう小文字で統一する。(jsonファイル名も全て小文字にする)
    
    NSString *profileNameLower = [profileName lowercaseString];
    
    // DConnectSDKのBundleに存在すれば読み込む。
    NSString *filePath = [self jsonFilePathWithProfileName: profileNameLower bundle: bundle];
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile: (NSString *)filePath
                                                     encoding: NSUTF8StringEncoding
                                                        error: &error];
    if (error) {
        // @throw [NSString stringWithFormat: @"json file open error : %@", error.localizedDescription];
        return nil;
    }
    
    return jsonString;
}

/*!
 @brief 指定したプロファイルの仕様定義を取得する.
 @param profileName プロファイル名
 @return {@link DConnectProfileSpec}のインスタンス
 */
- (DConnectProfileSpec *) findProfileSpec: (NSString *) profileName {
    NSString *profileNameLow = [profileName lowercaseString];
    return [self profileSpecs_][profileNameLow];
}

/*!
 @brief プラグインのサポートするプロファイルの仕様定義の一覧を登録する.
 <p>
 このメソッドに登録する一覧には、各プロファイル上で定義されているすべてのAPIの定義が含まれる.
 </p>
 @return {@link DConnectProfileSpec}のマップ. キーはプロファイル名.Map<String, DConnectProfileSpec>
 */
- (void) setProfileSpecs:(NSMutableDictionary *)profileSpecs {
    [self setProfileSpecs_: profileSpecs];
}

/*!
 @brief プラグインのサポートするプロファイルの仕様定義の一覧を取得する.
 <p>
 このメソッドから返される一覧には、各プロファイル上で定義されているすべてのAPIの定義が含まれる.
 </p>
 @return {@link DConnectProfileSpec}のマップ. キーはプロファイル名.Map<String, DConnectProfileSpec>
 */
- (NSDictionary *) profileSpecs {
   NSDictionary *deepCopyDictionary = [[NSDictionary alloc] initWithDictionary:[self profileSpecs_] copyItems:YES];
   return deepCopyDictionary;
}

#pragma mark - Private Method

/*!
 @brief プロファイル名を元にbundleに格納されたAPI定義JSONファイル名(<プロファイル名>.json)のファイルパスを返す。
 @param[in] jsonFilename JSONファイル名(=プロファイル名)
 @param[in] bundle jsonFilenameを探すBundle
 @retval Bundle内のJSONファイルパス
 */
- (NSString *)jsonFilePathWithProfileName: (NSString *)jsonFilename bundle: (NSBundle *) bundle {
    
    NSString *filetype = @"json";
    NSString *pathName = [bundle pathForResource:jsonFilename ofType:filetype];
    return pathName;
}

/*!
 @brief JSON文字列をNSArray(配列の場合)またはNSDictionary(Objectの場合)に変換(失敗したら例外スローする)
 */
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

@end
