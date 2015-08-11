//
//  DPAllJoynSettingDetailLIFXViewController.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynSettingDetailLIFXViewController.h"


@interface DPAllJoynSettingDetailLIFXViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation DPAllJoynSettingDetailLIFXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    
    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(didImageTapped)];
    [_imageView setUserInteractionEnabled:YES];
    [_imageView addGestureRecognizer:tapRecognizer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)didImageTapped
{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url =
    [NSURL URLWithString:
     @"itms-apps://itunes.apple.com/app/lifx/id657758311?mt=8"];
    if ([app canOpenURL:url]) {
        [app openURL:url];
    } else {
        DCLogError(@"Could not open App Store URL.");
    }
}

@end
