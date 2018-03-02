//
//  GHSettingController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHSettingController.h"
#import "GHDataManager.h"
#import <DConnectSDK/DConnectSDK.h>
#import "GrayLabelCell.h"
#import "SwitchableCell.h"
#import "DetailableCell.h"
#import "GHDevicePluginTableViewController.h"

@interface GHSettingController ()
{
    GHSettingViewModel* viewModel;
}
@end


@implementation GHSettingController

//--------------------------------------------------------------//
#pragma mark - 初期化
//--------------------------------------------------------------//
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        viewModel = [[GHSettingViewModel alloc]init];
        viewModel.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    viewModel = nil;
}

//--------------------------------------------------------------//
#pragma mark - delegate
//--------------------------------------------------------------//
- (void)openDevicePluginList
{
    
    GHDevicePluginTableViewController* controller = [GHDevicePluginTableViewController instantiate];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)updateViews
{
    [self.tableView reloadData];
}
//--------------------------------------------------------------//
#pragma mark - view cycle
//--------------------------------------------------------------//
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"設定";
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
- (IBAction)close
{
    [viewModel updateSwitchState];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//--------------------------------------------------------------//
#pragma mark - スイッチのON/OFF
//--------------------------------------------------------------//
- (void)updateSwitch:(UISwitch*)sender
{
    //NOTE: SecurityCellTypeがタグとして設定されている
    SecurityCellType type = sender.tag;
    [viewModel updateSwitch:type switchState:sender.isOn];
}


//--------------------------------------------------------------//
#pragma mark - Table view data source
//--------------------------------------------------------------//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [viewModel.datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[viewModel.datasource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self configureCell:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [viewModel didSelectedRow:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

/**
 * セルの表示内容をセット
 * @param tableView 対象のtableView
 * @param indexPath indexPath
 */
- (UITableViewCell*)configureCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = [(NSNumber*)[[viewModel.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] integerValue];
    switch (indexPath.section) {
        case SectionTypeSetting:
        {
            GrayLabelCell *cell = (GrayLabelCell*)[tableView dequeueReusableCellWithIdentifier:@"GrayLabelCell"
                                                                                  forIndexPath:indexPath];
            switch(type) {
                case SettingCellTypeManagerUUID:
                    [cell.titleLabel setFont:[UIFont systemFontOfSize:11.0]] ;

                case SettingCellTypeManagerName:
                    cell.titleLabel.textColor = [UIColor blackColor];
                    break;
            }
            cell.titleLabel.text = [viewModel cellTitle: indexPath];
            return cell;
        }
            break;
        case SectionTypeDevice:
            return [self configureDetailCell:tableView atIndexPath: indexPath];
            break;
        case SectionTypeSecurity:
            switch (type) {
                case SecurityCellTypeDeleteAccessToken:
                case SecurityCellTypeOriginWhitelist:
                case SecurityCellTypeRootCertInstall:
                    return [self configureDetailCell:tableView atIndexPath: indexPath];
                    break;
                case SecurityCellTypeOriginBlock:
                case SecurityCellTypeLocalOAuth:
                case SecurityCellTypeOrigin:
                case SecurityCellTypeExternIP:
                case SecurityCellTypeAvailability:
                case SecurityCellTypeSSL:
                {
                    SwitchableCell *cell = (SwitchableCell*)[tableView dequeueReusableCellWithIdentifier:@"SwitchableCell"
                                                                                            forIndexPath:indexPath];
                    cell.titleLabel.text = [viewModel cellTitle: indexPath];
                    [cell.switchBtn addTarget:self action:@selector(updateSwitch:)
                             forControlEvents: UIControlEventValueChanged];
                    cell.switchBtn.tag = type; //NOTE: SecurityCellType
                    cell.indexPath = indexPath;
                    [cell.switchBtn setOn:[viewModel switchState:type] animated:NO];
                    return cell;
                }
                    break;
            }
            break;
    }
    return [[UITableViewCell alloc]init];
}

- (DetailableCell*)configureDetailCell:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    DetailableCell *cell = (DetailableCell*)[tableView dequeueReusableCellWithIdentifier:@"DetailableCell"
                                                                            forIndexPath:indexPath];
    cell.titleLabel.text = [viewModel cellTitle: indexPath];
    cell.indexPath = indexPath;
    return cell;
}

CGFloat headerHeight = 36.0;
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = [viewModel sectionTitle: section];
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = rect.size.width;
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, screenWidth, headerHeight)];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:16.0];

    UIView* header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, headerHeight)];
    [header addSubview:label];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

@end
