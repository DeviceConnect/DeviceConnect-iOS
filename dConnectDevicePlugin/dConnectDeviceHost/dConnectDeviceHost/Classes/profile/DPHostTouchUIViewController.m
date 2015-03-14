//
//  DPHostTouchUIViewController.m
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostTouchUIViewController.h"

@interface DPHostTouchUIViewController () {
    BOOL _isInitialize;
}


@property (unsafe_unretained, nonatomic) IBOutlet UILabel *HostTouchViewLavel;
@property (weak, nonatomic) IBOutlet UIButton *TouchViewCloseButton;
@end

@implementation DPHostTouchUIViewController

- (IBAction)actionUpTouchViewCloseButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isInitialize = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isInitialize = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end