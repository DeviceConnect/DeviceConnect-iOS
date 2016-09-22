//
//  GHDeviceListViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHDeviceListViewController.h"
#import "GHDeviceListViewModel.h"
#import "TopCollectionHeaderView.h"
#import "DeviceIconViewCell.h"
#import "WebViewController.h"
#import "GHDeviceUtil.h"
#import "GHDevicePluginViewModel.h"
#import "GHDevicePluginDetailViewModel.h"
#import <DConnectSDK/DConnectSystemProfile.h>
#import <DConnectSDK/DConnectService.h>

@interface GHDeviceListViewController ()
{
    GHDeviceListViewModel *viewModel;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *reloadButton;
@property (strong, nonatomic) IBOutlet UIView* loadingView;
@end

@implementation GHDeviceListViewController
//--------------------------------------------------------------//
#pragma mark - 初期化
//--------------------------------------------------------------//
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        viewModel = [[GHDeviceListViewModel alloc]init];
        viewModel.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    viewModel = nil;
}

//--------------------------------------------------------------//
#pragma mark - collectionViewDelegate
//--------------------------------------------------------------//
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [viewModel.datasource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DConnectMessage* message = [viewModel.datasource objectAtIndex:indexPath.row];
        DeviceIconViewCell* cell = (DeviceIconViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceIconViewCell" forIndexPath:indexPath];
        [cell setDevice:message];
        __weak GHDeviceListViewController *weakSelf = self;
        [cell setDidIconSelected: ^(DConnectMessage* message) {
            [weakSelf openDeviceDetail: message];
        }];
        return cell;
}

- (TopCollectionHeaderView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    TopCollectionHeaderView* header = (TopCollectionHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerCell" forIndexPath:indexPath];
     header.titleLabel.text = @"デバイス";
    return header;
}

//--------------------------------------------------------------//
#pragma mark - GHDeviceListViewModelDelegate
//--------------------------------------------------------------//
- (void)startReloadDeviceList
{
    self.reloadButton.enabled = NO;
    self.loadingView.frame = CGRectMake(0, 40, self.collectionView.frame.size.width, 220);
    [self.collectionView addSubview: self.loadingView];

}

- (void)finishReloadDeviceList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView removeFromSuperview];
        [self.collectionView reloadData];
        self.reloadButton.enabled = YES;
    });
}

//--------------------------------------------------------------//
#pragma mark - transition
//--------------------------------------------------------------//
- (IBAction)close:(UIBarButtonItem*)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openDeviceDetail:(DConnectMessage*)message
{
    NSString *serviceId = [message stringForKey: DConnectServiceDiscoveryProfileParamId];
    NSString *name = [message stringForKey:DConnectServiceDiscoveryProfileParamName];
    BOOL isOnline = [message boolForKey:DConnectServiceDiscoveryProfileParamOnline];
    GHDevicePluginViewModel *viewModel = [[GHDevicePluginViewModel alloc] init];
    DConnectDevicePlugin *plugin = nil;
    for (DConnectDevicePlugin *p in viewModel.datasource) {
        for (DConnectService *s in p.serviceProvider.services) {
            NSRange range = [serviceId rangeOfString:s.serviceId];
            if (range.location != NSNotFound) {
                plugin = p;
                break;
            }
        }
    }
    if (isOnline) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"demo"];
        WebViewController* webView = [[WebViewController alloc] initWithURL: [NSString stringWithFormat:@"file://%@?serviceId=%@", path, serviceId]];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:webView];
        [webView presentationDeviceView:nav];
    } else {
        
        NSString *mes = [NSString stringWithFormat:@"%@は、接続されていません。デバイスプラグインの設定を確認してください。", name];
        UIAlertController * ac =
        [UIAlertController alertControllerWithTitle:@"デバイス起動"
                                            message:mes
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancelAction =
        [UIAlertAction actionWithTitle:@"閉じる"
                                 style:UIAlertActionStyleCancel
                               handler:nil];
        UIAlertAction * okAction =
        [UIAlertAction actionWithTitle:@"設定を開く"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   NSDictionary* plugins = [viewModel makePlguinAndPlugins:plugin];
                                   GHDevicePluginDetailViewModel *model = [[GHDevicePluginDetailViewModel alloc] initWithPlugin:plugins];
                                   
                                   DConnectSystemProfile *systemProfile = [model findSystemProfile];
                                   if (systemProfile) {
                                       UIViewController* controller = [systemProfile.dataSource profile:nil settingPageForRequest:nil];
                                       if (controller) {
                                           [self presentViewController:controller animated:YES completion:nil];
                                       } else {
                                           UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"設定画面はありません" preferredStyle:UIAlertControllerStyleAlert];
                                           [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                           [self presentViewController:alert animated:YES completion:nil];
                                       }
                                   }
                                   
                               }];
        [ac addAction:cancelAction];
        [ac addAction:okAction];
        [self presentViewController:ac animated:YES completion:nil];
    }
}


- (IBAction)refresh:(UIBarButtonItem *)sender {
    [viewModel refresh];
}

//--------------------------------------------------------------//
#pragma mark - view cycle
//--------------------------------------------------------------//
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"デバイス一覧";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [viewModel setup];
}

@end
