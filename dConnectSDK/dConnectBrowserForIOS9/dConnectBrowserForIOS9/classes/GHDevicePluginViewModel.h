//
//  GHDevicePluginViewModel.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface GHDevicePluginViewModel : NSObject
@property (nonatomic, strong) NSArray* datasource;
- (NSDictionary*)makePlguinAndProfiles:(NSInteger)index;
- (NSDictionary*)makePlguinAndPlugins:(DConnectDevicePlugin*)plugin;
@end
