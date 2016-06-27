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
#import "TopViewModel.h"
#import "TopCollectionHeaderView.h"
#import "InitialGuideViewController.h"
#import "WebViewController.h"

@interface ViewController ()
{
    TopViewModel *viewModel;
}

@property (nonatomic, strong) IBOutlet GHHeaderView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UILabel* emptyBookmarksLabel;
@property (strong, nonatomic) UILabel* emptyDevicesLabel;

- (IBAction)openBookmarkView:(id)sender;
- (IBAction)onTapView:(id)sender;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        viewModel = [[TopViewModel alloc]init];
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
    [viewModel updateDatasource];
    [self.collectionView reloadData];
    [self addEmptyLabelIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([viewModel isNeedOpenInitialGuide]) {
        [self openInitialGuide];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [viewModel saveOriginBlock];
}

// landscape時にはステータスバーが無くなるのでその分headerViewの高さを短くする
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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
        self.emptyBookmarksLabel = [self makeEmptyLabel: CGRectMake(0, 50, 320, 220)
                                             message:@"ブックマークがありません。\nブックマークを登録してください。"];
        [self.collectionView addSubview:self.emptyBookmarksLabel];
    } else {
        [self.emptyBookmarksLabel removeFromSuperview];
        self.emptyBookmarksLabel = nil;
    }

    if (viewModel.isDeviceEmpty) {
        self.emptyDevicesLabel = [self makeEmptyLabel: CGRectMake(0, 300, 320, 220)
                                             message:@"デバイスが接続されていません。\nプラグインから設定を行ってください。"];
        [self.collectionView addSubview:self.emptyDevicesLabel];
    } else {
        [self.emptyDevicesLabel removeFromSuperview];
        self.emptyDevicesLabel = nil;
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
    AppDelegate* delegate = [UIApplication sharedApplication].delegate;
    if (delegate.window.rootViewController.presentedViewController != nil) {
        [self dismissViewControllerAnimated:false completion:nil];
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
    NSString* path = [[NSBundle mainBundle]pathForResource:@"help" ofType:@"html"];
    WebViewController* webView = [[WebViewController alloc]initWithPath: path];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:webView];
    [self presentViewController:nav animated:YES completion:nil];
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
}

//--------------------------------------------------------------//
#pragma mark - collectionViewDelegate
//--------------------------------------------------------------//
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[viewModel.datasource objectAtIndex:section]count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [viewModel.datasource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
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
        case 1:
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
    if (indexPath.section == 0) {
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
@end
