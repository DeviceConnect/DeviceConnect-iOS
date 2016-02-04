//
//  DPIRKitVirtualProfileViewController.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitVirtualProfileViewController.h"
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitRESTfulRequest.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitRegisterIRViewController.h"

@interface DPIRKitVirtualProfileViewController () {
    DPIRKitVirtualDevice * _virtualDevice;
    NSArray *_virtualRequests;
    NSUInteger _currentRequest;

}
@property (weak, nonatomic) IBOutlet UITableView *virtualProfileList;

@end

@implementation DPIRKitVirtualProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentRequest = 0;
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
    if ([_virtualDevice.categoryName isEqualToString:@"テレビ"]) {
        title.text = @"TVプロファイル編集";
    } else {
        title.text = @"Lightプロファイル編集";        
    }
    [title sizeToFit];
    self.navigationItem.titleView = title;
    
    _virtualProfileList.delegate = self;
    _virtualProfileList.dataSource = self;
    [_virtualProfileList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellVirtualProfile"];

    _virtualRequests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:_virtualDevice.serviceId
                                                                                 profile:nil];
    [_virtualProfileList reloadData];
    if ([_virtualProfileList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_virtualProfileList setSeparatorInset:UIEdgeInsetsZero];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_virtualProfileList reloadData];
}

- (IBAction)closeProfileSettings:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)popUIViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - table delegate

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _virtualRequests.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showIRRegister"]) {
        DPIRKitRegisterIRViewController *controller =
        (DPIRKitRegisterIRViewController *)[segue destinationViewController] ;
        DPIRKitRESTfulRequest *request = _virtualRequests[_currentRequest];
        [controller setDetailItem:request];
    }
}



// セルの生成と設定
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Storyboard で設定したidentifier
    static NSString *CellIdentifier = @"cellVirtualProfile";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    cell.exclusiveTouch = YES;
    cell.accessoryView.exclusiveTouch = YES;
    DPIRKitRESTfulRequest *request = _virtualRequests[indexPath.row];
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    registerButton.frame = CGRectMake(0, 0, 100, 30);
    [registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    if (!request.ir) {
        [registerButton setTitle:@"登録" forState:UIControlStateNormal];
        [registerButton setBackgroundColor:[UIColor colorWithRed:0.00
                                                           green:0.63
                                                            blue:0.91
                                                           alpha:1.0]];
    } else {
        [registerButton setTitle:@"更新" forState:UIControlStateNormal];
        [registerButton setBackgroundColor:[UIColor colorWithRed:1.00
                                                           green:0.58
                                                            blue:0.00
                                                           alpha:1.0]];

    }
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 3.;
    };
    
    roundCorner(registerButton);
    
    [registerButton addTarget:self action:@selector(registerIR:) forControlEvents:UIControlEventTouchUpInside];
    registerButton.tag = indexPath.row;
    cell.accessoryView = registerButton;
    cell.textLabel.text = request.name;
    return cell;
}

- (void)registerIR:(id)sender {
    UIButton *registerButton = (UIButton *) sender;
    _currentRequest = (NSUInteger) registerButton.tag;
    [self performSegueWithIdentifier:@"showIRRegister" sender:self];
}


- (void)setDetailItem:(id)newDetailItem
{
    _virtualDevice = newDetailItem;
}

@end
