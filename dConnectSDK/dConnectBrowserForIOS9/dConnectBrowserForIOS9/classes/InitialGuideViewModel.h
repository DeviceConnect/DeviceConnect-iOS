//
//  InitialGuideViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideDataViewController.h"

@interface InitialGuideViewModel : NSObject

@property (nonatomic, strong) NSArray* datasource;
@property (nonatomic, readonly) NSUInteger pageIndex;

- (GuideDataViewController*)viewControllerAtIndex:(NSInteger)index;

@end
