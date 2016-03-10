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
@interface ViewController (){
    SFSafariViewController *sfSafariViewController;
}

@property (nonatomic, strong) GHURLManager *manager;
@property (nonatomic) NSString* url;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic, strong) GHHeaderView *headerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTopLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHeightSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHeightSize;
- (IBAction)openBookmarkView:(id)sender;
- (IBAction)openSettingView:(id)sender;

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
    CGFloat barW = 300;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    BOOL isOriginBlock = [def boolForKey:IS_ORIGIN_BLOCKING];
    mgr.settings.useOriginBlocking = isOriginBlock;

    CGRect frame = CGRectMake(15, 10, barW, 44);
    _manager = [[GHURLManager alloc]init];
    _url = @"http://www.google.com";
    _headerView = [[GHHeaderView alloc] initWithFrame:frame];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerView.delegate = self;
    [_searchView addSubview:_headerView];
    
    //ブックマークのweb表示通知
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(showWebPage:)
                                                name:SHOW_WEBPAGE object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DConnectManager *mgr = [DConnectManager sharedManager];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:mgr.settings.useOriginBlocking forKey:IS_ORIGIN_BLOCKING];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rotateOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(enterForeground:)
                   name:UIApplicationWillEnterForegroundNotification object:nil];

}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self rotateOrientation:toInterfaceOrientation];
}

- (void)dealloc
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - open UI


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

- (void)openSafariViewInternalWithURL:(NSString*)url
{
    //文字列がURLの場合
    _url = [self.manager isURLString:url];
    if (!_url) {
        _url = [self.manager createSearchURL:url];
    } else {
        _url = url;
    }
    void (^loadSFSafariViewControllerBlock)(NSURL *) = ^(NSURL *url) {
        sfSafariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
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
    NSString *u = _headerView.searchBar.text;
    [self openSafariViewInternalWithURL:u];
}

- (void)reload
{
    NSString *u = _headerView.searchBar.text;
    [self openSafariViewInternalWithURL:u];
}


- (void)cancelLoading
{
}

//--------------------------------------------------------------//
#pragma mark - SFSafariViewController Delegate Methods
//--------------------------------------------------------------//

-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {

}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [sfSafariViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - private method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
- (void)rotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self iphoneLayoutWithOrientation:toInterfaceOrientation];
    } else {
        [self ipadLayoutWithOrientation:toInterfaceOrientation];
    }
    [self.view setNeedsUpdateConstraints];
}

- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIDeviceOrientationLandscapeRight))
    {
        _iconTopLeading.constant = 35;
    } else {
        _iconTopLeading.constant = 70;
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
    _iconHeightSize.constant = 400;
    _iconWidthSize.constant = 400;
    _searchViewWidthSize.constant = 500;
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
    if (!url) {
        url = [self.manager createSearchURL:url];
    } else {
        _url = url;
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

@end
