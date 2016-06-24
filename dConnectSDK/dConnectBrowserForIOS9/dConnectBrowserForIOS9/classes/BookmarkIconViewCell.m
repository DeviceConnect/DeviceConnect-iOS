//
//  BookmarkIconViewCell.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/17.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "BookmarkIconViewCell.h"

@implementation BookmarkIconViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.viewModel = [[BookmarkIconViewModel alloc]init];
    }
    return self;
}

- (void)layoutSubviews
{
    self.iconImage.layer.cornerRadius = 10;
    self.iconImage.clipsToBounds = YES;
}

- (void)setBookmark:(Page*)page
{
    self.iconImage.image = nil;
    self.viewModel.page = page;
    self.titleLabel.text = self.viewModel.page.title;

    __weak BookmarkIconViewCell* weakSelf = self;
    [self.viewModel bookmarkIconImage:^(UIImage *image) {
        weakSelf.iconImage.image = image;
    }];

    [self setEnabled:YES];
}

- (void)setEnabled:(BOOL)isEnabled
{
    self.iconImage.hidden = !isEnabled;
    self.titleLabel.hidden = !isEnabled;
    self.selectButton.enabled = isEnabled;
}


//--------------------------------------------------------------//
#pragma mark - ボタン制御
//--------------------------------------------------------------//
- (IBAction)didTapItem:(UIButton *)sender {
    if (self.viewModel.page != nil) {
        self.didIconSelected(self.viewModel.page);
    }
    self.alpha = 1.0;
}

- (IBAction)didTouchDown:(UIButton *)sender {
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0.3;
    }];
}


- (void)dealloc
{
    self.didIconSelected = nil;
}
@end
