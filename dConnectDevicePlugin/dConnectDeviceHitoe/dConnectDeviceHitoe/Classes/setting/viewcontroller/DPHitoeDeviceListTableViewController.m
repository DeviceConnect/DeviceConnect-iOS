//
//  DPHitoeDeviceListTableViewController.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeDeviceListTableViewController.h"
#import "DPHitoeProgressDialog.h"
#import "DPHitoeDeviceListCell.h"
#import "DPHitoeAddDeviceTableViewController.h"
#import "DPHitoeProgressDialog.h"
#import "DPHitoeDeviceControlViewController.h"

static NSString *const DPHitoeOpenAddDevice = @"Hitoeが追加されていません。\n"
                                            "「デバイス追加画面へ」ボタンを押して、\n"
                                            "Hitoeを追加してください。";
static NSString *const DPHitoeOpenBluetooth = @"BluetoothがOFFになっているために接続できません。\n"
                                            "Bluetooth設定画面からBluetoothを有効に設定してください。";


@interface DPHitoeDeviceListTableViewController () {
    NSMutableArray *discoveries;
    CBCentralManager *cManager;
    BOOL isConnecting;
    NSUInteger current;
}

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UITableView *registerDeviceList;
@property (nonatomic) NSTimer *connectedTimeout;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addDeviceBtn;

@end

@implementation DPHitoeDeviceListTableViewController

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
    title.text = @"Device一覧画面";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    self.registerDeviceList.delegate = self;
    self.registerDeviceList.dataSource = self;
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [self disconnectedBtnColor];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(rowButtonAction:)];
    longPressRecognizer.allowableMovement = 15;
    longPressRecognizer.minimumPressDuration = 0.6f;
    [self.registerDeviceList addGestureRecognizer: longPressRecognizer];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[DPHitoeManager sharedInstance].registeredDevices count] == 0) {
        [[DPHitoeManager sharedInstance] readHitoeData];
    }
    discoveries = [[DPHitoeManager sharedInstance].registeredDevices mutableCopy];
    for (int i = 0; i < [discoveries count]; i++) {
        DPHitoeDevice *discovery = [discoveries objectAtIndex:i];
        if (!discovery.pinCode) {
            [discoveries removeObjectAtIndex:i];
        }
    }

    cManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSArray *services = @[];
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)};
    [cManager scanForPeripheralsWithServices:services options:options];
    //接続状態でボタンの文字が接続解除になってしまうため
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self enableTableView];
        });
    });
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
    if ([_connectedTimeout isValid]) {
        [_connectedTimeout invalidate];
    }
    
    isConnecting = NO;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:DPHitoeConnectDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeConnectFailedDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDisconnectNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDiscoveryDeviceNotification object:nil];
    [notificationCenter removeObserver:self name:DPHitoeDeleteDeviceNotification object:nil];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [discoveries count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DPHitoeDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellhitoe" forIndexPath:indexPath];
    NSMutableArray *devices = [DPHitoeManager sharedInstance].registeredDevices;
    DPHitoeDevice *device = devices[indexPath.row];
    NSString *name;
    NSString *btnName;
    UIColor *btnColor;
    if (device.isRegisterFlag) {
        name = [NSString stringWithFormat:@"%@\n[ONLINE]", device.name];
        btnName = @"解除";
        btnColor = [self connectedBtnColor];
    } else {
        name = [NSString stringWithFormat:@"%@\n[OFFLINE]", device.name];
        btnName = @"接続";
        btnColor = [self disconnectedBtnColor];

    }
    cell.title.text = name;
    cell.address.text = device.serviceId;
    cell.connect.titleLabel.text = btnName;
    cell.connect.backgroundColor = btnColor;
    [cell.connect addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    NSMutableArray *devices = [DPHitoeManager sharedInstance].registeredDevices;
    DPHitoeDevice *device = devices[indexPath.row];
    UIColor *btnColor;
    NSString *btnName;
    if (device.isRegisterFlag) {
        btnColor = [self disconnectedBtnColor];
        btnName = @"接続";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DPHitoeManager sharedInstance] disconnectForHitoe:device];
        });
    } else {
        btnColor = [self connectedBtnColor];
        btnName = @"解除";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (DPHitoeDevice *d in [DPHitoeManager sharedInstance].registeredDevices) {
                if (![d.serviceId isEqualToString:device.serviceId] && d.isRegisterFlag) {
                    [[DPHitoeManager sharedInstance] disconnectForHitoe:d];
                }
            }
            [[DPHitoeManager sharedInstance] connectForHitoe:device];
        });
        [DPHitoeProgressDialog showProgressDialog];
        [self startTimeoutTimer];
    }

    sender.titleLabel.text = btnName;
    sender.backgroundColor = btnColor;

}

-(IBAction)rowButtonAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint p = [gestureRecognizer locationInView:self.registerDeviceList];
    NSIndexPath *indexPath = [self.registerDeviceList indexPathForRowAtPoint:p];
    if (!indexPath){
        return;
    } else if (((UILongPressGestureRecognizer *)gestureRecognizer).state == UIGestureRecognizerStateBegan){
        DPHitoeDevice *device = [DPHitoeManager sharedInstance].registeredDevices[indexPath.row];
        NSString *message = [NSString stringWithFormat:@"%@を削除しますか？", device.name];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"削除" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"削除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [discoveries removeObject:device];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DPHitoeManager sharedInstance] deleteAtHitoe:device];
            });

            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DPHitoeDevice *device = discoveries[indexPath.row];
    if (!device.isRegisterFlag) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"警告"
                                                                                 message:@"Hitoeを操作するには、Hitoeと接続してください。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];

        return;
    }
    current = indexPath.row;
    [self performSegueWithIdentifier:@"showControlDevice" sender:self];

}


#pragma mark - Hitoe's Delegate
-(void)didConnectWithDevice:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.registerDeviceList reloadData];
    });
    [DPHitoeProgressDialog closeProgressDialog];
    isConnecting = NO;
}

-(void)didConnectFailWithDevice:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.registerDeviceList reloadData];
    });
    [DPHitoeProgressDialog closeProgressDialog];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続失敗"
                                                                             message:@"Hitoeとの接続に失敗しました。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];

    isConnecting = NO;
}
-(void)didDisconnectWithDevice:(NSNotification *)notification {

    [DPHitoeProgressDialog closeProgressDialog];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.registerDeviceList reloadData];
    });
}
-(void)didDiscoveryForDevices:(NSNotification *)notification {
}
-(void)didDeleteAtDevice:(NSNotification *)notification {
    [DPHitoeProgressDialog closeProgressDialog];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enableTableView];
    });
}

#pragma mark - CoreBluetooth Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    BOOL isStatus = (central.state == CBCentralManagerStatePoweredOn);
    if (!isStatus) {
        self.registerDeviceList.hidden = YES;
        self.addDeviceBtn.enabled = NO;
        self.descriptionLabel.text = DPHitoeOpenBluetooth;
    } else {
        [self enableTableView];
    }
    [cManager stopScan];
}


#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showControlDevice"]) {
        UINavigationController *navController = (UINavigationController*)[segue destinationViewController] ;
        DPHitoeDeviceControlViewController *controller =
        (DPHitoeDeviceControlViewController *) [navController topViewController];
        DPHitoeDevice *device = discoveries[current];
        [controller setDevice:device];
    }
}
- (IBAction)showAddDeviceViewController:(id)sender {
    [self performSegueWithIdentifier:@"showAddDevice" sender:self];
}





#pragma mark - UIColor's const.

- (UIColor *)connectedBtnColor
{
    return [UIColor colorWithRed:0.88 green:0.00 blue:0.30 alpha:1.0];
}

- (UIColor *)disconnectedBtnColor
{
    return [UIColor colorWithRed:0.00
                                     green:0.63
                                      blue:0.91
                                     alpha:1.0];
}


#pragma mark - Private method

- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self.registerDeviceList];
    NSIndexPath *indexPath = [self.registerDeviceList indexPathForRowAtPoint:p];
    return indexPath;
}

- (void)enableTableView {
    
    if ([discoveries count] == 0) {
        self.registerDeviceList.hidden = YES;
        self.addDeviceBtn.enabled = YES;
        self.descriptionLabel.text = DPHitoeOpenAddDevice;
    } else {
        self.registerDeviceList.hidden = NO;
        self.addDeviceBtn.enabled = YES;

        [self.registerDeviceList reloadData];
    }

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
#pragma mark - Timer
- (void)onTimeout:(NSTimer*)timer {
    if (isConnecting) {
        [DPHitoeProgressDialog closeProgressDialog];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続失敗"
                                                                                 message:@"Hitoeとの接続に失敗しました。"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        isConnecting = NO;
    }
}

@end
