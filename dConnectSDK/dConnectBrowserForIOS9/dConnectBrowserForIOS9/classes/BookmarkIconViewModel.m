//
//  IconViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BookmarkIconViewModel.h"
#import "HTMLParser.h"
#import "GHDataManager.h"

@interface BookmarkIconViewModel()
{
    dispatch_queue_t q_global;
}
@end

@implementation BookmarkIconViewModel

static NSString* faviconURL = @"http://www.google.com/s2/favicons?domain=";
static NSString* touch_icon = @"apple-touch-icon.png";

- (instancetype)init
{
    self = [super init];
    if(self){
        q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}


/*
 * ブックマークアイコンイメージを取得。以下の順番で順次取得できるまで繰り返す
 * 1.apple-touch-icon.pngを取得 2.ファビコン 3.デフォルトアイコン
 * @param urlString 画像のurl
 * @param completion 取得結果
 */
- (void)bookmarkIconImage:(void (^)(UIImage*))completion
{
    dispatch_async(q_global, ^{
        [self fetchImage:[self makeTouchIconURL:self.page.url] completion:^(UIImage *image) {
            if (image) {
                completion(image);
            } else {
                [self fetchImage:[self makeFaviconURL:self.page.url] completion:^(UIImage *image) {
                    if (image) {
                        completion(image);
                    } else {
                        completion([UIImage imageNamed:@"no_bookmark_icon"]);
                    }
                }];
            }
        }];
    });
}

/*
 * 非同期で画像を取得しUIImageにして返す。エラーの場合はnil
 * @param urlString 画像のurl
 * @param completion 取得結果
 */
- (void)fetchImage:(NSString*)urlString completion:(void (^)(UIImage*))completion
{
    dispatch_async(q_global, ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: urlString]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    });
}

/*
 * Faviconのアドレスを作成
 * @param　urlString URL
 * @return Faviconのアドレス
 */
- (NSString*)makeFaviconURL:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (url.host) {
        return [faviconURL stringByAppendingString:url.host];
    }
    return nil;
}

/*
 * apple-touch-iconのアドレスを作成
 * HTMLをparseしてapple-touch-iconを探す
 * @param urlString URL
 * @return apple-touch-iconのアドレス
 */
- (NSString*)makeTouchIconURL:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (url.host) {
        NSData *htmlData = [NSData dataWithContentsOfURL:url];
        NSString *html = [[NSString alloc] initWithBytes:htmlData.bytes length:htmlData.length encoding:NSUTF8StringEncoding];

        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
        HTMLNode *headNode = [parser head];
        NSArray *aNodes = [headNode findChildTags:@"link"];
        NSMutableArray *results = [[NSMutableArray alloc]init];

        //<link rel=apple-touch-icon>
        for (HTMLNode *node in aNodes) {
            NSString* rel = [node getAttributeNamed:@"rel"];
            if ([rel hasPrefix:@"apple-touch-icon"]) {
                [results addObject: node];
            }
        }

        //<link rel=icon>
        for (HTMLNode *node in aNodes) {
            NSString* rel = [node getAttributeNamed:@"rel"];
            if ([rel containsString:@"icon"]) {
                [results addObject: node];
            }
        }

        for (HTMLNode *node in results) {
            NSString* path = [node getAttributeNamed:@"href"];
            NSURL* baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/", url.scheme, url.host]];
            NSURL *iconUrl = [[NSURL alloc]initWithString:path relativeToURL:baseURL];
            if (iconUrl) {
                return iconUrl.absoluteString;
            } else {
                return [self createURL:url path: path];
            }
        }

        return [self createURL:url path:touch_icon];
    }
    return nil;
}

- (NSString*)createURL:(NSURL*)url path:(NSString*)path {
    return [NSString stringWithFormat:@"%@://%@/%@", url.scheme, url.host, path];
}

- (void)updateOpenDate
{
    self.page.latest_opened_date = [NSDate date];
    [[GHDataManager shareManager]save];
}

@end
