//
//  BookmarkIconViewCell.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/17.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookmarkIconViewModel.h"

@interface BookmarkIconViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) BookmarkIconViewModel *viewModel;

- (void)setBookmark:(Page*)page;
- (void)setEnabled:(BOOL)isEnabled;
@end
