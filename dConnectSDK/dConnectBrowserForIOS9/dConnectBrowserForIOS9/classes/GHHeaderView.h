//
//  GHHeaderView.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "GHURLLabel.h"

@protocol GHHeaderViewDelegate <NSObject>
@optional
/**
 * 入力されたURLを渡す
 * @param urlStr 文字列
 */
- (void)urlUpadated:(NSString*)urlStr;

@end

@interface GHHeaderView : UIView<UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar      *searchBar;
@property (nonatomic, weak) IBOutlet UIButton         *reloadbtn;
@property (nonatomic, weak) IBOutlet id<GHHeaderViewDelegate>  delegate;


/**
 * URLを表示する
 * @param urlStr 表示する文字列
 */
- (void)updateURL:(NSString*)urlStr;

@end
