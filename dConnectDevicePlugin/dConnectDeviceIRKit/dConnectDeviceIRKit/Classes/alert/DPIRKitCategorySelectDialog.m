//
//  DPIRKitCategorySelectDialog.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPIRKitCategorySelectDialog.h"
#import <objc/runtime.h>
#import "DPIRKitConst.h"

static const char kAssocKey_Window;

@interface DPIRKitCategorySelectDialog ()
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *closeButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *tvButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *lightButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *containerView;
@end

@interface DPIRKitCategorySelect : UIWindow

@end

@implementation DPIRKitCategorySelect

-(void)dealloc
{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
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

+ (void) show {
    [super doShowForWindow:[[DPIRKitCategorySelect alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:@"CategorySelectDialog"];
}
+ (void)close {
    [super doClose];
}
@end
