//
//  ViewController.m
//  dConnectBrowserForIOS9
//
//  Created by 星　貴之 on 2016/02/15.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "ViewController.h"
#import "GHHeaderView.h"

@interface ViewController ()

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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat barW = 300;
    
    //iPadの場合はナビゲーションにボタンを置く
//    if ([GHUtils isiPad]) {
//        [self iPadSetup];
//        barH = 80;
//    }
    CGRect frame = CGRectMake(0, 0, barW, 44);
    GHHeaderView *view = [[GHHeaderView alloc]initWithFrame:frame];
//    self.searchView.delegate = self;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _searchView.delegate = self;
    [_searchView addSubview:view];
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
