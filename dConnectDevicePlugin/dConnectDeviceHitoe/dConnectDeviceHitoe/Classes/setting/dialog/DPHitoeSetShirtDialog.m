//
//  DPHitoeSetShirtDialog.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeSetShirtDialog.h"

static void (^okCallback)(void);

@interface DPHitoeSetShirt : UIWindow

@end

@implementation DPHitoeSetShirt
@end

@interface DPHitoeSetShirtDialog ()
@property (unsafe_unretained, nonatomic) IBOutlet UIView *hitoeShirtView;

@end

@implementation DPHitoeSetShirtDialog

- (void)viewDidLoad {
    [super viewDidLoad];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(self.hitoeShirtView);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)onClose:(id)sender {
    [DPHitoeDialog doClose];
    if (okCallback) {
        okCallback();
    }

}

+ (void)showHitoeSetShirtDialogWithComplition:(void(^)(void))completion {
    NSString *bundleName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bundleName = @"HitoeShirtDialog_iPhone";
    } else {
        bundleName = @"HitoeShirtDialog_iPad";
    }
    [super doShowForWindow:[[DPHitoeSetShirt alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:bundleName];
    okCallback = completion;
}
@end
