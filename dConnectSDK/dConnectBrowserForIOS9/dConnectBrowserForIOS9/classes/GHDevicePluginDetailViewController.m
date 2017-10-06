//
//  GHDevicePluginDetailViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "GHDevicePluginDetailViewController.h"
#import "GHDevicePluginDetailViewModel.h"
#import "GHDevicePluginViewCell.h"
#import "GHDeviceSettingButtonViewCell.h"
#import "GHDevicePluginSectionHeaderViewCell.h"
#import "GHDeviceProfileViewCell.h"

@interface GHDevicePluginDetailViewController ()
{
    GHDevicePluginDetailViewModel *viewModel;
}
@end

@implementation GHDevicePluginDetailViewController

+ (GHDevicePluginDetailViewController*)instantiateWithPlugin:(NSDictionary*)plugin
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DevicePlugin" bundle:[NSBundle mainBundle]];
    GHDevicePluginDetailViewController* controller = (GHDevicePluginDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"GHDevicePluginDetailViewController"];
    [controller setPlugin:plugin];
    return controller;
}

- (void)setPlugin:(NSDictionary*)plugin
{
    viewModel = [[GHDevicePluginDetailViewModel alloc]initWithPlugin:plugin];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    // デバイスプラグインの設定画面で、全体のナビゲーションバーの色を変えられた時のために、Browserデフォルトの色に戻す。
    self.navigationController.navigationBar.barTintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.tintColor =  [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].tintColor = [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    [UITabBar appearance].translucent = NO;
    [UITabBar appearance].barTintColor = [UIColor whiteColor];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000]];
}
- (void)openDevicePluginSetting
{
    DConnectSystemProfile *systemProfile = [viewModel findSystemProfile];
    if (systemProfile) {
        UIViewController* controller = [systemProfile.dataSource profile:nil settingPageForRequest:nil];
        if (controller) {
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"設定画面はありません" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

//--------------------------------------------------------------//
#pragma mark - tableViewDelegate
//--------------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [viewModel.datasource count];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSMutableArray*)[viewModel.datasource objectAtIndex:section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CellTypeTypePlugin:
        {
            DConnectDevicePlugin* plugin = (DConnectDevicePlugin*)[[viewModel.datasource objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
            GHDevicePluginViewCell *cell = (GHDevicePluginViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GHDevicePluginViewCell" forIndexPath:indexPath];
            [cell configureCell:plugin];
            return cell;
        }
            break;
        case CellTypeTypeSetting:
        {
            GHDeviceSettingButtonViewCell *cell = (GHDeviceSettingButtonViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GHDeviceSettingButtonViewCell" forIndexPath:indexPath];
            __weak GHDevicePluginDetailViewController *weakSelf = self;
            [cell setDidTappedSetting:^(){
                [weakSelf openDevicePluginSetting];
            }];
            return cell;
        }
            break;
        case CellTypeTypeProfile:
        {
            DConnectProfile* profile = (DConnectProfile*)[[viewModel.datasource objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
            GHDeviceProfileViewCell *cell = (GHDeviceProfileViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GHDeviceProfileViewCell" forIndexPath:indexPath];
            [cell configureCell:profile];
            return cell;
        }
            break;
        default:
        {
            GHDevicePluginSectionHeaderViewCell *header = (GHDevicePluginSectionHeaderViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GHDevicePluginSectionHeaderViewCell"];
            NSString* title;
            switch (indexPath.section) {
                case CellTypeTypeHeaderSetting:
                    title = @"設定";
                    break;
                case CellTypeTypeHeaderProfile:
                    title = @"プロファイル";
                    break;
            }
            header.titleLabel.text = title;
            return header;
        }
    }
}

@end
