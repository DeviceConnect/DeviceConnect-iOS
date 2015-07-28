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
    self.view.backgroundColor = [UIColor colorWithRed:0.00
                                                green:0.63
                                                 blue:0.91
                                                alpha:1.0];
    bundle = DPIRBundle();
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
            (DPIRKitVirtualDeviceViewController *)[segue destinationViewController];
        int i = 0;
        for (DPIRKitDevice *device in [[DPIRKitManager sharedInstance] devicesAll]) {
            if (indexPath.row == i) {
                [controller setDetailItem:device];
                break;
            }
            i++;
        }
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
    static NSString *CellIdentifier = @"cellIRKit";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    cell.exclusiveTouch = YES;
    cell.accessoryView.exclusiveTouch = YES;
    NSString * path = [bundle pathForResource:@"irkit10" ofType:@"png"];
    cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    int i = 0;
    for (DPIRKitDevice *device in [[DPIRKitManager sharedInstance] devicesAll]) {
        if (indexPath.row == i) {
            
            cell.textLabel.text = device.name;
            break;
        }
        i++;
    }
    return cell;
}



@end
