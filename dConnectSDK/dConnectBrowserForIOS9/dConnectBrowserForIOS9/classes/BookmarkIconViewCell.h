//
//  BookmarkIconViewCell.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UIKit/UIKit.h>
#import "BookmarkIconViewModel.h"

@interface BookmarkIconViewCell : UICollectionViewCell
typedef void (^DidIconSelected)(Page*);

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (strong, nonatomic) BookmarkIconViewModel *viewModel;
@property (copy, nonatomic) DidIconSelected didIconSelected;

- (void)setBookmark:(Page*)page;
- (void)setEnabled:(BOOL)isEnabled;
@end
