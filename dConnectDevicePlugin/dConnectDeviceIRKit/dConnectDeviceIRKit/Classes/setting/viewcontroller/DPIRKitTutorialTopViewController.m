//
//  DPIRKitTutorialTopViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitTutorialTopViewController.h"
#import "DPIRKitVirtualDeviceViewController.h"
#import "DPIRKitDevice.h"
#import "DPIRKitDevicePlugin.h"
#import "DPIRKitManager.h"
#import "DPIRKitConst.h"

@interface DPIRKitTutorialTopViewController () {
    NSBundle *bundle;
    NSMutableDictionary *_devices;
    NSUInteger _selectedDevice;
}
@property (weak, nonatomic) IBOutlet UITableView *foundIRKitList;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation DPIRKitTutorialTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    bundle = DPIRBundle();
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
    title.text = @"IRKit一覧";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    // バー背景色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];

    _foundIRKitList.delegate = self;
    _foundIRKitList.dataSource = self;
    [_foundIRKitList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIRKit"];
    [_foundIRKitList reloadData];
    if ([_foundIRKitList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_foundIRKitList setSeparatorInset:UIEdgeInsetsZero];
    }
}
- (IBAction)closeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [_foundIRKitList indexPathForSelectedRow];
        DPIRKitVirtualDeviceViewController *controller =
            (DPIRKitVirtualDeviceViewController *)[segue destinationViewController] ;
        NSArray *devices = [[DPIRKitManager sharedInstance] devicesAll];
        [controller setDetailItem:devices[indexPath.row]];
    }
}

- (IBAction)searchIRKit:(id)sender {
    [[DPIRKitManager sharedInstance] startDetection];
    [_foundIRKitList reloadData];
}

#pragma mark - table delegate

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[DPIRKitManager sharedInstance] devicesAll].count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
   [self performSegueWithIdentifier:@"showDetail" sender:self];
}

// セルの生成と設定
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellIRKit";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    cell.exclusiveTouch = YES;
    cell.accessoryView.exclusiveTouch = YES;
    NSString * path = [bundle pathForResource:@"irkit10" ofType:@"png"];
    cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    NSArray *devices = [[DPIRKitManager sharedInstance] devicesAll];
    DPIRKitDevice *device = devices[indexPath.row];
    cell.textLabel.text = device.name;
    return cell;
}



@end
