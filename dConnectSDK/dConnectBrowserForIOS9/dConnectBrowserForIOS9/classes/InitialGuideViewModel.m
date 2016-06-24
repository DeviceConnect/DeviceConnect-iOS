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
    }
    return self;
}


- (GuideDataViewController*)viewControllerAtIndex:(NSInteger)index
{
    return [GuideDataViewController instantiateWithFilename: [self.datasource objectAtIndex: index]];
}
@end
