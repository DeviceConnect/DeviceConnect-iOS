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

@interface ViewController (){
    SFSafariViewController *sfSafariViewController;
}

@property (nonatomic, strong) GHURLManager *manager;
@property (nonatomic) NSString* url;
#pragma mark - View position constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTopLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeftLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerLeftLeading;
@property (strong, nonatomic) IBOutlet GHHeaderView *searchView;
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
    DConnectManager *mgr = [DConnectManager sharedManager];
    [mgr startByHttpServer];

    [super viewDidLoad];
    CGFloat barW = 300;
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL isOriginBlock = [def boolForKey:IS_ORIGIN_BLOCKING];
    mgr.settings.useOriginBlocking = isOriginBlock;

 
    CGRect frame = CGRectMake(0, 0, barW, 44);
    _manager = [[GHURLManager alloc]init];
    _url = @"http://www.google.com";
    GHHeaderView *view = [[GHHeaderView alloc]initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.delegate = self;
    [_searchView addSubview:view];
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
// View表示時
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rotateOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

// View回転時
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self rotateOrientation:toInterfaceOrientation];
}

#pragma mark - open UI

- (IBAction)openSafariView:(id)sender {
    void (^loadSFSafariViewControllerBlock)(NSURL *) = ^(NSURL *url) {
        sfSafariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
        sfSafariViewController.delegate = self;
        [self presentViewController:sfSafariViewController animated:YES completion:nil];
    };
    loadSFSafariViewControllerBlock([NSURL URLWithString:_url]);
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
    
}

- (void)reload
{
}


- (void)cancelLoading
{
}


#pragma mark - SFSafariViewController Delegate Methods
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
    _iconHeightSize.constant = 200;
    _iconHeightSize.constant = 200;
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait |
        toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        _iconTopLeading.constant = 8;
        _iconLeftLeading.constant = 60;
        _headerLeftLeading.constant = 10;
        _openRightLeading.constant = 90;
        _bookmarkRightLeading.constant = 90;
        _settingRightLeading.constant = 90;
    } else {
        _iconTopLeading.constant = 10;
        _iconLeftLeading.constant = 50;
        _headerLeftLeading.constant = 30;
        _searchViewLeading.constant = 250;
        _openRightLeading.constant = 70;
        _bookmarkRightLeading.constant = 70;
        _settingRightLeading.constant = 70;
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
        _settingBtnBottomLeading.constant = 100;
        _iconTopLeading.constant = 50;
        _iconLeftLeading.constant = (screen.width / 2) - 200;
        _headerLeftLeading.constant = (screen.width / 2) - 250;
        
    } else {
        
        _openRightLeading.constant = (screen.width / 2) - 400;
        _bookmarkRightLeading.constant = (screen.width / 2) - 400;
        _settingRightLeading.constant = (screen.width / 2) - 400;
        
        
        _settingBtnBottomLeading.constant = 300;
        _iconTopLeading.constant = 100;
        _iconLeftLeading.constant = (screen.width / 2) - 450;
        _headerLeftLeading.constant = (screen.width / 2) - 500;
        
    }
}

@end
