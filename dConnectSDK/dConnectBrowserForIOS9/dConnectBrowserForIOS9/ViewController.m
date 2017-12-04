//
//  ViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ViewController.h"
#import "GHSettingController.h"
#import "GHURLManager.h"
#import <DConnectSDK/DConnectSDK.h>
#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"
#import "BookmarkIconViewCell.h"
#import "TopCollectionHeaderView.h"
#import "InitialGuideViewController.h"
#import "WebViewController.h"
#import "DeviceIconViewCell.h"
#import "DeviceMoreViewCell.h"
#import "GHDeviceListViewController.h"
#import "GHDeviceUtil.h"
#import "GHDevicePluginViewModel.h"
#import "GHDevicePluginDetailViewModel.h"
#import <DConnectSDK/DConnectSystemProfile.h>
#import <DConnectSDK/DConnectService.h>
#import <objc/runtime.h>

@interface ViewController ()
{
    TopViewModel *viewModel;
}

@property (nonatomic, strong) IBOutlet GHHeaderView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UILabel* emptyBookmarksLabel;
@property (strong, nonatomic) UILabel* emptyDevicesLabel;
@property (strong, nonatomic) IBOutlet UIView* loadingView;

- (IBAction)openBookmarkView:(id)sender;
- (IBAction)onTapView:(id)sender;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        viewModel = [[TopViewModel alloc] init];
        viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    id<UIApplicationDelegate> appDelegate
    = [UIApplication sharedApplication].delegate;
    if ([appDelegate isKindOfClass:[AppDelegate class]]) {
        [(AppDelegate *)appDelegate
         setURLLoadingCallback:^(NSURL* redirectURL){
             if (redirectURL) {
                 [self openSafariViewInternalWithURL:redirectURL.absoluteString];
             }
         }];
        [(AppDelegate *)appDelegate setRequestToCloseSafariView:^{
            if (appDelegate.window.rootViewController.presentedViewController != nil) {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }];
    }

    [super viewDidLoad];
    [viewModel initialSetup];

    self.headerView.delegate = self;


    //ブックマークのweb表示通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(showWebPage:)
                                                name:SHOW_WEBPAGE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __weak ViewController* _self = self;
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    if ([def boolForKey:IS_INITIAL_GUIDE_OPEN]) {
        [viewModel updateDeviceList];
        [viewModel updateDatasource];
        [_self.collectionView reloadData];
        [_self addEmptyLabelIfNeeded];
    }
    if ([viewModel isNeedOpenInitialGuide]) {
        [self openInitialGuide];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [viewModel saveSettings];
}

// landscape時にはステータスバーが無くなるのでその分headerViewの高さを短くする
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return;
    }

    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
         toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        self.headerHeight.constant = 44;
    } else {
        self.headerHeight.constant = 64;
    }

    [self.view setNeedsUpdateConstraints];
}

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)addEmptyLabelIfNeeded
{
    if (viewModel.isBookmarksEmpty) {
        if (!self.emptyBookmarksLabel) {
            self.emptyBookmarksLabel = [self makeEmptyLabel: CGRectMake(0, 50, 320, 220)
                                                    message:@"ブックマークがありません。\nブックマークを登録してください。"];
            [self.collectionView addSubview:self.emptyBookmarksLabel];
        }
    } else {
        [self.emptyBookmarksLabel removeFromSuperview];
        self.emptyBookmarksLabel = nil;
    }

    if (viewModel.isDeviceEmpty && !viewModel.isDeviceLoading) {
        self.emptyDevicesLabel = [self makeEmptyLabel: CGRectMake(0, 300, 320, 220)
                                             message:@"デバイスが接続されていません。\nプラグインから設定を行ってください。"];
        [self.collectionView addSubview:self.emptyDevicesLabel];
    } else {
        [self.emptyDevicesLabel removeFromSuperview];
        self.emptyDevicesLabel = nil;
    }

    if (viewModel.isDeviceLoading) {
        self.loadingView.frame = CGRectMake(0, 300, self.collectionView.frame.size.width, 220);
        [self.collectionView addSubview: self.loadingView];
    } else {
        [self.loadingView removeFromSuperview];
    }
}

- (UILabel*)makeEmptyLabel:(CGRect)rect message:(NSString*)message
{
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    label.text = message;
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = HEXCOLOR(0x666666);
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

//--------------------------------------------------------------//
#pragma mark - open UI
//--------------------------------------------------------------//

- (IBAction)openBookmarkView:(id)sender {
    //ストーリーボードから取得
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:[NSBundle mainBundle]];
    UIViewController *bookmark = [storyboard instantiateInitialViewController];
    [self presentViewController:bookmark animated:YES completion:nil];
}


- (IBAction)onTapView:(id)sender {
    [self.view endEditing:YES];
}

- (void)openSafariViewInternalWithURL:(NSString*)url
{
    // 
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.window.rootViewController.presentedViewController != nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }

    void (^loadSFSafariViewControllerBlock)(NSURL *) = ^(NSURL *url) {
        SFSafariViewController* sfSafariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
        sfSafariViewController.delegate = self;
        [self presentViewController:sfSafariViewController animated:YES completion:nil];
    };
    loadSFSafariViewControllerBlock([NSURL URLWithString: [viewModel checkUrlString:url]]);
}

- (void)openInitialGuide
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialGuide" bundle:[NSBundle mainBundle]];
    InitialGuideViewController *controller = (InitialGuideViewController*)[storyboard instantiateViewControllerWithIdentifier:@"InitialGuideViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)openHelpView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"help"];
    WebViewController* webView = [[WebViewController alloc] initWithURL: [NSString stringWithFormat:@"file://%@", path]];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:webView];
    [webView presentationDeviceView:nav];
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

//--------------------------------------------------------------//
#pragma mark - GHHeaderViewDelegate delegate
//--------------------------------------------------------------//
- (void)urlUpadated:(NSString*)urlStr
{
    [self openSafariViewInternalWithURL:urlStr];
}

//--------------------------------------------------------------//
#pragma mark - SFSafariViewController Delegate Methods
//--------------------------------------------------------------//

-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {

}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Notification Center

/**
 * ブックマークのアドレスをwebで表示する
 * 表示するurlはNSNotificationのモデル、PAGE_URLキーに入っている
 * @param notif 通知モデル
 */
- (void)showWebPage:(NSNotification*)notif
{
    NSString *url = [viewModel makeURLFromNotification: notif];
    [self performSelector:@selector(openSafariViewInternalWithURL:) withObject:url afterDelay:0.75];
}

- (void) enterForeground:(NSNotification *)notification
{
    // foregroundに来た事を検知した時点では、このアプリを起動したカスタムURLを取得できない。
    // なので、カスタムURLを取得するGHAppDelegateにカスタムURLを引数に取って処理を行うコールバックを渡しておく。
    //ホームランチャーとSafariから起動されたことを区別するため初期化する
    id<UIApplicationDelegate> appDelegate
    = [UIApplication sharedApplication].delegate;
    if ([appDelegate isKindOfClass:[AppDelegate class]]) {
        [(AppDelegate *)appDelegate
         setURLLoadingCallback:^(NSURL* redirectURL){
             if (redirectURL) {
                 [self openSafariViewInternalWithURL:redirectURL.absoluteString];
             }
         }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewModel updateDeviceList];
        [viewModel updateDatasource];
        [self.collectionView reloadData];
        [self addEmptyLabelIfNeeded];
    });
}

//--------------------------------------------------------------//
#pragma mark - collectionViewDelegate
//--------------------------------------------------------------//
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [(NSMutableArray*)[viewModel.datasource objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [viewModel.datasource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case Bookmark:
        {
            BookmarkIconViewCell* cell = (BookmarkIconViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"BookmarkIconViewCell" forIndexPath:indexPath];
            Page* page = [[viewModel.datasource objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
            if ([page isKindOfClass:[GHPageModel class]] && [page.type isEqualToString: TYPE_BOOKMARK_DUMMY]) {
                [cell setEnabled:NO];
            } else {
                [cell setBookmark:page];
                __weak ViewController *weakSelf = self;
                [cell setDidIconSelected: ^(Page* page){
                    [weakSelf openSafariViewInternalWithURL:page.url];
                }];
            }
            return cell;
        }
            break;
        case Device:
        {
            if ([viewModel.datasource count] < indexPath.section) {
                break;
            }
            if ([(NSMutableArray*)[viewModel.datasource objectAtIndex:indexPath.section] count] < indexPath.row) {
                break;
            }
            DConnectMessage* message = [[viewModel.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            if([message isKindOfClass:[DConnectMessage class]]) {
                DeviceIconViewCell* cell = (DeviceIconViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceIconViewCell" forIndexPath:indexPath];
                [cell setDevice:message];
                __weak ViewController *weakSelf = self;
                [cell setDidIconSelected: ^(DConnectMessage* message) {
                    [weakSelf openDeviceDetail: message];
                }];
                return cell;
            } else {
                DeviceMoreViewCell* cell = (DeviceMoreViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceDetailIcon" forIndexPath:indexPath];
                __weak ViewController *weakSelf = self;
                [cell setDidDeviceMorelected: ^() {
                    [weakSelf performSegueWithIdentifier:@"OpenDeviceList" sender:nil];
                }];
                return cell;
            }
        }
            break;
        default:
            break;
    }
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookmarkIconViewCell" forIndexPath:indexPath];
    return cell;
}

- (TopCollectionHeaderView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    TopCollectionHeaderView* header = (TopCollectionHeaderView*)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerCell" forIndexPath:indexPath];
    if (indexPath.section == Bookmark) {
        header.titleLabel.text = @"ブックマーク";
    } else {
        header.titleLabel.text = @"デバイス";
    }
    return header;
}

- (IBAction)didSelectItem:(UICollectionViewCell*)sender
{
    if ( [sender isKindOfClass:[BookmarkIconViewCell class]]) {
        BookmarkIconViewCell* cell = (BookmarkIconViewCell*)sender;
        [self openSafariViewInternalWithURL:cell.viewModel.page.url];
    }
}


//--------------------------------------------------------------//
#pragma mark - TopViewModelDelegate
//--------------------------------------------------------------//
- (void)requestDatasourceReload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadSections: [NSIndexSet indexSetWithIndex:Device]];
        [self addEmptyLabelIfNeeded];
    });
}

@end
