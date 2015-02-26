//
//  DPIRKitWiFiFormViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitWiFiFormViewController.h"
#import "DPIRKit_irkit.h"
#import "DPIRKitConst.h"
#import "DPIRKitWiFiUtil.h"

@interface DPIRKitWiFiFormViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ssidField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *secTypeFiled;

@end

@implementation DPIRKitWiFiFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *currentSSID = [DPIRKitWiFiUtil currentSSID];
    NSString *defaultSSID = (currentSSID != nil) ? currentSSID : @"";
    
    // 保存してある値を設定
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{
                           DPIRKitUDKeySecType: @(DPIRKitWiFiSecurityTypeWPA2),
                           DPIRKitUDKeySSID: defaultSSID
                           }
     ];
    
    _ssidField.text = [userDefaults stringForKey:DPIRKitUDKeySSID];
    _passwordField.text = [userDefaults stringForKey:DPIRKitUDKeyPassword];
    if ([userDefaults integerForKey:DPIRKitUDKeySecType] == DPIRKitWiFiSecurityTypeNone) {
        _secTypeFiled.selectedSegmentIndex = 0;
    } else if ([userDefaults integerForKey:DPIRKitUDKeySecType] == DPIRKitWiFiSecurityTypeWEP) {
        _secTypeFiled.selectedSegmentIndex = 1;
    } else {
        _secTypeFiled.selectedSegmentIndex = 2;
    }

}

- (void) viewWillDisappear:(BOOL)animated
{
    // 値を保存
    NSString *ssid = _ssidField.text ? _ssidField.text : @"";
    NSString *password = _passwordField.text ? _passwordField.text : @"";
    DPIRKitWiFiSecurityType type;
    switch (_secTypeFiled.selectedSegmentIndex) {
        case 2:
            type = DPIRKitWiFiSecurityTypeWPA2;
            break;
        case 1:
            type = DPIRKitWiFiSecurityTypeWEP;
            break;
        case 0:
        default:
            type = DPIRKitWiFiSecurityTypeNone;
            break;
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:ssid forKey:DPIRKitUDKeySSID];
    [userDefaults setInteger:type forKey:DPIRKitUDKeySecType];
    [userDefaults setObject:password forKey:DPIRKitUDKeyPassword];
    [userDefaults synchronize];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
