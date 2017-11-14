//
//  DPHitoeWarningDialog.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeWarningDialog.h"
#import "DPHitoeConsts.h"
NSString *const DPHitoeWarningNever = @"IS_WARNING_HITOE";
static void (^okCallback)(void);
static BOOL isChecked = NO;
@interface DPHitoeWarning : UIWindow

@end

@implementation DPHitoeWarning
@end
@interface DPHitoeWarningDialog ()
@property (weak, nonatomic) IBOutlet UIButton *nextAbridgement;
@property (weak, nonatomic) IBOutlet UIView *warningDialogView;

@end

@implementation DPHitoeWarningDialog

- (void)viewDidLoad {
    [super viewDidLoad];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(self.warningDialogView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onClose:(id)sender {
    [DPHitoeWarningDialog closeHitoeWarningpDialog];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:@(isChecked) forKey:DPHitoeWarningNever];
    [def synchronize];
    if (okCallback) {
        okCallback();
    }
}
- (IBAction)onCheck:(id)sender {
    isChecked = !isChecked;
    [self.nextAbridgement setSelected:isChecked];
}

+ (void)showHitoeWarningDialogWithComplition:(void(^)(void))completion  {
    NSString *bundleName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bundleName = @"HitoeWarningDialog_iPhone";
    } else {
        bundleName = @"HitoeWarningDialog_iPad";
    }
    
    [super doShowForWindow:[[DPHitoeWarning alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:bundleName];
    okCallback = completion;
}

+(void)closeHitoeWarningpDialog {
    [super doClose];
}

@end
