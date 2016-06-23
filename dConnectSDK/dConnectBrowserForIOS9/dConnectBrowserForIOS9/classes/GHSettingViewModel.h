//
//  GHSettingViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/23.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHSettingViewModel : NSObject

typedef NS_ENUM (NSInteger, SectionType) {
    SectionTypeSetting,
    SectionTypeDevice,
    SectionTypeSecurity
};

typedef NS_ENUM (NSInteger, SettingCellType) {
    SettingCellTypeIpAddress,
    SettingCellTypePortNumber
};

typedef NS_ENUM (NSInteger, DeviceCellType) {
    DeviceCellTypeList,
};

typedef NS_ENUM (NSInteger, SecurityCellType) {
    SecurityCellTypeDeleteAccessToken,
    SecurityCellTypeOriginWhitelist,
    SecurityCellTypeOriginBlock,
    SecurityCellTypeLocalOAuth,
    SecurityCellTypeOrigin,
    SecurityCellTypeExternIP,
    SecurityCellTypeWebSocket,
};

@property (nonatomic, strong) NSArray* datasource;

- (NSString*)sectionTitle:(NSInteger)section;

@end
