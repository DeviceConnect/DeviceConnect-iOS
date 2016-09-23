//
//  InitialGuideViewModel.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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


