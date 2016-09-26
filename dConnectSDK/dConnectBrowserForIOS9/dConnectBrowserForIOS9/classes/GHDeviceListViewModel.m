//
//  GHDeviceListViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHDeviceListViewModel.h"
#import "GHDeviceUtil.h"

@implementation GHDeviceListViewModel

- (void)fetchDevices:(void (^)(DConnectArray *deviceList))completion
{
    if([GHDeviceUtil shareManager].currentDevices.count == 0) {
        [[GHDeviceUtil shareManager] discoverDevices:^(DConnectArray *result) {
            if (completion) {
                completion(result);
            }
        }];
    } else {
        if (completion) {
            completion([GHDeviceUtil shareManager].currentDevices);
        }
    }
}

- (void)setup
{
    if(self.datasource == nil){
        self.datasource = [[NSMutableArray alloc]init];
    }
    [self.datasource removeAllObjects];

    __weak GHDeviceListViewModel* _self = self;
    [self fetchDevices:^(DConnectArray *deviceList) {
        [_self updateDatasource:deviceList];
    }];
}

- (void)refresh
{
    __weak GHDeviceListViewModel* _self = self;
    [[GHDeviceUtil shareManager] discoverDevices:^(DConnectArray *result) {
        [_self updateDatasource:result];
    }];
    [self.delegate startReloadDeviceList];
}

- (void)updateDatasource:(DConnectArray*)deviceList
{
    [self.datasource removeAllObjects];
    for (int i = 0; i < [deviceList count]; i++) {
        DConnectMessage *service = [deviceList messageAtIndex: i];
        [self.datasource addObject:service];
    }
    [self.delegate finishReloadDeviceList];
}

@end
