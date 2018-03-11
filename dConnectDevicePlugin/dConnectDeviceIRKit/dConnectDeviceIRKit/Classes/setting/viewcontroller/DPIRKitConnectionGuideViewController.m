//
//  DPIRKitConnectionGuideViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitConnectionGuideViewController.h"
#import "DPIRKit_irkit.h"
#import "DPIRKitWiFiUtil.h"
#import "DPIRKitConst.h"

typedef NS_ENUM(NSUInteger, DPIRKitConnectionState) {
    DPIRKitConnectionStateIdling = 0,
    DPIRKitConnectionStateConnectingToIRKit,
    DPIRKitConnectionStateWaitingForLAN,
    DPIRKitConnectionStateConnected,
};

@interface DPIRKitConnectionGuideViewController ()
{
    DPIRKitConnectionState _state;
    NSString *_serviceId;
    NSString *_deviceKey;
    NSString *_clientKey;
    NSBundle *_bundle;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indView;
- (IBAction)sendButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *indBackView;


- (void) startLoading;
- (void) stopLoading;

- (void) showAlertWithTileKey:(NSString *)titleKey
                  messsageKey:(NSString *)messageKey
               closeButtonKey:(NSString *)closeButtonKey;
- (void) enterForeground;

@end

@implementation DPIRKitConnectionGuideViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _indBackView.hidden = YES;
    _indView.hidden = YES;
    _state = DPIRKitConnectionStateIdling;
    _bundle = DPIRBundle();
}

// 送信ボタンイベント
- (IBAction)sendButtonPressed:(id)sender
{
    _sendButton.enabled = NO;
    __weak typeof(self) _self = self;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ssid = [userDefaults stringForKey:DPIRKitUDKeySSID];
    DPIRKitWiFiSecurityType type = [userDefaults integerForKey:DPIRKitUDKeySecType];
    NSString *password = [userDefaults stringForKey:DPIRKitUDKeyPassword];
    
    @synchronized (self) {
        _state = DPIRKitConnectionStateConnectingToIRKit;
    }
    
    [self startLoading];
    [[DPIRKitManager sharedInstance] connectIRKitToWiFiWithSSID:ssid
                                                       password:password
                                                   securityType:type
                                                      deviceKey:_deviceKey
                                                     completion:
     ^(BOOL success, DPIRKitConnectionErrorCode errorCode) {
         @synchronized (_self) {
             if (success) {
                 [_self showAlertWithTileKey:@"AlertTitleConnection"
                                 messsageKey:@"AlertMessageConnectedWithWiFi"
                              closeButtonKey:@"AlertBtnClose"];
             } else {
                 _state = DPIRKitConnectionStateIdling;
                 [_self showAlertWithTileKey:@"AlertTitleError"
                                 messsageKey:@"AlertMessageNetworkError"
                              closeButtonKey:@"AlertBtnClose"];
             }
         }
     }];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _serviceId = [userDefaults stringForKey:DPIRKitUDKeyServiceId];
    _deviceKey = [userDefaults stringForKey:DPIRKitUDKeyDeviceKey];
    _clientKey = [userDefaults stringForKey:DPIRKitUDKeyClientKey];
    
    UIApplication *application = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForeground)
                                                name:UIApplicationWillEnterForegroundNotification
                                              object:application];
}

- (void) viewDidDisappear:(BOOL)animated {
    UIApplication *application = [UIApplication sharedApplication];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:application];
}

- (void) enterForeground {
    
    @synchronized (self) {
        if (_state == DPIRKitConnectionStateWaitingForLAN) {
            __weak typeof(self) _self = self;
            [self startLoading];
            [[DPIRKitManager sharedInstance]
             checkIfIRKitIsConnectedToInternetWithClientKey:_clientKey
             serviceId:_serviceId
             completion:^(BOOL isConnected) {
                 if (isConnected) {
                     _state = DPIRKitConnectionStateConnected;
                     [_self showAlertWithTileKey:@"AlertTitleConnection"
                                     messsageKey:@"AlertMessageConnectedSuccess"
                                  closeButtonKey:@"AlertBtnClose"];
                     
                 } else {
                     _state = DPIRKitConnectionStateIdling;
                     [_self showAlertWithTileKey:@"AlertTitleError"
                                     messsageKey:@"AlertMessageNetworkError"
                                  closeButtonKey:@"AlertBtnClose"];
                 }
                 
             }];
        }
    }
    
}

#pragma mark - Private Methods

- (void) startLoading {
    _indBackView.hidden = NO;
    _indView.hidden = NO;
    [_indView startAnimating];
    [self setScrollEnable:NO];
}

- (void) stopLoading {
    _indBackView.hidden = YES;
    _indView.hidden = YES;
    [_indView stopAnimating];
    [self setScrollEnable:YES];
}

- (void) showAlertWithTileKey:(NSString *)titleKey
                  messsageKey:(NSString *)messageKey
               closeButtonKey:(NSString *)closeButtonKey
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:DPIRLocalizedString(_bundle, titleKey)
                                 message:DPIRLocalizedString(_bundle, messageKey)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) _self = self;
    UIAlertAction* closeButton = [UIAlertAction
                                actionWithTitle:DPIRLocalizedString(_bundle, closeButtonKey)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    @synchronized (_self) {
                                        if (_state == DPIRKitConnectionStateConnectingToIRKit) {
                                            _state = DPIRKitConnectionStateWaitingForLAN;
                                        } else if (_state == DPIRKitConnectionStateConnected) {
                                            [self dismissViewControllerAnimated:YES completion:^{
                                                [[DPIRKitManager sharedInstance] stopDetection];
                                                [[DPIRKitManager sharedInstance] startDetection];
                                            }];
                                        } else {
                                            _sendButton.enabled = YES;
                                        }
                                    }
                                }];
    
    [alert addAction:closeButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_self stopLoading];
        [_self presentViewController:alert animated:YES completion:nil];
    });
    
}
@end
