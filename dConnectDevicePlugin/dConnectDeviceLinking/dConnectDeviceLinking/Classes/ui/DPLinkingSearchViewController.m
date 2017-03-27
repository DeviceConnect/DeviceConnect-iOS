//
//  DPLinkingSearchViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingSearchViewController.h"
#import <LinkingLibrary/LinkingLibrary.h>

#import "DPLinkingDeviceManager.h"
#import "DPLinkingBeaconManager.h"

@interface DPLinkingSearchViewController () <DPLinkingDeviceConnectDelegate>

@property (nonatomic) NSMutableArray *devices;
@property (nonatomic) DPLinkingDeviceManager *deviceManager;
@property (nonatomic) DPLinkingBeaconManager *beaconManager;
@property (nonatomic) UIAlertController *pairingAlert;

@end


@implementation DPLinkingSearchViewController {
    int _disconnectCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.devices = [[NSMutableArray alloc] init];
    self.deviceManager = [DPLinkingDeviceManager sharedInstance];
    self.beaconManager = [DPLinkingBeaconManager sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [self startScan];
    [self.deviceManager addConnectDelegate:self];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self.deviceManager stopScan];
    [self.deviceManager removeConnectDelegate:self];
}

#pragma mark - Private Method

- (void) startScan {
    if (YES) {
//    if (![self.deviceManager isStartScan]) {
        [self.deviceManager startScan];
        
        __block DPLinkingSearchViewController *_self = self;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_self.deviceManager stopScan];
            
            if ([_self.devices count] == 0) {
                [_self openNotFoundErrorDialog];
            }
        });
    }
}

- (void) paringPeripheral:(CBPeripheral *)peripheral {
    DCLogInfo(@"paringPeripheral: %@", peripheral);
    
    _disconnectCount = 0;
    
    DPLinkingDevice *device = [self.deviceManager findDPLinkingDeviceByPeripheral:peripheral];
    if (device && device.online) {
        [self.deviceManager disconnectDPLinkingDevice:device];
    } else {
        device = [self.deviceManager createDPLinkingDevice:peripheral];
    }
    [self.deviceManager connectDPLinkingDevice:device];
}

- (BOOL) containsDPLinkingDevice:(CBPeripheral *)peripheral {
    DPLinkingDevice *device = [self.deviceManager findDPLinkingDeviceByPeripheral:peripheral];
    return device || [self.devices containsObject:peripheral];
}

- (void) openNotFoundErrorDialog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                   message:@"Linkingに対応するデバイスが見つかりませんでした。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openPairingDialog {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
    UIViewController* viewCtl = [storyboard instantiateViewControllerWithIdentifier:@"pairing_alert"];
    self.pairingAlert = [UIAlertController alertControllerWithTitle:nil
                                                            message:nil
                                                     preferredStyle:UIAlertControllerStyleAlert];
    [self.pairingAlert setValue:viewCtl forKey:@"contentViewController"];;
    [self presentViewController:self.pairingAlert animated:YES completion:nil];
}

- (void) closePairingDialog {
    if (self.pairingAlert) {
        [self.pairingAlert dismissViewControllerAnimated:YES completion:nil];
        self.pairingAlert = nil;
    }
}

- (void) openErrorDialog {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                   message:@"ペアリングに失敗しました。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openDialog {
    __block DPLinkingSearchViewController *_self = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ペアリング成功"
                                                                   message:@"ペアリングに成功しました。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

#pragma mark - IBAction Button

- (IBAction)searchLinkingDevice:(id)sender {
    [self startScan];
}

#pragma mark - DPLinkingDeviceConnectDelegate

- (void) didDiscoveryPeripheral:(CBPeripheral *)peripheral {
    if (![self containsDPLinkingDevice:peripheral]) {
        [self.devices addObject:peripheral];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void) didConnectedDevice:(DPLinkingDevice *)device {
    [self closePairingDialog];
    [self openDialog];
}

- (void) didFailToConnectDevice:(DPLinkingDevice *)device {
    [self closePairingDialog];
    [self openErrorDialog];
    [self.deviceManager removeDPLinkingDevice:device];
}

- (void) didDisonnectedDevice:(DPLinkingDevice *)device {
    _disconnectCount++;
    if (_disconnectCount > 5) {
        DCLogInfo(@"################## 接続失敗");
        [self.deviceManager disconnectDPLinkingDevice:device];
        [self.deviceManager removeDPLinkingDevice:device];
        [self closePairingDialog];
        [self openErrorDialog];
    }
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchDeviceCell"];
    cell.layoutMargins = UIEdgeInsetsZero;

    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:2];
    CBPeripheral *peripheral = [self.devices objectAtIndex:indexPath.row];
    if (![peripheral.name length]) {
        nameLabel.text = peripheral.identifier.UUIDString;
        addressLabel.text = @"";
    } else {
        nameLabel.text = peripheral.name;
        addressLabel.text = peripheral.identifier.UUIDString;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openPairingDialog];
    [self paringPeripheral:[self.devices objectAtIndex:indexPath.row]];
}

@end
