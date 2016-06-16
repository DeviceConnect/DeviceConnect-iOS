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

@interface ViewController (){}

@property (nonatomic, strong) GHURLManager *manager;
@property (nonatomic) NSString* url;
@property (nonatomic, strong) IBOutlet GHHeaderView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)openBookmarkView:(id)sender;
- (IBAction)openSettingView:(id)sender;
- (IBAction)onTapView:(id)sender;

@end

@implementation ViewController

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

    DConnectManager *mgr = [DConnectManager sharedManager];

    [super viewDidLoad];

    BOOL isOriginBlock = [[NSUserDefaults standardUserDefaults] boolForKey:IS_ORIGIN_BLOCKING];
    mgr.settings.useOriginBlocking = isOriginBlock;

    _manager = [[GHURLManager alloc]init];
    _url = @"http://www.google.com";

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
    DConnectManager *mgr = [DConnectManager sharedManager];
    [[NSUserDefaults standardUserDefaults] setBool:mgr.settings.useOriginBlocking forKey:IS_ORIGIN_BLOCKING];
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

    //文字列がURLの場合
    _url = [self.manager isURLString:url];
    if ([url rangeOfString:@"#"].location != NSNotFound) {
        _url = url;
    } else if (!_url) {
        _url = [self.manager createSearchURL:url];
    }
    void (^loadSFSafariViewControllerBlock)(NSURL *) = ^(NSURL *url) {
        SFSafariViewController* sfSafariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
        sfSafariViewController.delegate = self;
        [self presentViewController:sfSafariViewController animated:YES completion:nil];
    };
    loadSFSafariViewControllerBlock([NSURL URLWithString:_url]);
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
    NSDictionary *dict = notif.userInfo;
    _url = [dict objectForKey:PAGE_URL];
    
    NSString *url = [self.manager isURLString:_url];
    if ([_url rangeOfString:@"%23"].location != NSNotFound) {
        _url = [_url stringByReplacingOccurrencesOfString:@"%23" withString:@"#"] ;
    } else if (!url) {
        url = [self.manager createSearchURL:url];
    } 
    [self performSelector:@selector(openSafariViewInternalWithURL:) withObject:_url afterDelay:0.75];
    

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
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 8;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bookmarkCell" forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView* header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerCell" forIndexPath:indexPath];
    return header;
}

@end
