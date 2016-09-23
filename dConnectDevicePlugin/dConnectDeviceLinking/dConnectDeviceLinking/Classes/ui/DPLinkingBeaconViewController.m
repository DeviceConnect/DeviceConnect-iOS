//
//  DPLinkingBeaconViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconViewController.h"

@interface DPLinkingBeaconViewController () <DPLinkingBeaconEventDelegate, DPLinkingBeaconButtonIdDelegate>

@property (nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic) IBOutlet UILabel *vendorIdLabel;
@property (nonatomic) IBOutlet UILabel *extraIdLabel;
@property (nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) IBOutlet UILabel *timeStampLabel;
@property (nonatomic) IBOutlet UILabel *lowBatteryLabel;
@property (nonatomic) IBOutlet UILabel *batteryLevelLabel;
@property (nonatomic) IBOutlet UILabel *atmosphericPressureLabel;
@property (nonatomic) IBOutlet UILabel *temperatureLabel;
@property (nonatomic) IBOutlet UILabel *humidityLabel;
@property (nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic) IBOutlet UILabel *rawDataLabel;
@property (nonatomic) IBOutlet UITextView *buttonTextView;

@end

@implementation DPLinkingBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"ビーコン確認";
        
    self.timeStampLabel.adjustsFontSizeToFitWidth = YES;
    self.timeStampLabel.minimumScaleFactor = 0.5f;
    
    [self refreshBeacon];
    [self.beaconManager addBeaconEventDelegate:self];
    [self.beaconManager addButtonIdDelegate:self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.beaconManager removeBeaconEventDelegate:self];
    [self.beaconManager removeButtonIdDelegate:self];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    return cell;
}

#pragma mark - Private Method

- (void) refreshBeacon {
    NSDate *a = [NSDate dateWithTimeIntervalSince1970:self.beacon.gattData.timeStamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    self.deviceNameLabel.text = self.beacon.displayName;
    self.vendorIdLabel.text = [NSString stringWithFormat:@"%ld", self.beacon.vendorId];
    self.extraIdLabel.text = [NSString stringWithFormat:@"%ld", self.beacon.extraId];
    self.versionLabel.text = [NSString stringWithFormat:@"%ld", self.beacon.version];
    self.statusLabel.text = [NSString stringWithFormat:@"%@", self.beacon.online ? @"Online" : @"Offline"];
    self.timeStampLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:a]];
    
    if (self.beacon.batteryData) {
        self.lowBatteryLabel.text = [NSString stringWithFormat:@"%@", self.beacon.batteryData.lowBatteryFlag ? @"true" : @"false"];
        self.batteryLevelLabel.text = [NSString stringWithFormat:@"%3.2f%%", self.beacon.batteryData.batteryLevel];
    } else {
        self.lowBatteryLabel.text = @"-";
        self.batteryLevelLabel.text = @"-";
    }
    
    if (self.beacon.atmosphericPressureData) {
        self.atmosphericPressureLabel.text = [NSString stringWithFormat:@"%5.2fhPa", self.beacon.atmosphericPressureData.value];
    } else {
        self.atmosphericPressureLabel.text = @"-";
    }
    
    if (self.beacon.temperatureData) {
        self.temperatureLabel.text = [NSString stringWithFormat:@"%5.2f℃", self.beacon.temperatureData.value];
    } else {
        self.temperatureLabel.text = @"-";
    }
    
    if (self.beacon.humidityData) {
        self.humidityLabel.text = [NSString stringWithFormat:@"%5.2f%%", self.beacon.humidityData.value];
    } else {
        self.humidityLabel.text = @"-";
    }
    
    if (self.beacon.gattData) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%5.2f", self.beacon.gattData.distance];
    }
    
    if (self.beacon.rawData) {
        self.rawDataLabel.text = [NSString stringWithFormat:@"%ld", self.beacon.rawData.value];
    } else {
        self.rawDataLabel.text = @"-";
    }
}

#pragma mark - DPLinkingBeaconEventDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon {
    if ([self.beacon isEqual:beacon]) {
        [self refreshBeacon];
    }
}

#pragma mark - DPLinkingBeaconButtonIdDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon ButtonId:(int)buttonId {
    if ([self.beacon isEqual:beacon]) {
        NSString *text = self.buttonTextView.text;
        self.buttonTextView.text = [NSString stringWithFormat:@"ButtonId:[%d]\n%@", buttonId, text];
    }
}

#pragma mark - IBAction

- (IBAction) clearButtonTap:(id)sender {
    self.buttonTextView.text = @"";
}

@end
