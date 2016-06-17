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


@end
