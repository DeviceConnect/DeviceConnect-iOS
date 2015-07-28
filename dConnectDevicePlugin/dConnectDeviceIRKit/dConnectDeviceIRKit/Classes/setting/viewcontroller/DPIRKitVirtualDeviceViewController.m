//
//  DPIRKitVirtualDeviceViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPIRKitVirtualDeviceViewController.h"
#import "DPIRKitManager.h"
#import "DPIRKitConst.h"
#import "DPIRKitCategorySelectDialog.h"

@interface DPIRKitVirtualDeviceViewController () {
    NSBundle *bundle;
    NSMutableDictionary *_virtuals;
    DPIRKitDevice *_virtual;
}
@property (weak, nonatomic) IBOutlet UITableView *virtualDeviceList;
- (IBAction)addVirtualDevice:(id)sender;
- (IBAction)deleteVirtualDevice:(id)sender;


@end

@implementation DPIRKitVirtualDeviceViewController
- (IBAction)closeDeviceSetting:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 背景白
    NSLog(@"viewDidLOad");

    self.view.backgroundColor = [UIColor colorWithRed:0.00
                                                green:0.63
                                                 blue:0.91
                                                alpha:1.0];
    bundle = DPIRBundle();
    _virtualDeviceList.delegate = self;
    _virtualDeviceList.dataSource = self;
    [_virtualDeviceList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellVirtualDevice"];
    [_virtualDeviceList reloadData];
    if ([_virtualDeviceList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_virtualDeviceList setSeparatorInset:UIEdgeInsetsZero];
    }

}


#pragma mark - table delegate

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[DPIRKitManager sharedInstance] devicesAll].count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDetail" sender:self];
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

    return cell;
}


- (void)setDetailItem:(id)newDetailItem
{
    _virtual = newDetailItem;
}
- (IBAction)addVirtualDevice:(id)sender {
    [DPIRKitCategorySelectDialog show];
}

- (IBAction)deleteVirtualDevice:(id)sender {
}
@end
