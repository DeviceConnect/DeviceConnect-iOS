//
//  GHSettingViewModel.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/23.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHSettingViewModel.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

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
                              @(SecurityCellTypeExternIP),
                              @(SecurityCellTypeWebSocket)]
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

@end
