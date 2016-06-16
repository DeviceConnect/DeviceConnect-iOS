//
//  GHHeaderView.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHHeaderView.h"

@implementation GHHeaderView

#define HEIGHT 44

//--------------------------------------------------------------//
#pragma mark - UI
//--------------------------------------------------------------//
- (void)awakeFromNib
{
    [super awakeFromNib];

    _searchBar.placeholder = @"Web検索/サイト名を入力";
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;

    // UISearchBarのサブビューの背景を透明にする
    for (UIView *subview in self.searchBar.subviews) {
        for(UIView *secondSubView in subview.subviews) {
            if ([secondSubView isKindOfClass:[UIImageView class]]) {
                [secondSubView removeFromSuperview];
            }

            // テキストフィールド部分を取得
            if ([secondSubView isKindOfClass:[UITextField class]]) {
                [(UITextField *)secondSubView setBackgroundColor:[UIColor whiteColor]];
            }
        }
    }
}

- (void)updateURL:(NSString*)urlStr
{
    if (![urlStr isEqualToString:@"about:blank"]) {
        self.searchBar.text = urlStr;
    }
}

- (void)setSearchShow:(BOOL)isShow
{
    if (isShow) {
        self.reloadbtn.hidden  = NO;
        self.searchBar.hidden  = NO;
        self.reloadbtn.enabled = YES;
    }else{
        self.reloadbtn.hidden  = NO;
        self.searchBar.hidden  = YES;
        self.reloadbtn.enabled = YES;
    }
}

//--------------------------------------------------------------//
#pragma mark - 更新ボタンまたはキャンセル
//--------------------------------------------------------------//
- (IBAction)search:(UIButton*)sender
{
    LOG_METHOD
    if ([self.delegate respondsToSelector:@selector(urlUpadated:)]) {
        [self.delegate urlUpadated:_searchBar.text];
    }
}


//--------------------------------------------------------------//
#pragma mark - searchBar delegate
//--------------------------------------------------------------//
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

///文字列からURLか検索キーワードか判別してwebviewに表示する
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(urlUpadated:)]) {
            [self.delegate urlUpadated:searchBar.text];
        }
    }

    [searchBar resignFirstResponder];
}

@end
