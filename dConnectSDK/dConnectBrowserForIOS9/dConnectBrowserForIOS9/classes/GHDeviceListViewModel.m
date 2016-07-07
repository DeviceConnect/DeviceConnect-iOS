//
//  GHDeviceListViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/07.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHDeviceListViewModel.h"
#import "GHDeviceUtil.h"

@implementation GHDeviceListViewModel

- (void)fetchDevices:(void (^)(DConnectArray *deviceList))completion
{
    if([GHDeviceUtil shareManager].currentDevices.count == 0) {
        [[GHDeviceUtil shareManager] setRecieveDeviceList:^(DConnectArray *deviceList){
            if (completion) {
                completion(deviceList);
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
        for (int i = 0; i < [deviceList count]; i++) {
            DConnectMessage *service = [deviceList messageAtIndex: i];
            [_self.datasource addObject:service];
        }
        [_self.delegate requestDatasourceReload];
    }];
}

@end
