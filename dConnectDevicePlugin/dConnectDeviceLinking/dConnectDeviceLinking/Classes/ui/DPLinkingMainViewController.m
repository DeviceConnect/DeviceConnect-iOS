//
//  DPLinkingMainViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingMainViewController.h"
#import "DPLinkingDeviceManager.h"

@interface DPLinkingMainViewController () <UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic) IBOutlet UITabBarItem *item0;
@property (nonatomic) IBOutlet UITabBarItem *item1;


@end

@implementation DPLinkingMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    
    [UITabBar appearance].translucent = NO;
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    
    NSDictionary *selectedAttributes = @{NSFontAttributeName : font,
                                         NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [[UITabBarItem appearance] setTitleTextAttributes:selectedAttributes
                                             forState:UIControlStateSelected];
    
    NSDictionary *attributesNormal = @{NSFontAttributeName : font,
                                       NSForegroundColorAttributeName : [UIColor grayColor]};
    
    [[UITabBarItem appearance] setTitleTextAttributes:attributesNormal
                                             forState:UIControlStateNormal];

    self.navigationItem.title = @"Linkingデバイス一覧";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) openConfirmRemoveDeviceDialog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"削除"
                                                                   message:@"デバイスを全て削除して良いですか？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[DPLinkingDeviceManager sharedInstance] removeAllDPLinkingDevice];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UIAdaptivePresentationControllerDelegate

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark - IBAction

- (IBAction)closeButtonTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingButtonTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
    UIViewController* viewCtl = [storyboard instantiateViewControllerWithIdentifier:@"popover_sample"];
    
    viewCtl.modalPresentationStyle = UIModalPresentationPopover;
    viewCtl.preferredContentSize = CGSizeMake(200, 100);
        
    UIPopoverPresentationController *presentationController = viewCtl.popoverPresentationController;
    presentationController.delegate = self;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.barButtonItem = sender;
    presentationController.sourceView = self.view;

    [self presentViewController:viewCtl animated:YES completion:nil];
}

@end
