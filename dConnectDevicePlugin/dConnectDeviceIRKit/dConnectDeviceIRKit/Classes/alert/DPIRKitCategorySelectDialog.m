//
//  DPIRKitCategorySelectDialog.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPIRKitCategorySelectDialog.h"
#import "DPIRKitVirtualDeviceCreateDialog.h"
#import <objc/runtime.h>
#import "DPIRKitConst.h"

static NSString *_DPIRKitVirtualDeviceServiceId;

@interface DPIRKitCategorySelectDialog ()
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *closeButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *tvButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *lightButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *containerView;
- (IBAction)closeDialog:(id)sender;

- (IBAction)selectTVCategory:(id)sender;
- (IBAction)selectLightCategory:(id)sender;

@end

@interface DPIRKitCategorySelect : UIWindow

@end

@implementation DPIRKitCategorySelect

-(void)dealloc
{
}

@end

@implementation DPIRKitCategorySelectDialog

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
    roundCorner(self.tvButton);
    roundCorner(self.lightButton);

}

+ (void) showWithServiceId:(NSString*)serviceId {
    _DPIRKitVirtualDeviceServiceId = serviceId;
    [super doShowForWindow:[[DPIRKitCategorySelect alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:@"CategorySelectDialog"];
}
- (IBAction)closeDialog:(id)sender {
    [DPIRKitDialog doClose];
}

- (IBAction)selectTVCategory:(id)sender {
    [DPIRKitVirtualDeviceCreateDialog showWithServiceId:_DPIRKitVirtualDeviceServiceId
                                               categoryName:DPIRKitCategoryTV];
}

- (IBAction)selectLightCategory:(id)sender {
    [DPIRKitVirtualDeviceCreateDialog showWithServiceId:_DPIRKitVirtualDeviceServiceId
                                               categoryName:DPIRKitCategoryLight];
}
@end
