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

@interface DPHitoeDeviceListTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UITableView *registerDeviceList;

@end

@implementation DPHitoeDeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.00
                                                                           green:0.63
                                                                            blue:0.91
                                                                           alpha:1.0];
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{

//        [DPHitoeProgressDialog showProgressDialog];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)closeSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DPHitoeDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellhitoe" forIndexPath:indexPath];
    cell.title.text = @"Hitoe 001  d000322\n[ONLINE]";
    cell.address.text = @"address";
    cell.connect.titleLabel.text = @"接続";
    [cell.connect addTarget:self action:@selector(handleTouchButton:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)handleTouchButton:(UIButton *)sender event:(UIEvent *)event {

    [sender setBackgroundColor:[UIColor grayColor]];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [sender setBackgroundColor:[UIColor colorWithRed:0.00
                                                   green:0.63
                                                    blue:0.91
                                                   alpha:1.0]];
    });

    

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAddDevice"]) {
        //        NSIndexPath *indexPath = [_foundIRKitList indexPathForSelectedRow];
        DPHitoeAddDeviceTableViewController *controller =
        (DPHitoeAddDeviceTableViewController *)[segue destinationViewController] ;
        //        NSArray *devices = [[DPIRKitManager sharedInstance] devicesAll];
        //        [controller setDetailItem:devices[indexPath.row]];
    }
}
- (IBAction)showAddDeviceViewController:(id)sender {
    [self performSegueWithIdentifier:@"showAddDevice" sender:self];
}



@end
