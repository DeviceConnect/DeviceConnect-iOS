//
//  GHDeviceListViewController.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHDeviceListViewController.h"

@interface GHDeviceListViewController ()

@end

@implementation GHDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"デバイス一覧";
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithTitle:@"閉じる"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = closeButton;
}

- (void)close:(UIBarButtonItem*)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
