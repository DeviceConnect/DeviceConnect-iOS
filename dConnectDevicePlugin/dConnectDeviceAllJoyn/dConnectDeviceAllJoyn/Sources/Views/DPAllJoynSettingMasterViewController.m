//
//  DPAllJoynSettingMasterViewController.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynSettingMasterViewController.h"

@import AssetsLibrary;


@interface DPAllJoynSettingMasterViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButtonItem;

@end


@implementation DPAllJoynSettingMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Change the tint color of Back button.
    //
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // First view controller does not have Back button because it has no
    // previous view controller. So, add a custom Back button.
    //
    _backButtonItem.tintColor = [UIColor whiteColor];
    
    // TODO: Append a back arrow icon without ellipsizing title
//    NSBundle *bundle = DPAllJoynResourceBundle();
//    NSString *path = [bundle pathForResource:@"back-arrow@2x"
//                                      ofType:@"png"];
//    _backButtonItem.image = [UIImage imageWithContentsOfFile:path];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)didBackButtonItemTapped:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
