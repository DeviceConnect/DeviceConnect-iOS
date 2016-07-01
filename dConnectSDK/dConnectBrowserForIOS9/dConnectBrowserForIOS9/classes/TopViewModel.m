//
//  TopViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/17.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "TopViewModel.h"
#import <DConnectSDK/DConnectSDK.h>
#import "GHDataManager.h"
#import "GHDeviceUtil.h"

@interface TopViewModel()
{
    GHDeviceUtil* diveiceUtil;
}
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
        __weak TopViewModel *_self = self;
        self.manager = [[GHURLManager alloc]init];
        diveiceUtil = [[GHDeviceUtil alloc]init];
        [diveiceUtil setRecieveDeviceList:^(DConnectArray *deviceList){
            [_self updateDevice:deviceList];
        }];
        self.url = @"http://www.google.com";
        self.devices = [[NSArray alloc]init];
        self.datasource = [[NSMutableArray alloc]initWithObjects:
                           [[NSArray alloc]init],
                           self.devices,
                           nil];
        [self updateDatasource];
    }
    return self;
}

- (void)dealloc
{
    self.manager = nil;
    self.url = nil;
    self.datasource = nil;
    [diveiceUtil setRecieveDeviceList:nil];
    diveiceUtil = nil;
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
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"latest_opened_date != NULL"];
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
    return ([[self.datasource objectAtIndex:Bookmark] count] == 0);
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

//--------------------------------------------------------------//
#pragma mark - useOriginBlocking 更新
//--------------------------------------------------------------//
- (void)initialSetup
{
    DConnectManager *mgr = [DConnectManager sharedManager];
    BOOL isOriginBlock = [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_BLOCKING];
    mgr.settings.useOriginBlocking = isOriginBlock;
}

- (void)saveOriginBlock
{
    DConnectManager *mgr = [DConnectManager sharedManager];
    [[NSUserDefaults standardUserDefaults] setBool:mgr.settings.useOriginBlocking forKey:IS_ORIGIN_BLOCKING];
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
    return self.url;
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
