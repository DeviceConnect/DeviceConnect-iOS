//
//  DPHitoeDeviceControlViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeDeviceControlViewController.h"
#import "DPHitoeControlViewController.h"
typedef enum DPHitoeProfiles : NSUInteger
{
    DPHitoeHeartRate = 0,
    DPHitoeBattery,
    DPHitoeDeviceOrientation,
    DPHitoeECG,
    DPHitoeStress,
    DPHitoePose,
    DPHitoeWalk
} DPHitoeProfiles;

@interface DPHitoeDeviceControlViewController () {
    CBCentralManager *cManager;
}
@property NSArray *profileList;
@property (nonatomic, copy) DPHitoeDevice *device;
@end


@implementation DPHitoeDeviceControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _profileList = @[@"HeartRate(心拍数)", @"Battery(電池残量)", @"DeviceOrientation(加速度)",
                    @"ECG(心電図)", @"StressEstimation(ストレス推定)", @"PoseEstimation(姿勢推定)", @"WalkState(歩行状態)"];
    // 背景白
    self.view.backgroundColor = [UIColor whiteColor];
    // 閉じるボタン追加
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"＜CLOSE"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closeSettings:) ];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
    cManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSArray *services = @[];
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)};
    [cManager scanForPeripheralsWithServices:services options:options];
    
}

- (IBAction)closeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




#pragma mark - Public method
- (void)setDevice:(DPHitoeDevice *)device {
    _device = device;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    NSString *titleMessage = [NSString stringWithFormat:@"%@ 操作画面", _device.name];
    title.text = titleMessage;
    [title sizeToFit];
    self.navigationItem.titleView = title;
    
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    DPHitoeControlViewController *controller =
    (DPHitoeControlViewController *) [segue destinationViewController];
    [controller setDevice:_device];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_profileList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"controlProfile" forIndexPath:indexPath];
    cell.textLabel.text = _profileList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case DPHitoeHeartRate:
            [self performSegueWithIdentifier:@"controlHeartRate" sender:self];
            break;
        case DPHitoeBattery:
            [self performSegueWithIdentifier:@"controlBattery" sender:self];
            break;
        case DPHitoeECG:
            [self performSegueWithIdentifier:@"controlECG" sender:self];
            break;
        case DPHitoeDeviceOrientation:
            [self performSegueWithIdentifier:@"controlAcc" sender:self];
            break;
        case DPHitoePose:
            [self performSegueWithIdentifier:@"controlPose" sender:self];
            break;
        case DPHitoeWalk:
            [self performSegueWithIdentifier:@"controlWalk" sender:self];
            break;
        case DPHitoeStress:
            [self performSegueWithIdentifier:@"controlStress" sender:self];
            break;

        default:
            break;
    }
}

#pragma mark - CoreBluetooth Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL isStatus = (central.state == CBCentralManagerStatePoweredOn);
    if (!isStatus) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [cManager stopScan];
}


@end
