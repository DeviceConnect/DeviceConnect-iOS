//
//  IconViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/17.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "BookmarkIconViewModel.h"
@interface BookmarkIconViewModel()
@end

@implementation BookmarkIconViewModel

static NSString* faviconURL = @"http://www.google.com/s2/favicons?domain=";
static NSString* touch_icon = @"apple-touch-icon.png";

/*
 * ブックマークアイコンイメージを取得。以下の順番で順次取得できるまで繰り返す
 * 1.apple-touch-icon.pngを取得 2.ファビコン 3.デフォルトアイコン
 * @param urlString 画像のurl
 * @param completion 取得結果
 */
- (void)bookmarkIconImage:(void (^)(UIImage*))completion
{
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
}

/*
 * 非同期で画像を取得しUIImageにして返す。エラーの場合はnil
 * @param urlString 画像のurl
 * @param completion 取得結果
 */
- (void)fetchImage:(NSString*)urlString completion:(void (^)(UIImage*))completion
{
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
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
 * @param urlString URL
 * @return apple-touch-iconのアドレス
 */
- (NSString*)makeTouchIconURL:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (url.host) {
        return [NSString stringWithFormat:@"%@://%@/%@", url.scheme, url.host, touch_icon];
    }
    return nil;
}

@end
