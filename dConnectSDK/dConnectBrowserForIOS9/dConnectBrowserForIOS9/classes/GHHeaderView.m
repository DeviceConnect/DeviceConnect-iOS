//
//  GHHeaderView.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHHeaderView.h"
@interface GHHeaderView()
{
    ///ローディング中か判断フラグ
    BOOL isLoading;
}
@end

@implementation GHHeaderView

#define HEIGHT 44

//--------------------------------------------------------------//
#pragma mark - UI
//--------------------------------------------------------------//
- (void)awakeFromNib
{
    [super awakeFromNib];
    isLoading = NO;

    //画像角丸
    CALayer *layer = self.urlLabel.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 5.0f;
    
    self.urlLabel.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];

    _searchBar.placeholder = @"Web検索/サイト名を入力";
    _searchBar.keyboardType = UIKeyboardTypeDefault;
    _searchBar.delegate = self;
    
    //タップセット
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTaped:)];
    tap.numberOfTapsRequired = 1;
    [self.urlLabel addGestureRecognizer:tap];
}

- (void)updateURL:(NSString*)urlStr
{
    if (![urlStr isEqualToString:@"about:blank"]) {
        self.urlLabel.text  = urlStr;
        self.searchBar.text = urlStr;
    }
}

- (void)setSearchShow:(BOOL)isShow
{
    if (isShow) {
        self.urlLabel.hidden   = YES;
        self.reloadbtn.hidden  = NO;
        self.searchBar.hidden  = NO;
        self.reloadbtn.enabled = YES;
    }else{
        self.urlLabel.hidden   = NO;
        self.reloadbtn.hidden  = NO;
        self.searchBar.hidden  = YES;
        self.reloadbtn.enabled = YES;
    }
}

//--------------------------------------------------------------//
#pragma mark - 更新ボタンまたはキャンセル
//--------------------------------------------------------------//
- (IBAction)reload:(UIButton*)sender
{
    LOG_METHOD
    if (isLoading) {
        if ([self.delegate respondsToSelector:@selector(cancelLoading)]) {
            [self.delegate cancelLoading];
            isLoading = NO;
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(reload)]) {
            [self.delegate reload];
             isLoading = YES;
        }
    }
}

//--------------------------------------------------------------//
#pragma mark - ボタンの変更
//--------------------------------------------------------------//
- (void)setReloadBtn:(BOOL)isReload
{
    isLoading = !isReload;
}

- (void)didTaped:(UIGestureRecognizer*)gest
{
    [self.searchBar becomeFirstResponder];
}

//--------------------------------------------------------------//
#pragma mark - searchBar delegate
//--------------------------------------------------------------//
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.text = self.urlLabel.text;
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
