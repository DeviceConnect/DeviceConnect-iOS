//
//  GHDevicePluginDetailViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/08.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
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
