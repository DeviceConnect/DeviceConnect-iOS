//
//  SonyCameraSettingView04Controller.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraSettingView04Controller.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface SonyCameraSettingView04Controller ()

@end

@implementation SonyCameraSettingView04Controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 角丸にする
    self.searchBtn.layer.cornerRadius = 16;
    
    // Sony Cameraに接続されているかチェックする
    BOOL exist =[self.deviceplugin isConnectedSonyCamera];
    if (exist) {
        self.ssidLabel.text = @"Sony Camera Connected.";
    } else {
        self.ssidLabel.text = @"Not Found Sony Camera.";
    }
    
    // デリゲートを設定
    self.deviceplugin.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


// WiFi設定画面を開く確認を行う
- (void) confirmOpenWiFiSettings
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sonyカメラ設定"
                                                                   message:@"WiFi設定画面でSonyカメラに接続してください。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"閉じる" style:UIAlertActionStyleDefault handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"設定を開く" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
        [[UIApplication sharedApplication] openURL:url];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Action methods

- (IBAction) searchBtnDidPushed:(id)sender
{
    if (![self.deviceplugin isConnectedSonyCamera]) {
        [self confirmOpenWiFiSettings];
    } else {
        // viewDidLoadの時点ではデバイスを認識できておらずその後認識された場合は、
        // ボタンがタップされたタイミングでConnectedと表示する
        self.ssidLabel.text = @"Sony Camera Connected.";
    }
}

#pragma mark - SonyCameraDevicePluginDelegate delegate methods

- (void) didReceiveDeviceList:(BOOL) discovery
{
    if (discovery) {
        CFArrayRef interfaces = CNCopySupportedInterfaces();
        CFDictionaryRef dicRef = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(interfaces, 0));
        if (dicRef) {
            NSString *ssid = CFDictionaryGetValue(dicRef, kCNNetworkInfoKeySSID);
            self.ssidLabel.text = ssid;
            self.ssidLabel.text = @"Sony Camera Connected.";
        }
    } else {
        // 発見できず
        self.ssidLabel.text = @"Not Found Sony Camera.";
    }
    self.progressView.hidden = YES;
    [self.indicator stopAnimating];
}

@end
