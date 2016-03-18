//
//  DPIRKitVirtualDeviceCreateDialog.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitVirtualDeviceCreateDialog.h"
#import <objc/runtime.h>
#import "DPIRKitConst.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitVirtualDevice.h"

static NSString *_DPIRKitVirtualDeviceServiceId;
static NSString *_DPIRKitVirtualDeviceCategory;

@interface DPIRKitVirtualDeviceCreateDialog ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *serviceIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@end

@interface DPIRKitVirtualDeviceCreate : UIWindow

@end

@implementation DPIRKitVirtualDeviceCreate

-(void)dealloc
{
}

@end

@implementation DPIRKitVirtualDeviceCreateDialog
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 3.;
    };
    
    roundCorner(self.containerView);
    roundCorner(self.closeButton);
    roundCorner(self.createButton);
    _deviceNameTextField.text = _DPIRKitVirtualDeviceCategory;
    _serviceIdLabel.text = [NSString stringWithFormat:@"%@.%@", _DPIRKitVirtualDeviceServiceId, [[NSUUID UUID] UUIDString]];
    _categoryLabel.text = _DPIRKitVirtualDeviceCategory;
    // 背景をキリックしたら、キーボードを隠す
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeSoftKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [self.containerView addGestureRecognizer:gestureRecognizer];
    _deviceNameTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_deviceNameTextField resignFirstResponder];
    return YES;
}

- (void)closeSoftKeyboard {
    [_deviceNameTextField resignFirstResponder];
}

+ (void)showWithServiceId:(NSString*)serviceId
                 categoryName:(NSString*)categoryName {
    _DPIRKitVirtualDeviceServiceId = serviceId;
    _DPIRKitVirtualDeviceCategory = categoryName;
    [super doShowForWindow:[[DPIRKitVirtualDeviceCreate alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:@"VirtualDeviceCreateDialog"];
}
- (IBAction)createVirtualDevice:(id)sender {
    DPIRKitVirtualDevice *device = [DPIRKitVirtualDevice new];
    device.serviceId = _serviceIdLabel.text;
    device.deviceName = _deviceNameTextField.text;
    device.categoryName = _categoryLabel.text;
    BOOL isVirtualDeviceInsert = [[DPIRKitDBManager sharedInstance] insertVirtualDeviceWithData:device];
    BOOL isProfilesInsert = [[DPIRKitDBManager sharedInstance] insertRESTfulRequestWithDevice:device];
    if (isVirtualDeviceInsert && isProfilesInsert) {
        [self showAlertWithTitle:@"デバイスの登録" message:@"デバイスの登録が完了しました。"];
    } else {
        [self showAlertWithTitle:@"デバイスの登録失敗" message:@"デバイスの登録が失敗しました。"];
    }
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [DPIRKitDialog doClose];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)cancelCreateDevice:(id)sender {
    [DPIRKitDialog doClose];
}
@end
