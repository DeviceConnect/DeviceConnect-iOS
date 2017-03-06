//
//  GHSettingViewModel.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
                              @(SettingCellTypePortNumber),
                              @(SettingCellTypeManagerName),
                              @(SettingCellTypeManagerUUID)],
                            @[@(DeviceCellTypeList)],
                            @[@(SecurityCellTypeAvailability),
                              @(SecurityCellTypeDeleteAccessToken),
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
    
    if (!address) {
        address = @"0.0.0.0";
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
                case SettingCellTypePortNumber:
                    return @"Port 4035";
                case SettingCellTypeManagerName:
                    return [NSString stringWithFormat:@"Name %@", [[DConnectManager sharedManager] managerName]];
                case SettingCellTypeManagerUUID:
                    return [NSString stringWithFormat:@"UUID %@", [[DConnectManager sharedManager] managerUUID]];
            }
            break;
        case SectionTypeDevice:
            return @"デバイスプラグイン";
            break;
        case SectionTypeSecurity:
            switch (type) {
                case SecurityCellTypeAvailability:
                    return @"Manager名の表示";
                case SecurityCellTypeDeleteAccessToken:
                    return @"アクセストークン削除";
                case SecurityCellTypeOriginWhitelist:
                    return @"Originホワイトリスト管理";
                case SecurityCellTypeOriginBlock:
                    return @"Originブロック機能";
                case SecurityCellTypeLocalOAuth:
                    return @"LocalAuth (ON/OFF)";
                case SecurityCellTypeOrigin:
                    return @"Origin (有効/無効)";
                case SecurityCellTypeExternIP:
                    return @"外部IPを許可 (有効/無効)";
            }
            break;
    }

    return @"";
}



- (void)updateSwitch:(SecurityCellType)type switchState:(BOOL)isOn
{
    switch (type) {
        case SecurityCellTypeAvailability:
            if (isOn) {
                [self checkShowManagerName];
            } else {
                [DConnectManager sharedManager].settings.useManagerName = NO;
            }
            break;
        case SecurityCellTypeOriginBlock:
            [DConnectManager sharedManager].settings.useOriginBlocking = isOn;
            break;
        case SecurityCellTypeLocalOAuth:
            [self checkOriginAndLocalOAuth:isOn type:type copmletion:^{
                [DConnectManager sharedManager].settings.useLocalOAuth = isOn;
            }];
            break;
        case SecurityCellTypeOrigin:
            [self checkOriginAndLocalOAuth:isOn type:type copmletion:^{
                [DConnectManager sharedManager].settings.useOriginEnable = isOn;
            }];
            break;
        case SecurityCellTypeExternIP:
            [DConnectManager sharedManager].settings.useExternalIP = isOn;
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
    [def setBool:settings.useOriginBlocking forKey:IS_ORIGIN_BLOCKING];
    [def setBool:settings.useLocalOAuth forKey:IS_USE_LOCALOAUTH];
    [def setBool:settings.useOriginEnable forKey:IS_ORIGIN_ENABLE];
    [def setBool:settings.useExternalIP forKey:IS_EXTERNAL_IP];
    [def setBool:settings.useManagerName forKey:IS_AVAILABILITY];
    [def synchronize];
}

- (void)didSelectedRow:(NSIndexPath *)indexPath
{
    NSInteger type = [(NSNumber*)[[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] integerValue];
    switch (indexPath.section) {
        case SectionTypeSetting:
            switch (type) {
                case SettingCellTypeManagerName:
                    [self changeManagerName];
                    break;
            }
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
            [DConnectManager sharedManager].settings.useOriginBlocking
              = [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_BLOCKING];
            return [DConnectManager sharedManager].settings.useOriginBlocking;
        case SecurityCellTypeLocalOAuth:
            [DConnectManager sharedManager].settings.useLocalOAuth
                    = [[NSUserDefaults standardUserDefaults] boolForKey:IS_USE_LOCALOAUTH];
            return [DConnectManager sharedManager].settings.useLocalOAuth;
        case SecurityCellTypeOrigin:
           [DConnectManager sharedManager].settings.useOriginEnable
             = [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_ENABLE];
            return [DConnectManager sharedManager].settings.useOriginEnable;
        case SecurityCellTypeExternIP:
            [DConnectManager sharedManager].settings.useExternalIP
                = [[NSUserDefaults standardUserDefaults] boolForKey:IS_EXTERNAL_IP];
            return [DConnectManager sharedManager].settings.useExternalIP;
        case SecurityCellTypeAvailability:
            [DConnectManager sharedManager].settings.useManagerName
            = [[NSUserDefaults standardUserDefaults] boolForKey:IS_AVAILABILITY];
            return [DConnectManager sharedManager].settings.useManagerName;

        default:
            break;
    }
    return NO;
}


/*!
 @brief OriginとLocalOAuthのチェック状態を確認する。
 @param[in] isOn YES:状態をONにするか。 NO:状態をOFFにするか。
 @param[in] type 設定項目
 @param[out] completion コールバックオブジェクト
 */
- (void)checkOriginAndLocalOAuth:(BOOL)isOn type:(int)type copmletion:(void (^)())completion
{
    if (type == SecurityCellTypeOrigin
        && [[NSUserDefaults standardUserDefaults] boolForKey:IS_USE_LOCALOAUTH]
        && [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_ENABLE]) {
        NSString *message = @"下記の機能がアプリのOriginを参照するため下記もOFFに切り替わります。\n- LocalOAuth\nよろしいですか？";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [DConnectManager sharedManager].settings.useLocalOAuth = isOn;
            [DConnectManager sharedManager].settings.useOriginEnable = isOn;
            [self updateSwitchState];
            if (self.delegate) {
                [self.delegate updateViews];
            }
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [DConnectManager sharedManager].settings.useOriginEnable = YES;
            [self updateSwitchState];
            if (self.delegate) {
                [self.delegate updateViews];
            }
        }]];
    
        [[self rootViewController] presentViewController:alertController animated:YES completion:nil];
    } else if (type == SecurityCellTypeLocalOAuth
               && ![[NSUserDefaults standardUserDefaults] boolForKey:IS_USE_LOCALOAUTH]
               && ![[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_ENABLE]) {
        NSString *message = @"本機能はアプリのOriginを参照するため、下記もONに切り替わります。\n- Origin(有効/無効)\nよろしいでしょうか？";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [DConnectManager sharedManager].settings.useLocalOAuth = isOn;
            [DConnectManager sharedManager].settings.useOriginEnable = isOn;
            [self updateSwitchState];
            if (self.delegate) {
                [self.delegate updateViews];
            }
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [DConnectManager sharedManager].settings.useLocalOAuth = NO;
            [self updateSwitchState];
            if (self.delegate) {
                [self.delegate updateViews];
            }
        }]];
        
        [[self rootViewController] presentViewController:alertController animated:YES completion:nil];
        
    } else {
        completion();
    }
}

- (void)checkShowManagerName
{
    NSString *message = @"AvailabilityAPIでManagerの名前を表示します。\n\nhttp://localhost:4035/gotapi/availability\nにより、Managerの名前が確認ダイアログなしで取得できるようになります。\n\n有効にしてもよろしいでしょうか？";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [DConnectManager sharedManager].settings.useManagerName = YES;
        [self updateSwitchState];
        if (self.delegate) {
            [self.delegate updateViews];
        }
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [DConnectManager sharedManager].settings.useManagerName = NO;
        [self updateSwitchState];
        if (self.delegate) {
            [self.delegate updateViews];
        }
    }]];
    [[self rootViewController] presentViewController:alertController animated:YES completion:nil];
    
}


/*!
 @brief Managerの名前を変更するためのダイアログを表示する。
 */
- (void)changeManagerName
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Device Connect Manager"
                                                                              message:@"名前を入力してください。"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.placeholder = @"Manager名";
        textField.text = [[DConnectManager sharedManager] managerName];
    }];
    UIAlertAction * cancelAction =
    [UIAlertAction actionWithTitle:@"キャンセル"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction * createAction =
    [UIAlertAction actionWithTitle:@"変更"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               UITextField * textField = alertController.textFields[0];
                               if (textField.text.length > 0) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[DConnectManager sharedManager] updateManagerName:textField.text];
                                       if (self.delegate) {
                                           [self.delegate updateViews];
                                       }
                                   });
                               }
                           }];

    [alertController addAction:createAction];
    
    [[self rootViewController] presentViewController:alertController animated:YES completion:nil];
}


/*!
 @brief 最前面のViewControllerを取得する。
 */
- (UIViewController*)rootViewController
{
    UIViewController *baseView = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (baseView.presentedViewController != nil && !baseView.presentedViewController.isBeingDismissed) {
        baseView = baseView.presentedViewController;
    }
    return baseView;
}

@end
