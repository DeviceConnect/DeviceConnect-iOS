//
//  GHDevicePluginTableViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHDevicePluginTableViewController.h"
#import "GHDevicePluginViewModel.h"
#import "GHDevicePluginViewCell.h"
#import "GHDevicePluginDetailViewController.h"

@interface GHDevicePluginTableViewController ()
{
    GHDevicePluginViewModel* viewModel;
}
@end

@implementation GHDevicePluginTableViewController

+ (GHDevicePluginTableViewController*)instantiate
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DevicePlugin" bundle:[NSBundle mainBundle]];
    return (GHDevicePluginTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"GHDevicePluginTableViewController"];
}

//--------------------------------------------------------------//
#pragma mark - button
//--------------------------------------------------------------//
- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//--------------------------------------------------------------//
#pragma mark - view cycle
//--------------------------------------------------------------//
- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithTitle:@"閉じる"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    self.title = @"デバイスプラグイン";
    viewModel = [[GHDevicePluginViewModel alloc]init];
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

//--------------------------------------------------------------//
#pragma mark - tableViewDelegate
//--------------------------------------------------------------//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [viewModel.datasource count];
}

- (GHDevicePluginViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DConnectDevicePlugin* plugin = [viewModel.datasource objectAtIndex:indexPath.row];
    GHDevicePluginViewCell *cell = (GHDevicePluginViewCell*)[tableView dequeueReusableCellWithIdentifier:@"GHDevicePluginViewCell" forIndexPath:indexPath];
    [cell configureCell:plugin];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* plugin = [viewModel makePlguinAndProfiles:indexPath.row];
    GHDevicePluginDetailViewController *controller = [GHDevicePluginDetailViewController instantiateWithPlugin:plugin];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
