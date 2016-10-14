//
//  DPLinkingDeviceListViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceListViewController.h"
#import "DPLinkingDeviceViewController.h"
#import "DPLinkingDeviceManager.h"
#import "DPLinkingBeaconManager.h"

@interface DPLinkingDeviceListViewController () <DPLinkingDeviceConnectDelegate>

@property (nonatomic) DPLinkingDeviceManager *deviceManager;
@property (nonatomic) DPLinkingBeaconManager *beaconManager;

@property (nonatomic) UIAlertController *connectingAlert;

@property (nonatomic) UISwitch *deviceStatusSwitch;
@property (nonatomic) IBOutlet UIView *warningView;

@end

@implementation DPLinkingDeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deviceManager = [DPLinkingDeviceManager sharedInstance];
    [self.deviceManager startScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    
    [self.deviceManager addConnectDelegate:self];
    
    if ([self.deviceManager getDPLinkingDevices].count > 0) {
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.deviceManager removeConnectDelegate:self];
}

#pragma mark - Private Method

- (void) openConnectingDialog {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
    UIViewController* viewCtl = [storyboard instantiateViewControllerWithIdentifier:@"pairing_alert"];
    self.connectingAlert = [UIAlertController alertControllerWithTitle:nil
                                                            message:nil
                                                     preferredStyle:UIAlertControllerStyleAlert];
    [self.connectingAlert setValue:viewCtl forKey:@"contentViewController"];;
    [self presentViewController:self.connectingAlert animated:YES completion:nil];
}

- (void) closeConnectingDialog {
    if (self.connectingAlert) {
        [self.connectingAlert dismissViewControllerAnimated:YES completion:nil];
        self.connectingAlert = nil;
    }
}

- (void) openConfirmRemoveDeviceDialog:(NSIndexPath *)indexPath {
    __block DPLinkingDeviceListViewController *_self = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"削除"
                                                                   message:@"デバイスを削除して良いですか？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [_self.deviceManager removeDPLinkingDeviceAtIndex:(int)indexPath.row];
        [_self.tableView deleteRowsAtIndexPaths:@[indexPath]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openErrorDialogWithString:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openErrorDialog {
    [self openErrorDialogWithString:@"ペアリングされていません。"];
}

- (void) openErrorConnectDialog {
    [self openErrorDialogWithString:@"ペアリングに失敗しました。"];
}

#pragma mark - DPLinkingDeviceConnectDelegate

- (void) didConnectedDevice:(DPLinkingDevice *)device {
    [self closeConnectingDialog];
}

- (void) didFailToConnectDevice:(DPLinkingDevice *)device {
    [self closeConnectingDialog];
    [self openErrorConnectDialog];
    self.deviceStatusSwitch.on = NO;
}

- (void) didRemovedDeviceAll {
    __block DPLinkingDeviceListViewController *_self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_self.tableView reloadData];
    });
}

#pragma mark - IBAction Switch

- (UITableViewCell *) getUITableViewCell:(UIView *) view {
    while (view) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            return (UITableViewCell *) view;
        }
        view  = [view superview];
    }
    return nil;
}

- (IBAction) switchDeviceStatus:(UISwitch *) sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:[self getUITableViewCell:sender]];
    
    BOOL online = sender.on;
    DPLinkingDevice *device = [[self.deviceManager getDPLinkingDevices] objectAtIndex:indexPath.row];
    if (online && !device.online) {
        [self openConnectingDialog];
        [self.deviceManager connectDPLinkingDevice:device];
    } else if (!online && device.online) {
        [self.deviceManager disconnectDPLinkingDevice:device];
    }
    
    self.deviceStatusSwitch = sender;
}

- (IBAction) buttonLinkingDeviceSearch:(id)sender {
    UINavigationController *p = self.navigationController;
    UIViewController *a = p.topViewController;
    [a performSegueWithIdentifier:@"search_linking_device" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.deviceManager getDPLinkingDevices].count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchDeviceCell"];
    cell.layoutMargins = UIEdgeInsetsZero;

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:2];
    UISwitch *switchStatus = (UISwitch *)[cell viewWithTag:3];
    DPLinkingDevice *device = [[self.deviceManager getDPLinkingDevices] objectAtIndex:indexPath.row];
    nameLabel.text = device.name;
    addressLabel.text = device.identifier;
    switchStatus.on = device.online;
    [switchStatus addTarget:self action:@selector(switchDeviceStatus:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DPLinkingDevice *device = [[self.deviceManager getDPLinkingDevices] objectAtIndex:indexPath.row];
    if (device.online) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
        DPLinkingDeviceViewController* viewCtl = [storyboard instantiateViewControllerWithIdentifier:@"device_controller"];
        viewCtl.deviceManager = self.deviceManager;
        viewCtl.device = device;
        [self.navigationController pushViewController:viewCtl animated:YES];
    } else {
        [self openErrorDialog];
    }
}

- (NSArray *) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block DPLinkingDeviceListViewController *_self = self;
    return @[
             [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                title:@"削除"
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                  [_self openConfirmRemoveDeviceDialog:indexPath];
                                              }],
             ];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

@end
