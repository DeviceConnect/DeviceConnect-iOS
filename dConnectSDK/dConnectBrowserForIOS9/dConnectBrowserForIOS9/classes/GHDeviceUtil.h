//
//  GHDeviceUtil.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

typedef void (^DiscoverDeviceCompletion)(DConnectArray *result);
typedef void (^RecieveDeviceList)(DConnectArray *deviceList);

@interface GHDeviceUtil : NSObject
@property (nonatomic, strong) DConnectArray* currentDevices;
@property (nonatomic, copy) RecieveDeviceList recieveDeviceList;
+ (GHDeviceUtil*)shareManager;
- (void)discoverDevices:(DiscoverDeviceCompletion)completion;
@end
