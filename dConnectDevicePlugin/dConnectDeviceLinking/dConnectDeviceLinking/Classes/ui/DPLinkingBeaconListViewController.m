//
//  DPLinkingBeaconListTableViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconListViewController.h"
#import "DPLinkingBeaconViewController.h"

@interface DPLinkingBeaconListViewController () <DPLinkingBeaconConnectDelegate>

@property (nonatomic) IBOutlet UISwitch *scanSwitch;

@end

@implementation DPLinkingBeaconListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.beaconManager = [DPLinkingBeaconManager sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    self.scanSwitch.on = [self.beaconManager isStartBeaconScan];
    [self.beaconManager addConnectDelegate:self];
    [self.tableView reloadData];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self.beaconManager removeConnectDelegate:self];
}


- (void) openConfirmRemoveBeaconDialog:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"削除"
                                                                   message:@"ビーコンを削除して良いですか？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf.beaconManager removeBeacon:(int)indexPath.row];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - DPLinkingBeaconConnectDelegate

- (void) didConnectedBeacon:(DPLinkingBeacon *)beacon {
    [self.tableView reloadData];
}

- (void) didDisconnectedBeacon:(DPLinkingBeacon *)beacon {
    [self.tableView reloadData];
}

#pragma mark - IBAction Switch

- (IBAction)switchBeaconScanStatus:(UISwitch *) sender {
    BOOL online = sender.on;
    if (online) {
        [self.beaconManager startBeaconScan];
    } else {
        [self.beaconManager stopBeaconScan];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.beaconManager getBeacons].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell"];
    cell.layoutMargins = UIEdgeInsetsZero;
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *statusLabel = (UILabel *)[cell viewWithTag:2];
    DPLinkingBeacon *beacon = [[self.beaconManager getBeacons] objectAtIndex:indexPath.row];
    nameLabel.text = beacon.displayName;
    statusLabel.text = [NSString stringWithFormat:@"status: %@", beacon.online ? @"online" : @"offline"];
    
    if (beacon.online) {
        nameLabel.textColor = [UIColor blackColor];
        statusLabel.textColor = [UIColor blackColor];
    } else {
        nameLabel.textColor = [UIColor grayColor];
        statusLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DPLinkingBeacon *beacon = [[self.beaconManager getBeacons] objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Linking" bundle:DPLinkingResourceBundle()];
    DPLinkingBeaconViewController* viewCtl = [storyboard instantiateViewControllerWithIdentifier:@"beacon_controller"];
    viewCtl.beaconManager = self.beaconManager;
    viewCtl.beacon = beacon;
    [self.navigationController pushViewController:viewCtl animated:YES];
}

- (NSArray *) tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    __block DPLinkingBeaconListViewController *_self = self;
    return @[
             [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                title:@"削除"
                                              handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                  [_self openConfirmRemoveBeaconDialog:indexPath];
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
