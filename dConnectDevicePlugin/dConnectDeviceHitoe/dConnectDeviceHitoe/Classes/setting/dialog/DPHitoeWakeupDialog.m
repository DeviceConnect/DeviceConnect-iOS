//
//  DPHitoeWakeupDialog.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeWakeupDialog.h"
#import "DPHitoeConsts.h"


NSString *const DPHitoeWakeUpNever = @"IS_WAKEUP_HITOE";
static void (^okCallback)(void);
static BOOL isChecked = NO;
@interface DPHitoeWakeup : UIWindow

@end

@implementation DPHitoeWakeup
@end
@interface DPHitoeWakeupDialog ()
@property (weak, nonatomic) IBOutlet UIButton *nextAbridgement;
@property (weak, nonatomic) IBOutlet UIView *wakeupDialogView;

@end

@implementation DPHitoeWakeupDialog

- (void)viewDidLoad {
    [super viewDidLoad];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(self.wakeupDialogView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onClose:(id)sender {
    [DPHitoeWakeupDialog closeHitoeWakeupDialog];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:@(isChecked) forKey:DPHitoeWakeUpNever];
    [def synchronize];
    if (okCallback) {
        okCallback();
    }
}
- (IBAction)onCheck:(id)sender {
    isChecked = !isChecked;
    [self.nextAbridgement setSelected:isChecked];
}

+ (void)showHitoeWakeupDialogWithComplition:(void(^)(void))completion  {
    NSString *bundleName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bundleName = @"HitoeWakeupDialog_iPhone";
    } else {
        bundleName = @"HitoeWakeupDialog_iPad";
    }

    [super doShowForWindow:[[DPHitoeWakeup alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:bundleName];
    okCallback = completion;
}

+(void)closeHitoeWakeupDialog {
    [super doClose];
}
@end
