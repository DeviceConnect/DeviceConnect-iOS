//
//  DPHitoePinCodeDialog.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoePinCodeDialog.h"



static void (^pinCodeCallback)(NSString *pinCode);
@interface DPHitoePinCode : UIWindow

@end

@implementation DPHitoePinCode
@end
@interface DPHitoePinCodeDialog ()
@property (weak, nonatomic) IBOutlet UITextField *pinCodeField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinDialogTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinDialogHeight;
@property (weak, nonatomic) IBOutlet UIView *pinCodeDialogView;

@end

@implementation DPHitoePinCodeDialog

- (void)viewDidLoad {
    [super viewDidLoad];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(self.pinCodeDialogView);

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillBeShown:)
                                                name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillBeHidden:)
                                                name:UIKeyboardWillHideNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)cancelBtn:(id)sender {
    [DPHitoePinCodeDialog closePinCodesDialog];
}
- (IBAction)okBtn:(id)sender {
    if (_pinCodeField.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"PINコードの入力"
                                                                                 message:@"PINコードを入力してください"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    if (pinCodeCallback) {
        pinCodeCallback(_pinCodeField.text);
    }

}

#pragma mark - public method

+(void)showPinCodeDialogWithCompletion:(void  (^)(NSString *pinCode))completion {
    [super doShowForWindow:[[DPHitoePinCode alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:@"PinCodeDialog"];
    pinCodeCallback = completion;
}

+(void)closePinCodesDialog {
    [super doClose];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
- (void)rotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self iphoneLayoutWithOrientation:toInterfaceOrientation];
    } else {
        [self ipadLayoutWithOrientation:toInterfaceOrientation];
    }
    [self.view setNeedsUpdateConstraints];
}

- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _pinDialogTop.constant = 20;
    } else {
        _pinDialogTop.constant = 146;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
}

#pragma mark - TextField

- (void)keyboardWillBeShown:(NSNotification*)notif
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft ||
         [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight))
    {
        _pinDialogTop.constant = 146 - (_pinDialogHeight.constant);
    } else {
        _pinDialogTop.constant = 146 - (_pinDialogHeight.constant / 2);
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)notif
{
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft ||
         [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight))
    {
        _pinDialogTop.constant = 20;
    } else {
        _pinDialogTop.constant = 146;
    }
}
@end
