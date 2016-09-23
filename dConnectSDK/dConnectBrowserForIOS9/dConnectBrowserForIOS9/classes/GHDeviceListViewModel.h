//
//  GHDeviceListViewModel.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@protocol GHDeviceListViewModelDelegate <NSObject>
- (void)startReloadDeviceList;
- (void)finishReloadDeviceList;
@end

@interface GHDeviceListViewModel : NSObject
@property (strong, nonatomic) NSMutableArray* datasource;
@property (nonatomic, weak) id<GHDeviceListViewModelDelegate> delegate;
- (void)setup;
- (void)refresh;
@end
