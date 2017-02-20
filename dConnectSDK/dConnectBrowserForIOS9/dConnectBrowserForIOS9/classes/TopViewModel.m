//
//  TopViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TopViewModel.h"
#import <DConnectSDK/DConnectSDK.h>
#import "GHDataManager.h"
#import "GHDeviceUtil.h"
#import "AppDelegate.h"

@interface TopViewModel()
@property(nonatomic, strong) NSArray* devices;
@end

@implementation TopViewModel

//--------------------------------------------------------------//
#pragma mark - 初期化
//--------------------------------------------------------------//
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [[GHURLManager alloc]init];
        self.url = @"http://www.google.com";
        self.devices = [[NSArray alloc]init];
        self.datasource = [[NSMutableArray alloc]initWithObjects:
                           [[NSArray alloc]init],
                           self.devices,
                           nil];
        __weak TopViewModel *_self = self;
        [[GHDeviceUtil shareManager] setRecieveDeviceList:^(DConnectArray *deviceList){
            [_self updateDevice:deviceList];
        }];
        [self updateDatasource];
    }
    return self;
}

- (void)dealloc
{
    self.manager = nil;
    self.url = nil;
    self.datasource = nil;
    [[GHDeviceUtil shareManager] setRecieveDeviceList: nil];
}

//--------------------------------------------------------------//
#pragma mark - datasource生成
//--------------------------------------------------------------//
- (void)updateDatasource
{
    [self.datasource replaceObjectAtIndex:Bookmark withObject:[self setupBookmarks]];
    [self.datasource replaceObjectAtIndex:Device withObject:[self showableDevices]];
}


//--------------------------------------------------------------//
#pragma mark - bookmarks
//--------------------------------------------------------------//
static NSInteger maxIconCount = 8;
- (NSArray*)setupBookmarks
{
    NSMutableArray* bookmarks = [[self fetchBookmarks]mutableCopy];
    if ([bookmarks count] == 0) {
        bookmarks = [[NSMutableArray alloc]init];
    }
    //maxIconCountに達していない場合はダミーを作成する
    while (bookmarks.count < maxIconCount) {
        GHPageModel* page = [[GHPageModel alloc]init];
        page.type = TYPE_BOOKMARK_DUMMY;
        [bookmarks addObject:page];
    }
    return bookmarks;
}

- (NSArray*)fetchBookmarks
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"type == %@ AND latest_opened_date != NULL AND priority > %d", TYPE_BOOKMARK, PRIORITY-1];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"latest_opened_date" ascending:NO];
    NSArray* bookmarks = [[GHDataManager shareManager]getModelDataByPredicate:predicate
                                                          withSortDescriptors:@[sortDescriptor]
                                                                   entityName:@"Page"
                                                                        limit: maxIconCount
                                                                      context:nil];
    return bookmarks;
}

- (BOOL)isBookmarksEmpty
{
    for (GHPageModel* page in [self.datasource objectAtIndex:Bookmark]) {
        if (![page.type isEqualToString:TYPE_BOOKMARK_DUMMY]) {
            return NO;
        }
    }
    return YES;
}


//--------------------------------------------------------------//
#pragma mark - Devices
//--------------------------------------------------------------//
- (void)updateDevice:(DConnectArray*)deviceList
{
    NSMutableArray* array = [[NSMutableArray alloc]init];
    for (int s = 0; s < [deviceList count]; s++) {
        DConnectMessage *service = [deviceList messageAtIndex: s];
        [array addObject:service];
    }
    self.devices = array;
    _isDeviceLoading = NO;
    [self updateDatasource];
    [self.delegate requestDatasourceReload];
}

- (NSArray*)showableDevices
{
    if([self.devices count] > maxIconCount) {
        NSMutableArray* reduce = [self.devices mutableCopy];
        NSRange range = NSMakeRange(maxIconCount-1, [self.devices count] - maxIconCount+1); //NOTE:+1は詳細ボタンを追加するため
        [reduce removeObjectsInRange:range];

        //最後の1つを詳細表示用にNSStringを入れる
        [reduce addObject: @"deviceDeteilButtonKey"];
        return reduce;
    }
    return self.devices;
}

- (BOOL)isDeviceEmpty
{
    return ([self.devices count] == 0);
}

- (void)updateDeviceList
{
    _isDeviceLoading = YES;
    [[GHDeviceUtil shareManager] updateDeviceList];
}

//--------------------------------------------------------------//
#pragma mark - useOriginBlocking 更新
//--------------------------------------------------------------//
- (void)initialSetup
{
    DConnectManager *mgr = [DConnectManager sharedManager];
    BOOL isOriginBlock = [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_BLOCKING];
    mgr.settings.useOriginBlocking = isOriginBlock;
    BOOL isLocalOAuth = [[NSUserDefaults standardUserDefaults] boolForKey:IS_USE_LOCALOAUTH];
    mgr.settings.useLocalOAuth = isLocalOAuth;
    BOOL isOriginEnable = [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_ENABLE];
    mgr.settings.useOriginEnable = isOriginEnable;
    BOOL isExternalIp = [[NSUserDefaults standardUserDefaults] boolForKey:IS_EXTERNAL_IP];
    mgr.settings.useExternalIP = isExternalIp;
    BOOL isManagerName = [[NSUserDefaults standardUserDefaults] boolForKey:IS_AVAILABILITY];
    mgr.settings.useManagerName = isManagerName;
}

- (void)saveSettings
{
    DConnectManager *mgr = [DConnectManager sharedManager];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:mgr.settings.useOriginBlocking forKey:IS_ORIGIN_BLOCKING];
    [def setBool:mgr.settings.useLocalOAuth forKey:IS_USE_LOCALOAUTH];
    [def setBool:mgr.settings.useOriginEnable forKey:IS_ORIGIN_ENABLE];
    [def setBool:mgr.settings.useExternalIP forKey:IS_EXTERNAL_IP];
    [def setBool:mgr.settings.useManagerName forKey:IS_AVAILABILITY];
    [def synchronize];
}


//--------------------------------------------------------------//
#pragma mark - URL
//--------------------------------------------------------------//
- (NSString*)checkUrlString:(NSString*)url
{
    //文字列がURLの場合
    self.url = [self.manager isURLString:url];
    if ([url rangeOfString:@"#"].location != NSNotFound) {
        self.url = url;
    } else if (!self.url) {
        self.url = [self.manager createSearchURL:url];
    }
    // http:// https://が省略されているときは付加する
    if (![[self.url lowercaseString] hasPrefix:@"http://"]
        && ![[self.url lowercaseString] hasPrefix:@"https://"]) {
        self.url = [NSString stringWithFormat:@"http://%@", self.url];
    }
    [self setLatestURL:self.url];
    if ([self.url rangeOfString:@"%23"].location != NSNotFound) {
        self.url = [self.url stringByReplacingOccurrencesOfString:@"%23" withString:@"#"] ;
    }

    return self.url;
}


- (NSString*)makeURLFromNotification:(NSNotification*)notif
{
    NSDictionary *dict = notif.userInfo;
    NSString* url = [dict objectForKey:PAGE_URL];
    self.url = url;
    if ([self.url rangeOfString:@"%23"].location != NSNotFound) {
        self.url = [self.url stringByReplacingOccurrencesOfString:@"%23" withString:@"#"] ;
    } else if (![self.manager isURLString:self.url]) {
        self.url = [self.manager createSearchURL:url];
    }

    [self setLatestURL:self.url];
    return self.url;
}

- (void)setLatestURL:(NSString*)url
{
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    app.latestURL = [NSURL URLWithString: url];
}



//--------------------------------------------------------------//
#pragma mark - 初期ガイド表示
//--------------------------------------------------------------//
- (BOOL)isNeedOpenInitialGuide
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    if ([def boolForKey:IS_INITIAL_GUIDE_OPEN]) {
        return NO;
    } else {
        [def setBool:YES forKey:IS_INITIAL_GUIDE_OPEN];
        [def synchronize];
        return YES;
    }
}

@end
