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
#import "GHAddBookmarkActivity.h"
#import "AppDelegate.h"
@interface ViewController (){
    SFSafariViewController *sfSafariViewController;
}

@property (nonatomic, strong) GHURLManager *manager;
@property (nonatomic) NSString* url;
@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic, strong) GHHeaderView *headerView;

#pragma mark - View position constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTopLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeftLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerLeftLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openRightLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkRightLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingRightLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingBtnBottomLeading;
#pragma mark - button size constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHeightSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHeightSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openBtnHeightSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *openBtnWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkBtnHeightSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookmarkBtnWidthSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingBtnHeightSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingBtnWidthSize;
#pragma mark - UI
- (IBAction)openSafariView:(id)sender;
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
    BOOL sw = [def boolForKey:IS_MANAGER_LAUNCH];
    if (sw) {
        [mgr startByHttpServer];
    }

    BOOL isOriginBlock = [def boolForKey:IS_ORIGIN_BLOCKING];
    mgr.settings.useOriginBlocking = isOriginBlock;

 
    CGRect frame = CGRectMake(0, 0, barW, 44);
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

- (IBAction)openSafariView:(id)sender {
    
    NSString *u = _headerView.searchBar.text;
    [self openSafariViewInternalWithURL:u];
}

- (IBAction)openBookmarkView:(id)sender {
    //ストーリーボードから取得
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Popup" bundle:[NSBundle mainBundle]];
    UIViewController *bookmark = [storyboard instantiateInitialViewController];
    
    
//    if ([GHUtils isiPad]) {
//        [self showPopup:bookmark button:item];
//    }else{
        [self presentViewController:bookmark animated:YES completion:nil];
//    }

}

- (IBAction)openSettingView:(id)sender {
    GHSettingController *setting = [[GHSettingController alloc]initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:setting];
//    if ([GHUtils isiPad]) {
//        [self showPopup:nav button:settingBtn];
//    }else{
        [self presentViewController:nav animated:YES completion:nil];
//    }

}

- (void)openSafariViewInternalWithURL:(NSString*)url
{
    if (url.length == 0) {
        url = @"http://www.google.com";
    }
    void (^loadSFSafariViewControllerBlock)(NSURL *) = ^(NSURL *url) {
        sfSafariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
        sfSafariViewController.delegate = self;
        [self presentViewController:sfSafariViewController animated:YES completion:nil];
    };
    loadSFSafariViewControllerBlock([NSURL URLWithString:url]);
}

//--------------------------------------------------------------//
#pragma mark - GHHeaderViewDelegate delegate
//--------------------------------------------------------------//

- (void)urlUpadated:(NSString*)urlStr
{
    //文字列がURLの場合
    _url = [self.manager isURLString:urlStr];
    if (!_url) {
        _url = [self.manager createSearchURL:urlStr];
    }
    [self openSafariViewInternalWithURL:_url];
}

- (void)reload
{
}


- (void)cancelLoading
{
}

//--------------------------------------------------------------//
#pragma mark - SFSafariViewController Delegate Methods
//--------------------------------------------------------------//

-(void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    // Load finished
    //    if (didLoadSuccessfully) {
    //        NSLog(@"SafariViewController: Loading of URl finished");
    //    }
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    //    NSLog(@"safariViewController: Done button pressed");
    [sfSafariViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - private method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}
- (void)rotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    _searchViewLeading.constant = 300;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self iphoneLayoutWithOrientation:toInterfaceOrientation];
    } else {
        [self ipadLayoutWithOrientation:toInterfaceOrientation];
    }
    [self.view setNeedsUpdateConstraints];
}

- (void)iphoneLayoutWithOrientation:(int)toInterfaceOrientation
{
    CGSize screen = [UIScreen mainScreen].bounds.size;

    _iconHeightSize.constant = 200;
    _iconHeightSize.constant = 200;
    if ((toInterfaceOrientation == UIDeviceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIDeviceOrientationLandscapeRight)
        && screen.width < screen.height)
    {
        _iconTopLeading.constant = 10;
        _iconLeftLeading.constant = (screen.height / 2) - 230;
        _headerLeftLeading.constant = (screen.height / 2) - 280;
        _openRightLeading.constant = (screen.height / 2) - 200;
        _bookmarkRightLeading.constant = (screen.height / 2) - 200;
        _settingRightLeading.constant = (screen.height / 2) - 200;
        _settingBtnBottomLeading.constant = (screen.height / 2)  - 200;
    } else {
        if (screen.width < screen.height) {
            _iconTopLeading.constant = (screen.height / 2) - 250;
            _iconLeftLeading.constant = (screen.width / 2) - 100;
            _headerLeftLeading.constant = (screen.width / 2) - 150;
            _settingBtnBottomLeading.constant = (screen.height / 2) - 250;
            _openRightLeading.constant = (screen.width / 2) - 67;
            _bookmarkRightLeading.constant = (screen.width / 2) - 67;
            _settingRightLeading.constant = (screen.width / 2) - 67;
        } else {
            _iconTopLeading.constant = (screen.width / 2) - 250;
            _iconLeftLeading.constant = (screen.height / 2) - 100;
            _headerLeftLeading.constant = (screen.height / 2) - 150;
            _settingBtnBottomLeading.constant = (screen.width / 2) - 250;
            _openRightLeading.constant = (screen.height / 2) - 67;
            _bookmarkRightLeading.constant = (screen.height / 2) - 67;
            _settingRightLeading.constant = (screen.height / 2) - 67;
        }
    }
}

- (void)ipadLayoutWithOrientation:(int)toInterfaceOrientation
{
    CGSize screen = [UIScreen mainScreen].bounds.size;
    _iconHeightSize.constant = 400;
    
    _iconWidthSize.constant = 400;
    _searchViewWidthSize.constant = 500;
    _openBtnWidthSize.constant = 270;
    _openBtnHeightSize.constant = 80;
    _bookmarkBtnWidthSize.constant = 270;
    _bookmarkBtnHeightSize.constant = 80;
    _settingBtnWidthSize.constant = 270;
    _settingBtnHeightSize.constant = 80;
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait |
        toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        _openRightLeading.constant = (screen.width / 2) - 138;
        _bookmarkRightLeading.constant = (screen.width / 2) - 138;
        _settingRightLeading.constant = (screen.width / 2) - 138;
        _settingBtnBottomLeading.constant = (screen.height / 2) - 400;
        _iconTopLeading.constant = 50;
        _iconLeftLeading.constant = (screen.width / 2) - 200;
        _headerLeftLeading.constant = (screen.width / 2) - 250;
        
    } else {
        
        _openRightLeading.constant = (screen.width / 2) - 400;
        _bookmarkRightLeading.constant = (screen.width / 2) - 400;
        _settingRightLeading.constant = (screen.width / 2) - 400;
        
        _settingBtnBottomLeading.constant = (screen.height / 2) - 50;
        _iconTopLeading.constant = (screen.height / 2) - 300;
        _iconLeftLeading.constant = (screen.width / 2) - 450;
        _headerLeftLeading.constant = (screen.width / 2) - 500;
        
    }
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
    
    _url = [self.manager isURLString:_url];
    if (!_url) {
        _url = [self.manager createSearchURL:_url];
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
