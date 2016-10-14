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
    BOOL isConnecting;
    DPHitoeDevice *currentDevice;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateBtn;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *connectedTimeout;
@property (nonatomic) NSTimer *searchTimeout;
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
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{

    
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:_self selector:@selector(didConnectWithDevice:)
                                   name:DPHitoeConnectDeviceNotification
                                 object:nil];
        [notificationCenter addObserver:_self selector:@selector(didConnectFailWithDevice:)
                                   name:DPHitoeConnectFailedDeviceNotification
                                 object:nil];
        [notificationCenter addObserver:_self selector:@selector(didDisconnectWithDevice:)
                                   name:DPHitoeDisconnectNotification
                                 object:nil];
        [notificationCenter addObserver:_self selector:@selector(didDiscoveryForDevices:)
                                   name:DPHitoeDiscoveryDeviceNotification
                                 object:nil];
        [notificationCenter addObserver:_self selector:@selector(didDeleteAtDevice:)
                                   name:DPHitoeDeleteDeviceNotification
                                 object:nil];
    });
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    if ([_connectedTimeout isValid]) {
        [_connectedTimeout invalidate];
    }

    isConnecting = NO;
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:DPHitoeConnectDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeConnectFailedDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDisconnectNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDiscoveryDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDeleteDeviceNotification object:nil];

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
    currentDevice = discoveries[indexPath.row];
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    if (!currentDevice.pinCode) {
        [DPHitoePinCodeDialog showPinCodeDialogWithCompletion:^(NSString *pinCode) {
            [DPHitoePinCodeDialog closePinCodesDialog];

            currentDevice.pinCode = pinCode;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (DPHitoeDevice *d in [DPHitoeManager sharedInstance].registeredDevices) {
                    if (![d.serviceId isEqualToString:currentDevice.serviceId] && d.isRegisterFlag) {
                        [[DPHitoeManager sharedInstance] disconnectForHitoe:d];
                    }
                }
                [[DPHitoeManager sharedInstance] connectForHitoe:currentDevice];
                
            });
            dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(updateQueue, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [DPHitoeProgressDialog showProgressDialog];
                    _updateBtn.enabled = NO;
                });
            });
            [self startTimeoutTimer];
        }];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DPHitoeManager sharedInstance] connectForHitoe:currentDevice];
        });
        [DPHitoeProgressDialog showProgressDialog];
        _updateBtn.enabled = NO;
        [self startTimeoutTimer];
    }
}


#pragma mark - Hitoe delegate
-(void)didConnectWithDevice:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    DPHitoeDevice *device = userInfo[DPHitoeConnectDeviceObject];
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
            _updateBtn.enabled = YES;
        }];
    });
    isConnecting = NO;
}

-(void)didConnectFailWithDevice:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    DPHitoeDevice *device = userInfo[DPHitoeConnectFailedDeviceObject];
    for (int i = 0; i < [discoveries count]; i++) {
        if ([device.serviceId isEqualToString:((DPHitoeDevice*) discoveries[i]).serviceId]) {
            ((DPHitoeDevice*) discoveries[i]).pinCode = nil;
        }
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続失敗"
                                                                             message:@"Hitoeとの接続に失敗しました。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    [self startTimer];
    [DPHitoeProgressDialog closeProgressDialog];
    _updateBtn.enabled = YES;
    isConnecting = NO;

}

-(void)didDisconnectWithDevice:(NSNotification *)notification {

    
}

-(void)didDiscoveryForDevices:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)[notification userInfo];
    NSMutableArray *devices = userInfo[DPHitoeDiscoveryDeviceObject];

    discoveries = [devices mutableCopy];
    for (int i = 0; i < [discoveries count]; i++) {
        DPHitoeDevice *discovery = [discoveries objectAtIndex:i];
        if (discovery.pinCode && discovery.pinCode.length > 0) {
            [discoveries removeObjectAtIndex:i];
        }
    }
    [self.tableView reloadData];
    [DPHitoeProgressDialog closeProgressDialog];
    _updateBtn.enabled = YES;

}

-(void)didDeleteAtDevice:(NSNotification *)notification {
    
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
    _updateBtn.enabled = NO;
    [self startSearchoutTimer];


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

- (void)startTimeoutTimer {
    isConnecting = YES;
    _connectedTimeout = [NSTimer
                         scheduledTimerWithTimeInterval:30.0
                         target:self
                         selector:@selector(onTimeout:)
                         userInfo:nil
                         repeats:NO];

}

- (void)startSearchoutTimer {
    _searchTimeout = [NSTimer
                         scheduledTimerWithTimeInterval:10.0
                         target:self
                         selector:@selector(onSearchout:)
                         userInfo:nil
                         repeats:NO];
    
}
#pragma mark - Timer

- (void)onTimer:(NSTimer*)timer {
    [[DPHitoeManager sharedInstance] discovery];
}

- (void)onTimeout:(NSTimer*)timer {
    if (isConnecting) {
        [DPHitoeProgressDialog closeProgressDialog];
        _updateBtn.enabled = YES;

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続失敗"
                                                                                 message:@"Hitoeとの接続に失敗しました。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        isConnecting = NO;
        if (currentDevice) {
            currentDevice.pinCode = nil;
            currentDevice = nil;
        }
    }

}

- (void)onSearchout:(NSTimer*)timer {
    [DPHitoeProgressDialog closeProgressDialog];
    _updateBtn.enabled = YES;
}

@end
