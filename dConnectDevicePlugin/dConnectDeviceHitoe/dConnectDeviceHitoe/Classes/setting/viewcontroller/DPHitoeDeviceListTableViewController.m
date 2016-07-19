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

@interface DPHitoeDeviceListTableViewController () {
    NSMutableArray *discoveries;
}

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UITableView *registerDeviceList;
@property (nonatomic) NSTimer *timer;

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
    [[DPHitoeManager sharedInstance] readHitoeData];
    discoveries = [[DPHitoeManager sharedInstance].registeredDevices mutableCopy];
    for (int i = 0; i < [discoveries count]; i++) {
        DPHitoeDevice *discovery = [discoveries objectAtIndex:i];
        if (discovery.pinCode) {
            [discoveries removeObjectAtIndex:i];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [DPHitoeManager sharedInstance].connectionDelegate = self;

    [self enableTableView];
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
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DPHitoeDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellhitoe" forIndexPath:indexPath];
    NSMutableArray *devices = [DPHitoeManager sharedInstance].registeredDevices;
    DPHitoeDevice *device = devices[indexPath.section];
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
    DPHitoeDevice *device = devices[indexPath.section];
    UIColor *btnColor;
    NSString *btnName;
    if (device.isRegisterFlag) {
        btnColor = [self disconnectedBtnColor];
        btnName = @"解除";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DPHitoeManager sharedInstance] disconnectForHitoe:device];
        });
    } else {
        btnColor = [self connectedBtnColor];
        btnName = @"接続";
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DPHitoeManager sharedInstance] connectForHitoe:device];
        });
        [DPHitoeProgressDialog showProgressDialog];

    }

    sender.titleLabel.text = btnName;
}

-(IBAction)rowButtonAction:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    CGPoint p = [gestureRecognizer locationInView:self.registerDeviceList];
    NSIndexPath *indexPath = [self.registerDeviceList indexPathForRowAtPoint:p];
    if (!indexPath){
        return;
    } else if (((UILongPressGestureRecognizer *)gestureRecognizer).state == UIGestureRecognizerStateBegan){
        NSMutableArray *devices = [DPHitoeManager sharedInstance].registeredDevices;
        DPHitoeDevice *device = devices[indexPath.section];
        NSString *message = [NSString stringWithFormat:@"%@を削除しますか？", device.name];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"削除" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"削除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[DPHitoeManager sharedInstance] deleteAtHitoe:device];
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Hitoe's Delegate
-(void)didConnectWithDevice:(DPHitoeDevice*)device {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.registerDeviceList reloadData];
    });
    [DPHitoeProgressDialog closeProgressDialog];
}
-(void)didConnectFailWithDevice:(DPHitoeDevice*)device {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.registerDeviceList reloadData];
    });
    [DPHitoeProgressDialog closeProgressDialog];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"接続失敗"
                                                                             message:@"Hitoeとの接続に失敗しました。"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];

    
}
-(void)didDisconnectWithDevice:(DPHitoeDevice*)device {
    [DPHitoeProgressDialog closeProgressDialog];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.registerDeviceList reloadData];
    });
}
-(void)didDiscoveryForDevices:(NSMutableArray*)devices {
    
}
-(void)didDeleteAtDevice:(DPHitoeDevice*)device {
    [DPHitoeProgressDialog closeProgressDialog];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enableTableView];
    });
}

#pragma mark - segue


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
        self.settingBtn.hidden = YES;
    } else {
        self.registerDeviceList.hidden = NO;
        self.settingBtn.hidden = NO;
        [self.registerDeviceList reloadData];
    }

}

@end
