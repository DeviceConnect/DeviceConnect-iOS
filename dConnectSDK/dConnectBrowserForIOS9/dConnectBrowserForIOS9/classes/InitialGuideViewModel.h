//
//  InitialGuideViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideDataViewController.h"

@protocol InitialGuideViewModelDelegate
- (void)closeWindow;
@end

@interface InitialGuideViewModel : NSObject

@property (nonatomic, strong) NSArray* datasource;
@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic, weak) id<InitialGuideViewModelDelegate> delegate;

- (GuideDataViewController*)viewControllerAtIndex:(NSInteger)index;
- (GuideDataViewController*)makeViewController:(NSInteger)index;

@end


