//
//  DPHueSettingViewControllerBase.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHueSettingViewControllerBase.h"

@implementation DPHueSettingViewControllerBase

static DPHueItemBridge *mSelectedItemBridge;


- (void)viewDidLoad
{
    [super viewDidLoad];
    portConstraints = [NSArray array];
    landConstraints = [NSArray array];
    manager = [DPHueManager sharedManager];
    [manager initHue];
    _bundle = DPHueBundle();
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //起動時の位置合わせ
    [self setLayoutConstraint];

}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft
       || orientation == UIInterfaceOrientationLandscapeRight)
    {
        [NSLayoutConstraint deactivateConstraints:portConstraints];
        [NSLayoutConstraint activateConstraints:landConstraints];
    } else {
        [NSLayoutConstraint deactivateConstraints:landConstraints];
        [NSLayoutConstraint activateConstraints:portConstraints];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
 
    [self setLayoutConstraint];
    
}

- (void)setLayoutConstraint
{
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
        [self setLayoutConstraintPortrait];
    } else {
        [self setLayoutConstraintLandscape];
    }
}

//縦向き座標調整
- (void)setLayoutConstraintPortrait
{
    // nop
}

//横向き座標調整
- (void)setLayoutConstraintLandscape
{
    // nop
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [manager deallocHueSDK];
}

- (void)showAleart:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"hue"
                          message:msg delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
}

- (BOOL)ipad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (BOOL)iphone
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

- (BOOL)ipadMini
{
    if (!self.ipad) {
        return false;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    return ((int)rect.size.height <= 1024);
}

- (BOOL)iphone5
{
    if (!self.iphone) {
        return false;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];

    return ((int)rect.size.height == 568);
    
}
- (BOOL)iphone6
{
    if (!self.iphone) {
        return false;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    return ((int)rect.size.height == 667);
    
}

- (BOOL)iphone6p
{
    if (!self.iphone) {
        return false;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    return ((int)rect.size.height == 736);
    
}

- (void)setSelectedItemBridge:(DPHueItemBridge*)itemBridge
{
    
    mSelectedItemBridge = itemBridge.copy;
    
}


- (void)initSelectedItemBridge
{
    mSelectedItemBridge = nil;
    mSelectedItemBridge = [[DPHueItemBridge alloc] init];
}

- (DPHueItemBridge*)getSelectedItemBridge
{
    if (mSelectedItemBridge == nil) {
        [self initSelectedItemBridge];
    }
    return mSelectedItemBridge;
}

- (BOOL)isSelectedItemBridge
{
    if (mSelectedItemBridge == nil) {
        return NO;
    }
    return YES;
}

- (void)showPage:(NSUInteger)jumpIndex
{
    [self.hueViewController showPage:jumpIndex];
}

//ブリッジ検索ページを開く
- (void)showBridgeListPage
{
    [self showPage:0];
}

//アプリ登録ページを開く
- (void)showAuthPage
{
    [self showPage:1];
}

//ライト検索ページを開く
- (void)showLightSearchPage
{
    [self showPage:2];
}


//ライト一覧ページを開く
- (void)showLightListPage
{
    [self showPage:3];
}

- (void) setCloseBtn:(BOOL)closeEnable {
    self.root.navigationItem.leftBarButtonItem.enabled = closeEnable;
}

@end
