//
//  GHSettingViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/23.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHSettingViewModel.h"
#import <DConnectSDK/DConnectSDK.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "GHSettingController.h"

@implementation GHSettingViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.datasource = @[@[@(SettingCellTypeIpAddress),
                              @(SettingCellTypePortNumber)],
                            @[@(DeviceCellTypeList)],
                            @[@(SecurityCellTypeDeleteAccessToken),
                              @(SecurityCellTypeOriginWhitelist),
                              @(SecurityCellTypeOriginBlock),
                              @(SecurityCellTypeLocalOAuth),
                              @(SecurityCellTypeOrigin),
                              @(SecurityCellTypeExternIP)]
                            ];
    }

    return self;
}

- (NSString *)myIPAddress
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}


- (NSString*)sectionTitle:(NSInteger)section
{
    switch (section) {
        case SectionTypeSetting:
            return @"設定";
            break;
        case SectionTypeDevice:
            return @"デバイスプラグイン";
            break;
        case SectionTypeSecurity:
            return @"セキュリティ";
            break;
        default:
            return @"";
            break;
    }
}

- (NSString*)cellTitle:(NSIndexPath *)indexPath
{
    NSInteger type = [(NSNumber*)[[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] integerValue];
    switch (indexPath.section) {
        case SectionTypeSetting:
            switch (type) {
                case SettingCellTypeIpAddress:
                    return [NSString stringWithFormat: @"IP %@", [self myIPAddress]];
                    break;
                case SettingCellTypePortNumber:
                    return @"Port 4035";
                    break;
            }
            break;
        case SectionTypeDevice:
            return @"デバイスプラグイン";
            break;
        case SectionTypeSecurity:
            switch (type) {
                case SecurityCellTypeDeleteAccessToken:
                    return @"アクセストークン削除";
                    break;
                case SecurityCellTypeOriginWhitelist:
                    return @"Originホワイトリスト管理";
                    break;
                case SecurityCellTypeOriginBlock:
                    return @"Originブロック機能";
                    break;
                case SecurityCellTypeLocalOAuth:
                    return @"LocalAuth (ON/OFF)";
                    break;
                case SecurityCellTypeOrigin:
                    return @"Origin (有効/無効)";
                    break;
                case SecurityCellTypeExternIP:
                    return @"外部IPを許可 (有効/無効)";
                    break;
            }
            break;
    }

    return @"";
}


- (void)updateSwitch:(SecurityCellType)type switchState:(BOOL)isOn
{
    switch (type) {
        case SecurityCellTypeOriginBlock:
            [DConnectManager sharedManager].settings.useOriginBlocking = isOn;
            break;
        case SecurityCellTypeLocalOAuth:
            [DConnectManager sharedManager].settings.useLocalOAuth = isOn;
            break;
        case SecurityCellTypeOrigin:
            //TODO:
            break;
        case SecurityCellTypeExternIP:
            //TODO:
            break;
        default:
            break;
    }
}


///スイッチの状態を保存
- (void)updateSwitchState
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    DConnectSettings* settings = [DConnectManager sharedManager].settings;
    [def setObject:@(settings.useOriginBlocking) forKey:IS_ORIGIN_BLOCKING];
    [def setObject:@(settings.useLocalOAuth) forKey:IS_USE_LOCALOAUTH];
    [def synchronize];
}

- (void)didSelectedRow:(NSIndexPath *)indexPath
{
    NSInteger type = [(NSNumber*)[[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] integerValue];
    switch (indexPath.section) {
        case SectionTypeDevice:
            [self.delegate openDevicePluginList];
            break;
        case SectionTypeSecurity:
            switch (type) {
                case SecurityCellTypeDeleteAccessToken:
                    [DConnectUtil showAccessTokenList];
                    break;
                case SecurityCellTypeOriginWhitelist:
                    [DConnectUtil showOriginWhitelist];
                    break;
            }
            break;
    }
}


- (BOOL)switchState:(SecurityCellType)type
{
    switch (type) {
        case SecurityCellTypeOriginBlock:
            return [DConnectManager sharedManager].settings.useOriginBlocking;
            break;
        case SecurityCellTypeLocalOAuth:
            return [DConnectManager sharedManager].settings.useLocalOAuth;
            break;
        case SecurityCellTypeOrigin:
            //TODO:
            break;
        case SecurityCellTypeExternIP:
            //TODO:
            break;
        default:
            return NO;
            break;
    }
    return NO; //FIXME:
}

@end
