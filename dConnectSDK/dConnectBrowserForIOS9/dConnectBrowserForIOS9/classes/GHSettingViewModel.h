//
//  GHSettingViewModel.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <Foundation/Foundation.h>

@protocol GHSettingViewModelDelegate <NSObject>
- (void)openDevicePluginList;
- (void)updateSwitches;
@end

@interface GHSettingViewModel : NSObject

typedef NS_ENUM (NSInteger, SettingSectionType) {
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
};

@property (nonatomic, strong) NSArray* datasource;
@property (nonatomic, weak) id<GHSettingViewModelDelegate> delegate;

- (NSString*)sectionTitle:(NSInteger)section;
- (NSString*)cellTitle:(NSIndexPath *)indexPath;
- (void)updateSwitchState;
- (void)updateSwitch:(SecurityCellType)type switchState:(BOOL)isOn;
- (void)didSelectedRow:(NSIndexPath *)indexPath;
- (BOOL)switchState:(SecurityCellType)type;

@end
