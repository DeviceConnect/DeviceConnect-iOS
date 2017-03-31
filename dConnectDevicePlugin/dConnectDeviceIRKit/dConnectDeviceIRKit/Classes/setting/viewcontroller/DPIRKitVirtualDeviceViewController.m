//
//  DPIRKitVirtualDeviceViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <DConnectSDK/DConnectSDK.h>
#import "DPIRKitVirtualDeviceViewController.h"
#import "DPIRKitManager.h"
#import "DPIRKitConst.h"
#import "DPIRKitCategorySelectDialog.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitVirtualProfileViewController.h"


@interface DPIRKitVirtualDeviceViewController () {
    DConnectServiceProvider *_serviceProvider;
    NSBundle *bundle;
    NSMutableDictionary *_virtuals;
    NSString *_irkitName;
    NSArray *_devices;
    BOOL _isRemoved;
}
@property (weak, nonatomic) IBOutlet UITableView *virtualDeviceList;
- (IBAction)addVirtualDevice:(id)sender;
- (IBAction)deleteVirtualDevice:(id)sender;

@property (weak, nonatomic) IBOutlet UIToolbar *menuBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;


@end

@implementation DPIRKitVirtualDeviceViewController
- (IBAction)closeDeviceSetting:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_isRemoved) {
        [self switchButton];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    bundle = DPIRBundle();
    _virtualDeviceList.allowsMultipleSelection = NO;

    _isRemoved = NO;
    // 背景白
    self.view.backgroundColor = [UIColor whiteColor];
    // 閉じるボタン追加
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"＜ 一覧"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(popUIViewController:) ];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"デバイス一覧";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
    [_menuBar setBarTintColor:[UIColor colorWithRed:0.00
                                              green:0.63
                                               blue:0.91
                                              alpha:1.0]];
    _virtualDeviceList.delegate = self;
    _virtualDeviceList.dataSource = self;
    [_virtualDeviceList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellVirtualDevice"];
    _devices = [[DPIRKitDBManager sharedInstance] queryVirtualDevice:nil];
    [_virtualDeviceList reloadData];
    if ([_virtualDeviceList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_virtualDeviceList setSeparatorInset:UIEdgeInsetsZero];
    }
}


- (IBAction)popUIViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_isRemoved) {
        [self switchButton];
    }
}

#pragma mark - table delegate

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _devices.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_isRemoved) {
        [self performSegueWithIdentifier:@"showProfile" sender:self];
    } else {
        // 選択の外れたセルを取得する
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        // セルにチェックマークを付ける
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

// セルの選択がはずれた時も忘れずに
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 選択の外れたセルを取得する
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // セルのチェックマークを外す
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showProfile"]) {
        _isRemoved = NO;
        NSIndexPath *indexPath = [_virtualDeviceList indexPathForSelectedRow];
        DPIRKitVirtualProfileViewController *controller =
        (DPIRKitVirtualProfileViewController *)[segue destinationViewController] ;
        DPIRKitVirtualDevice *device = _devices[indexPath.row];
        [controller setDetailItem:device];
    }
}



// セルの生成と設定
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Storyboard で設定したidentifier
    static NSString *CellIdentifier = @"cellVirtualDevice";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    cell.exclusiveTouch = YES;
    cell.accessoryView.exclusiveTouch = YES;
    DPIRKitVirtualDevice * device = _devices[indexPath.row];
    NSString * path = [bundle pathForResource:@"light" ofType:@"png"];
    if ([device.categoryName isEqualToString:@"テレビ"]) {
        path = [bundle pathForResource:@"tv" ofType:@"png"];
    }
    cell.imageView.image = [UIImage imageWithContentsOfFile:path];

    if (!_isRemoved) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = device.deviceName;
    return cell;
}


- (void)setDetailName:(id)detailName
{
    _irkitName = detailName;
}

- (void)setProvider:(id)provider
{
    _serviceProvider = provider;
}

// 仮想デバイスのリストを更新する
- (void)updateChanges:(NSNotification*)notification
{
    _devices = [[DPIRKitDBManager sharedInstance] queryVirtualDevice:nil];
    [_virtualDeviceList reloadData];
}


- (IBAction)addVirtualDevice:(id)sender {
    if (!_isRemoved) {
        // ダイアログでの操作を受け取るNotification
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

        [nc addObserver:self
               selector:@selector(updateChanges:)
                   name:DPIRKitVirtualDeviceCreateNotification
                 object:nil];
        [DPIRKitCategorySelectDialog showWithServiceId:_irkitName];
    } else {
        //削除モード時はキャンセルボタンになる
        [self switchButton];
    }
}

- (IBAction)deleteVirtualDevice:(id)sender {
    if (!_isRemoved) {
        [self switchButton];
    } else {
        NSArray *cells = [_virtualDeviceList indexPathsForSelectedRows];
        if (cells.count == 0) {
            [self showAlertWithTitle:@"削除" message:@"削除するデバイスを選んでください。"];
        } else {
            __weak typeof(self) _self = self;
            [self showConfirmAlertWithTitle:@"選択項目の削除" message:@"削除しますか？" completion:^{
                [_self executeDeleteVirtualDevice];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _devices = [[DPIRKitDBManager sharedInstance] queryVirtualDevice:nil];
                    [self switchButton];
                    [_virtualDeviceList reloadData];
                });

            }];
        }
    }
}

- (void)switchButton {
    if (!_isRemoved) {
        _virtualDeviceList.allowsMultipleSelection = YES;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.93
                                           green:0.65
                                                                                blue:0.70
                                                                               alpha:1.0];

        [_menuBar setBarTintColor:[UIColor colorWithRed:0.93 green:0.65 blue:0.70 alpha:1.0]];
        [_leftButton setTitle:@"キャンセル"];
        [_rightButton setTitle:@"削除"];
        _isRemoved = YES;
    } else {
        _virtualDeviceList.allowsMultipleSelection = NO;

        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                               green:0.63
                                                                                blue:0.91
                                                                               alpha:1.0];
        [_menuBar setBarTintColor:[UIColor colorWithRed:0.00
                                                    green:0.63
                                                     blue:0.91
                                                    alpha:1.0]];
        [_leftButton setTitle:@"追加"];
        [_rightButton setTitle:@"削除"];
        _isRemoved = NO;
    }
    [_virtualDeviceList reloadData];
}




- (void)executeDeleteVirtualDevice {
    
    NSArray *cells = [_virtualDeviceList indexPathsForSelectedRows];
    DPIRKitDBManager *mgr = [DPIRKitDBManager sharedInstance];
    BOOL isDelete = NO;
    for (NSIndexPath *c in cells) {
        DPIRKitVirtualDevice *device = _devices[c.row];
        DConnectService *service = [_serviceProvider service:device.serviceId];
        [_serviceProvider removeService:service];
        BOOL isDeleteVirtualDevice = [mgr deleteVirtualDevice:device.serviceId];
        BOOL isDeleteVirtualProfile = [mgr deleteRESTfulRequestForServiceId:device.serviceId];
        if (isDeleteVirtualDevice || isDeleteVirtualProfile) {
            isDelete = YES;
        }
    }
    if (isDelete) {
        [self showAlertWithTitle:@"削除" message:@"削除しました。"];
    } else {
        [self showAlertWithTitle:@"削除" message:@"削除に失敗しました。"];
    }
}

- (void)showConfirmAlertWithTitle:(NSString*)title
                          message:(NSString*)message
                            completion:(void (^)())completion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"削除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (completion) {
            completion();
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
