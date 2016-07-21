//
//  DPHitoeDeviceControlViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeDeviceControlViewController.h"
#import "DPHitoeControlECGViewController.h"

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

@interface DPHitoeDeviceControlViewController ()
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
    
}

- (IBAction)closeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

    if ([[segue identifier] isEqualToString:@"controlECG"]) {
        DPHitoeDeviceControlViewController *controller =
        (DPHitoeDeviceControlViewController *) [segue destinationViewController];
        [controller setDevice:_device];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case DPHitoeHeartRate:
            [self.navigationController performSegueWithIdentifier:@"controlHealth" sender:self];
            break;
        case DPHitoeECG:
            [self performSegueWithIdentifier:@"controlECG" sender:self];
            break;
        default:
            break;
    }
}


@end
