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

@interface DPHitoeAddDeviceTableViewController () {
    NSMutableArray *discoveries;
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
    

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        _timer = [NSTimer
                     scheduledTimerWithTimeInterval:5.0
                     target:self
                     selector:@selector(onTimer:)
                     userInfo:nil
                     repeats:YES];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [DPHitoeManager sharedInstance].connectionDelegate = self;
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
    return [discoveries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DPHitoeAddDeviceCell *cell = (DPHitoeAddDeviceCell*) [tableView dequeueReusableCellWithIdentifier:@"cellDevice" forIndexPath:indexPath];
    DPHitoeDevice *device = [discoveries objectAtIndex:indexPath.section];
    cell.title.text = device.name;
    cell.address.text = device.serviceId;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSMutableArray *devices = [DPHitoeManager sharedInstance].registeredDevices;
    DPHitoeDevice *device = [devices objectAtIndex:indexPath.section];
    
    if (!device.pinCode) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        [DPHitoePinCodeDialog showPinCodeDialogWithCompletion:^(NSString *pinCode) {
            device.pinCode = pinCode;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DPHitoeManager sharedInstance] connectForHitoe:device];
            });
            _timer = [NSTimer
                      scheduledTimerWithTimeInterval:5.0
                      target:self
                      selector:@selector(onTimer:)
                      userInfo:nil
                      repeats:YES];
        }];
        return;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DPHitoeManager sharedInstance] connectForHitoe:device];
        });
    }
   [DPHitoeProgressDialog showProgressDialog];

}


#pragma mark - Hitoe delegate
-(void)didConnectWithDevice:(DPHitoeDevice*)device {
    [DPHitoeProgressDialog closeProgressDialog];
    for (int i = 0; i < [discoveries count]; i++) {
        DPHitoeDevice *discovery = [discoveries objectAtIndex:i];
        if ([discovery.serviceId isEqualToString:device.serviceId]) {
            [discoveries removeObjectAtIndex:i];
        }
    }
    [self.tableView reloadData];
}

-(void)didConnectFailWithDevice:(DPHitoeDevice*)device {
    [DPHitoeProgressDialog closeProgressDialog];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続失敗"
                                                                             message:@"Hitoeとの接続に失敗しました。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];

}

-(void)didDisconnectWithDevice:(DPHitoeDevice*)device {
    
}

-(void)didDiscoveryForDevices:(NSMutableArray*)devices {
    discoveries = [devices mutableCopy];
    for (int i = 0; i < [discoveries count]; i++) {
        DPHitoeDevice *discovery = [discoveries objectAtIndex:i];
        if (discovery.pinCode) {
            [discoveries removeObjectAtIndex:i];
        }
    }

    if ([discoveries count] > 0) {
        [self.tableView reloadData];
    }
    [DPHitoeProgressDialog closeProgressDialog];
}

-(void)didDeleteAtDevice:(DPHitoeDevice*)device {
    
}

- (IBAction)searchDevices:(id)sender {
    [[DPHitoeManager sharedInstance] discovery];
    [DPHitoeProgressDialog showProgressDialog];
}

#pragma mark - Timer

- (void)onTimer:(NSTimer*)timer {
    [[DPHitoeManager sharedInstance] discovery];
}

@end
