//
//  DPHitoeProgressDialog.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHitoeProgressDialog.h"


@interface DPHitoeProgress : UIWindow

@end

@implementation DPHitoeProgress

-(void)dealloc
{
}

@end

@interface DPHitoeProgressDialog()
@property (unsafe_unretained, nonatomic) IBOutlet UIView *progressView;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;

@end

@implementation DPHitoeProgressDialog

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
        layer.cornerRadius = 5.;
    };
    
    roundCorner(self.progressView);
    _progressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_progressIndicator.layer setValue:[NSNumber numberWithFloat:1.39f] forKeyPath:@"transform.scale"];
    [_progressIndicator startAnimating];
}

- (void)dealloc {
    [_progressIndicator stopAnimating];
}

#pragma mark - public method

+(void)showProgressDialog {
    [super doShowForWindow:[[DPHitoeProgress alloc] initWithFrame:[UIScreen mainScreen].bounds]
            storyboardName:@"ProgressDialog"];

}

+(void)closeProgressDialog {
    [super doClose];
}

@end
