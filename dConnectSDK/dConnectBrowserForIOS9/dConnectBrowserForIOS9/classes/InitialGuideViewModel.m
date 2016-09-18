//
//  InitialGuideViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
    return [GuideDataViewController instantiateWithFilename: [self.datasource objectAtIndex: index]
                                            withPageNaumber: index];
}

@end
