//
//  GHDevicePluginDetailViewModel.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface GHDevicePluginDetailViewModel : NSObject

typedef NS_ENUM (NSInteger, CellType) {
    CellTypeTypePlugin,
    CellTypeTypeHeaderSetting,
    CellTypeTypeSetting,
    CellTypeTypeHeaderProfile,
    CellTypeTypeProfile
};

@property (nonatomic, strong) NSArray* datasource;

- (instancetype)initWithPlugin:(NSDictionary*)plugin;
- (DConnectSystemProfile*)findSystemProfile;
@end
