//
//  GHDeviceListViewController.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GHDeviceListViewController.h"
#import "GHDeviceListViewModel.h"
#import "TopCollectionHeaderView.h"
#import "DeviceIconViewCell.h"
#import "WebViewController.h"

@interface GHDeviceListViewController ()
{
    GHDeviceListViewModel *viewModel;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
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
- (void)requestDatasourceReload
{
    [self.collectionView reloadData];
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
    //TODO: デバイス確認画面用のhtmlのpathを渡す
    NSString* path = [[NSBundle mainBundle]pathForResource:@"device" ofType:@"html"];
    WebViewController* controller = [[WebViewController alloc]initWithPath:path];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self presentViewController:nav animated:YES completion:nil];
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
