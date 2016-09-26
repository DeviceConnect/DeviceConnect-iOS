//
//  BookmarkIconViewCell.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
        if (image.size.height < 32) {
            weakSelf.iconImage.contentMode = UIViewContentModeCenter;
        } else {
            weakSelf.iconImage.contentMode = UIViewContentModeScaleAspectFit;
        }
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
        [self.viewModel updateOpenDate];
    }
    self.alpha = 1.0;
}

- (IBAction)didTouchDown:(UIButton *)sender {
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = 0.3;
    }];
}

- (IBAction)backNormal:(UIButton *)sender {
    self.alpha = 1.0;
}


- (void)dealloc
{
    self.didIconSelected = nil;
}
@end
