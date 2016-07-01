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

@interface GHDeviceUtil : NSObject
@property (nonatomic, strong) NSString* accessToken;
- (void)setup;
- (void)discoverDevices:(DiscoverDeviceCompletion)completion;
@end
