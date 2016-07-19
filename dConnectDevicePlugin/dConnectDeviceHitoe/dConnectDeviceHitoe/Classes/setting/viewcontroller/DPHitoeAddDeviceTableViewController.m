//
//  DPHitoeAddDeviceTableViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeAddDeviceTableViewController.h"
#import "DPHitoeAddDeviceCell.h"
#import "DPHitoeDevice.h"
#import "DPHitoeProgressDialog.h"
#import "DPHitoePinCodeDialog.h"
#import "DPHitoeWakeupDialog.h"
#import "DPHitoeSetShirtDialog.h"

@interface DPHitoeAddDeviceTableViewController () {
    NSMutableArray *discoveries;
    CBCentralManager *cManager;
}
@property (nonatomic) NSTimer *timer;
@end

@implementation DPHitoeAddDeviceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    discoveries = [NSMutableArray array];
    // 背景白
    self.view.backgroundColor = [UIColor whiteColor];
    // 閉じるボタン追加
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"＜CLOSE"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closeSettings:) ];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"Device追加画面";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
    


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [DPHitoeManager sharedInstance].connectionDelegate = self;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL sw = [def boolForKey:DPHitoeWakeUpNever];
    if (!sw) {
        [DPHitoeWakeupDialog showHitoeWakeupDialogWithComplition:^{
            [self startTimer];
        }];
    } else {
        [self startTimer];
    }
    cManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSArray *services = @[];
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)};
    [cManager scanForPeripheralsWithServices:services options:options];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([_timer isValid]) {
        [_timer invalidate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [discoveries count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DPHitoeAddDeviceCell *cell = (DPHitoeAddDeviceCell*) [tableView dequeueReusableCellWithIdentifier:@"cellDevice" forIndexPath:indexPath];
    if ([discoveries count] > indexPath.row) {
        DPHitoeDevice *device = [discoveries objectAtIndex:indexPath.row];
        cell.title.text = device.name;
        cell.address.text = device.serviceId;
        cell.title.hidden = NO;
        cell.address.hidden = NO;
        cell.searchProgress.hidden = YES;
    } else {
        cell.title.hidden = YES;
        cell.address.hidden = YES;
        cell.searchProgress.hidden = NO;
        [cell.searchProgress startAnimating];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([discoveries count] <= 0) {
        return;
    }
    DPHitoeDevice *device = discoveries[indexPath.row];
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    if (!device.pinCode) {
        [DPHitoePinCodeDialog showPinCodeDialogWithCompletion:^(NSString *pinCode) {
            [DPHitoePinCodeDialog closePinCodesDialog];

            device.pinCode = pinCode;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DPHitoeManager sharedInstance] connectForHitoe:device];
                
            });
            dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(updateQueue, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [DPHitoeProgressDialog showProgressDialog];
                });
            });

        }];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DPHitoeManager sharedInstance] connectForHitoe:device];
        });
        [DPHitoeProgressDialog showProgressDialog];

    }
}


#pragma mark - Hitoe delegate
-(void)didConnectWithDevice:(DPHitoeDevice*)device {
    for (int i = 0; i < [discoveries count]; i++) {
        DPHitoeDevice *discovery = [discoveries objectAtIndex:i];
        if ([discovery.serviceId isEqualToString:device.serviceId]) {
            [discoveries removeObjectAtIndex:i];
        }
    }
    [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [DPHitoeSetShirtDialog showHitoeSetShirtDialogWithComplition:^{
            [self startTimer];
            [DPHitoeProgressDialog closeProgressDialog];
        }];
    });
}

-(void)didConnectFailWithDevice:(DPHitoeDevice*)device {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続失敗"
                                                                             message:@"Hitoeとの接続に失敗しました。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    [self startTimer];
    [DPHitoeProgressDialog closeProgressDialog];
}

-(void)didDisconnectWithDevice:(DPHitoeDevice*)device {
    
}

-(void)didDiscoveryForDevices:(NSMutableArray*)devices {
    discoveries = [devices mutableCopy];
    for (int i = 0; i < [discoveries count]; i++) {
        DPHitoeDevice *discovery = [discoveries objectAtIndex:i];
        if (discovery.pinCode && discovery.pinCode.length > 0) {
            [discoveries removeObjectAtIndex:i];
        }
    }
    [self.tableView reloadData];
    [DPHitoeProgressDialog closeProgressDialog];
}

-(void)didDeleteAtDevice:(DPHitoeDevice*)device {
    
}

#pragma mark - CoreBluetooth Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL isStatus = (central.state == CBCentralManagerStatePoweredOn);
    if (!isStatus) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    [cManager stopScan];
}


- (IBAction)searchDevices:(id)sender {
    [[DPHitoeManager sharedInstance] discovery];
    [DPHitoeProgressDialog showProgressDialog];
}


#pragma mark - Private Method
- (void)startTimer {
    _timer = [NSTimer
              scheduledTimerWithTimeInterval:5.0
              target:self
              selector:@selector(onTimer:)
              userInfo:nil
              repeats:YES];
}

#pragma mark - Timer

- (void)onTimer:(NSTimer*)timer {
    [[DPHitoeManager sharedInstance] discovery];
}

@end
