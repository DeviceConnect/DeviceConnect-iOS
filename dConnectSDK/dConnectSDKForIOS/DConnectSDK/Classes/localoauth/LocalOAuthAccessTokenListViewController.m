//
//  LocalOAuthAccessTokenListViewController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LocalOAuthAccessTokenListViewController.h"
#import "LocalOAuth2Main.h"
#import "LocalOAuthSQLiteToken.h"
#import "LocalOAuthScope.h"
#import "LocalOAuthAccessTokenDetailViewController.h"
#import "LocalOAuthScopeUtil.h"
#import <QuartzCore/QuartzCore.h>

@implementation LocalOAuthAccessTokenListCell

@end


@interface LocalOAuthAccessTokenListViewController () {
    
    /*! key */
    NSString *_key;
    
    /*! LocalOAuthインスタンス */
    LocalOAuth2Main *_oauth;
    
    /*! 全アクセストークンデータ(SQLiteToken)の配列 / null: アクセストークンなし */
    NSMutableArray *_accessTokens;
    
    /*!
     アクセストークン全削除ボタン押下時の確認AlertViewポインタ
     */
    UIAlertController *_accessTokenAllDeleteAlertView;
    
    /*!
     アクセストークン削除ボタン押下時の確認AlertViewポインタ
     */
    UIAlertController *_accessTokenDeleteAlertView;
    
    /*!
     アクセストークン削除ボタン押下時の対象データインデックス
     */
    NSUInteger _accessTokenDeleteAlertViewDataIndex;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *allRemoveBtn;

@property (weak, nonatomic) IBOutlet UIView *noTokenView;

/*!
 トークンを1件削除
 @param index トークンデータのiti
 */
- (void)deleteToken: (NSUInteger) index;

/**
 * アクセストークンを全て削除.
 */
- (void)deleteAllToken;

@end


@implementation LocalOAuthAccessTokenListViewController

- (void)setKey: (NSString *)key {
    _key = key;
}

#pragma mark - UIViewController Override

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.navigationController.view.layer.cornerRadius = 10;
        self.navigationController.view.superview.backgroundColor = [UIColor clearColor];
        self.view.superview.layer.cornerRadius = 10;
        self.view.superview.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* アクセストークンのインスタンスを取得 */
    _oauth = [LocalOAuth2Main sharedOAuthForKey: _key];
    
    /* アクセストークン一覧を読み込む */
    _accessTokens = [[_oauth allAccessTokens] mutableCopy];
    
    /* TableView準備 */
    _tableAccessTokenList.delegate = self;
    _tableAccessTokenList.dataSource = self;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TokenDetail"]) {
        LocalOAuthAccessTokenDetailViewController *controller =
        [segue destinationViewController];
        [controller setToken:(LocalOAuthSQLiteToken *)sender];
    }
}

/*!
 全削除ボタンが押されたときの処理
 */
- (IBAction)deleteAllAccessToken:(id)sender {
    
    NSBundle *bundle = DCBundle();
    
    _accessTokenAllDeleteAlertView = [UIAlertController
                                      alertControllerWithTitle:DCLocalizedString(bundle, @"alert_title_all_delete")
                                      message:DCLocalizedString(bundle, @"alert_message_all_delete")
                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:DCLocalizedString(bundle, @"alert_btn_delete")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    /* 全削除処理 */
                                    [self deleteAllToken];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:DCLocalizedString(bundle, @"alert_btn_cancel")
                               style:UIAlertActionStyleDefault
                               handler:nil];
    [_accessTokenAllDeleteAlertView addAction:yesButton];
    [_accessTokenAllDeleteAlertView addAction:noButton];
    UIViewController *top = nil;
    DCPutPresentedViewController(top);
    [top presentViewController:_accessTokenAllDeleteAlertView animated:YES completion:nil];
}

/*!
 閉じるボタンが押されたときの処理
 */
- (IBAction)closeViewController:(id)sender {
    // 閉じたあとにテーブルビューの処理が発生してクラッシュするのを防ぐため
    // デリゲートとデータソースを消しておく
    _tableAccessTokenList.delegate = nil;
    _tableAccessTokenList.dataSource = nil;
    _tableAccessTokenList.editing = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

/**
 * テーブルの行数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rowCount = 0;
    if (_accessTokens != nil) {
        rowCount = [_accessTokens count];
    }
    
    if (rowCount <= 0) {
        tableView.hidden = YES;
        _noTokenView.hidden = NO;
        _allRemoveBtn.enabled = NO;
    } else {
        _noTokenView.hidden = YES;
        _allRemoveBtn.enabled = YES;
    }
    
    return rowCount;
}

/**
 * 行に表示するデータ
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocalOAuthToken *token = nil;
    LocalOAuthSQLiteToken *sqliteToken = nil;
    if (_accessTokens != nil
        && indexPath.row < [_accessTokens count]) {
        token = [_accessTokens objectAtIndex: indexPath.row];
        if (token != nil) {
            sqliteToken = token.delegate;
        }
    }
    
    NSString *applicationName = @"";
    NSString *scopes = @"";
    
    if (sqliteToken != nil) {
        applicationName = [sqliteToken applicationName];
        NSArray *scope = [sqliteToken scope];
        if (scope != nil) {
            int scopeCount = [scope count];
            if (scopeCount == 1) {
                LocalOAuthScope *oauthScope = scope[0];
                scopes = [LocalOAuthScopeUtil displayScope: [oauthScope scope] devicePlugin: nil];
            } else if (scopeCount >= 2) {
                
                NSBundle *bundle = DCBundle();
                LocalOAuthScope *oauthScope = scope[0];
                scopes =
                    [NSString stringWithFormat:DCLocalizedString(bundle, @"token_list_scopes"),
                            [LocalOAuthScopeUtil displayScope:[oauthScope scope]
                                                 devicePlugin: nil],
                                                    (scopeCount - 1)];
            }
        }
    }
    
    /* セルに値を設定する */
    static NSString *CellIdentifier = @"tableCell";
    
    LocalOAuthAccessTokenListCell *cell =
            (LocalOAuthAccessTokenListCell *) [tableView
                                                dequeueReusableCellWithIdentifier:CellIdentifier
                                                                    forIndexPath:indexPath];
    
    // セルの値を設定
    cell.tableCellApplicationName.text = applicationName;
    cell.tableCellScopes.text = scopes;
    
    return cell;
}

/*!
 セルをタップしたときの処理
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocalOAuthToken *token = nil;
    LocalOAuthSQLiteToken *sqliteToken = nil;
    if (_accessTokens != nil && indexPath.row < [_accessTokens count]) {
        token = [_accessTokens objectAtIndex: indexPath.row];
        if (token != nil) {
            sqliteToken = token.delegate;
        }
    }
    
    if (sqliteToken != nil) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self performSegueWithIdentifier:@"TokenDetail" sender:sqliteToken];
    }
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteAtIndex:indexPath];
    }
}

/*!
 アクセストークン削除ボタン押下時の処理
 */
- (void) deleteAtIndex:(NSIndexPath *) indexPath {
    
    if (0 <= indexPath.row && indexPath.row < [_accessTokens count]) {
        
        LocalOAuthToken *token = [_accessTokens objectAtIndex: indexPath.row];
        LocalOAuthSQLiteToken *sqliteToken = token.delegate;
        
        NSBundle *bundle = DCBundle();
        
        _accessTokenDeleteAlertView = [UIAlertController
                                      alertControllerWithTitle:[sqliteToken applicationName]
                                      message:DCLocalizedString(bundle, @"alert_message_delete")
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:DCLocalizedString(bundle, @"alert_btn_delete")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        /* トークン削除 */
                                        [self deleteToken: indexPath.row];
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:DCLocalizedString(bundle, @"alert_btn_cancel")
                                   style:UIAlertActionStyleDefault
                                   handler:nil];
        [_accessTokenAllDeleteAlertView addAction:yesButton];
        [_accessTokenAllDeleteAlertView addAction:noButton];
        UIViewController *top = nil;
        DCPutPresentedViewController(top);
        [top presentViewController:_accessTokenAllDeleteAlertView animated:YES completion:nil];
    }
}

/*!
 トークンを1件削除
 @param index トークンデータのiti
 */
- (void)deleteToken: (NSUInteger) index {
    
    LocalOAuthToken *token = [_accessTokens objectAtIndex: _accessTokenDeleteAlertViewDataIndex];
    LocalOAuthSQLiteToken *sqliteToken = token.delegate;
    
    /* アクセストークン削除 */
    long long tokenId = [sqliteToken id_];
    [_oauth destroyAccessTokenByTokenId: tokenId];
    
    /* 配列から1件削除 */
    [_accessTokens removeObjectAtIndex: index];
    
    /* 表示更新 */
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableAccessTokenList reloadData];
    });
}

/**
 * アクセストークンを全て削除.
 */
- (void)deleteAllToken {
    
    /* アクセストークン削除 */
    [_oauth destroyAllAccessTokens];
    
    /* 配列から全件削除 */
    [_accessTokens removeAllObjects];
    
    /* 表示更新 */
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableAccessTokenList reloadData];
    });
}

@end
