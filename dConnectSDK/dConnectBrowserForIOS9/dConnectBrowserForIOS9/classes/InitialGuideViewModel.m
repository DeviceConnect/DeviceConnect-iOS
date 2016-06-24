//
//  InitialGuideViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "InitialGuideViewModel.h"

@implementation InitialGuideViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.datasource = @[];
        _pageIndex = 0;
    }
    return self;
}

- (GuideDataViewController*)viewControllerAtIndex:(NSInteger)index
{
    if (index >= self.datasource.count || index < 0) {
        return nil;
    }
    _pageIndex = index;
    GuideDataViewController* controller = [GuideDataViewController instantiateWithFilename: [self.datasource objectAtIndex: _pageIndex]];
    [controller setCloseButtonEnabled: (_pageIndex == self.datasource.count - 1)];
    return controller;
}

@end
