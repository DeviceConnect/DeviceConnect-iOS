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

@interface ViewController ()
{
    TopViewModel *viewModel;
}

@property (nonatomic, strong) IBOutlet GHHeaderView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)openBookmarkView:(id)sender;
- (IBAction)openSettingView:(id)sender;
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [viewModel finishOriginBlock];
}

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


//--------------------------------------------------------------//
#pragma mark - open UI
//--------------------------------------------------------------//

- (IBAction)openBookmarkView:(id)sender {
    //ストーリーボードから取得
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:[NSBundle mainBundle]];
    UIViewController *bookmark = [storyboard instantiateInitialViewController];
    [self presentViewController:bookmark animated:YES completion:nil];
}

- (IBAction)openSettingView:(id)sender {
    GHSettingController *setting = [[GHSettingController alloc]initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:setting];
    [self presentViewController:nav animated:YES completion:nil];
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
//            [cell setBookmark:page];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerCell" forIndexPath:indexPath];
    return header;
}

@end
