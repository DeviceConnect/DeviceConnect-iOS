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
        self.datasource = @[
                            @"guide01",
                            @"guide02",
                            @"guide03",
                            @"guide04",
                            @"guide05",
                            @"guide06",
                            @"guide07",
                            ];
    }
    return self;
}

- (GuideDataViewController*)viewControllerAtIndex:(NSInteger)index
{
    if (index >= self.datasource.count || index < 0) {
        return nil;
    }
    GuideDataViewController* controller = [self makeViewController: index];
    [controller setCloseButtonCallback:^{
        [_delegate closeWindow];
    }];
    return controller;
}


- (GuideDataViewController*)makeViewController:(NSInteger)index
{
    BOOL isLastPage = (index == self.datasource.count - 1);
    return [GuideDataViewController instantiateWithFilename: [self.datasource objectAtIndex: index]
                                            withPageNaumber: index
                                                 isLastPage: isLastPage];
}

@end
