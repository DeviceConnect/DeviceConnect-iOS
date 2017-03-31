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
    
    // 接続状態を確認
    [self checkConnectSonyCamera];
    
    // デリゲートを設定
    self.deviceplugin.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
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


- (void) checkConnectSonyCamera {
    if (![self.deviceplugin isConnectedSonyCamera]) {
        self.ssidLabel.text = @"Not Found Sony Camera.";
    } else {
        self.ssidLabel.text = @"Sony Camera Connected.";
    }
}

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
    [self confirmOpenWiFiSettings];
}

#pragma mark - SonyCameraDevicePluginDelegate delegate methods

- (void) didReceiveDeviceList:(BOOL) discovery
{
    if (discovery) {
        self.ssidLabel.text = @"Sony Camera Connected.";
    } else {
        self.ssidLabel.text = @"Not Found Sony Camera.";
    }
    self.progressView.hidden = YES;
    [self.indicator stopAnimating];
}

- (void) didReceiveUpdateDevice
{
    [self checkConnectSonyCamera];
}

@end
