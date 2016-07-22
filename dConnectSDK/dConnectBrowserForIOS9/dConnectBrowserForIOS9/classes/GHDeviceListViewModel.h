//
//  GHDeviceListViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/07.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GHDeviceListViewModelDelegate <NSObject>
- (void)requestDatasourceReload;
@end

@interface GHDeviceListViewModel : NSObject
@property (strong, nonatomic) NSMutableArray* datasource;
@property (nonatomic, weak) id<GHDeviceListViewModelDelegate> delegate;
- (void)setup;
- (void)refresh;
@end
