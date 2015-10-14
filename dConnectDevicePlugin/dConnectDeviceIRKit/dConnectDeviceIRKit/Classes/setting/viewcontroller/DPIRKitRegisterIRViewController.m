//
//  DPIRKitRegisterIRViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitRegisterIRViewController.h"
#import "DPIRKitRESTfulRequest.h"
#import "DPIRKitManager.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitDevice.h"

@interface DPIRKitRegisterIRViewController () {
    DPIRKitRESTfulRequest *_virtualRequest;
}
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIView *indBackView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

- (IBAction)receiveIR:(id)sender;
@end

@implementation DPIRKitRegisterIRViewController
- (IBAction)closeDeviceSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景白
    self.view.backgroundColor = [UIColor whiteColor];
    // 閉じるボタン追加
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"＜ 一覧"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(popUIViewController:) ];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    NSRange range = [_virtualRequest.uri rangeOfString:@"tv"];
    if (range.location != NSNotFound) {
        title.text = @"TVプロファイル編集";
    } else {
        title.text = @"Lightプロファイル編集";
    }
    [title sizeToFit];
    self.navigationItem.titleView = title;
    _profileNameLabel.text = _virtualRequest.name;
}

- (IBAction)popUIViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDetailItem:(id)newDetailItem
{
    _virtualRequest = newDetailItem;
}

- (IBAction)receiveIR:(id)sender {
    _indBackView.hidden = NO;
    [_indicatorView startAnimating];
    
    NSArray *ids = [_virtualRequest.serviceId componentsSeparatedByString:@"."];
    DPIRKitManager *mgr = [DPIRKitManager sharedInstance];
    DPIRKitDevice *device = [mgr deviceForServiceId:ids[0]];
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), updateQueue, ^{
        [mgr fetchMessageWithHostName:device.hostName completion:^(NSString *message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSRange range = [message rangeOfString:@"{\"format\":\"raw\","];
                if (message && range.location != NSNotFound) {
                    _virtualRequest.ir = message;
                    BOOL isUpdateIR = [[DPIRKitDBManager sharedInstance] updateRESTfulRequest:_virtualRequest];
                    if (isUpdateIR) {
                        DPIRLog(@"ir:%@", message);
                        [self showAlertWithTitle:@"受信成功" message:@"正常に赤外線を受信しました。"];
                    } else {
                        [self showAlertWithTitle:@"受信失敗" message:@"赤外線の保存に失敗しました。"];
                    }
                } else {
                    [self showAlertWithTitle:@"受信失敗" message:@"赤外線の受信に失敗しました。"];
                }
                _indBackView.hidden = YES;
                [_indicatorView stopAnimating];
            });
        }];
    });
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // addActionした順に左から右にボタンが配置されます
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
