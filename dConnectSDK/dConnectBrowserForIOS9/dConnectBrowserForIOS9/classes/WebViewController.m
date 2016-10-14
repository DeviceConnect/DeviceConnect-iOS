//
//  WebViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "WebViewController.h"
#import <objc/runtime.h>

static const char kAssocKey_Window;
@interface DeviceConnectWindow : UIWindow

@end

@implementation DeviceConnectWindow

-(void)dealloc
{
}

@end

@interface WebViewController ()
@property (nonatomic, strong) WKWebView* webView;
@end

@implementation WebViewController

- (instancetype)initWithURL:(NSString*)urlString
{
    self = [super init];
    if (self) {
        [self setupWebView];
        [self loadRequest: urlString];
    }
    return self;
}

- (instancetype)initWithPath:(NSString*)path
{
    self = [super init];
    if (self) {
        [self setupWebView];
        [self loadLocalFile: path];
    }
    return self;
}


- (void)dealloc
{
    self.webView = nil;
}


//--------------------------------------------------------------//
#pragma mark - webView setup
//--------------------------------------------------------------//
- (void)setupWebView
{
    self.webView = [[WKWebView alloc]init];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:0]
                                ]];

}

- (void)loadRequest:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString: urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}

- (void)loadLocalFile:(NSString*)path
{
    NSString* html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:nil];
}

//--------------------------------------------------------------//
#pragma mark - WKNavigationDelegate
//--------------------------------------------------------------//
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = webView.title;
}

//--------------------------------------------------------------//
#pragma mark - view cycle
//--------------------------------------------------------------//
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithTitle:@"閉じる"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = closeButton;
}

- (void)close:(UIBarButtonItem*)item
{
    UIWindow *window = objc_getAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window);
    
    [UIView transitionWithView:window
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        UIView *view = window.rootViewController.view;
                        
                        for (UIView *v in view.subviews) {
                            v.transform = CGAffineTransformMakeScale(.8, .8);
                        }
                        
                        window.alpha = 0;
                    }
                    completion:^(BOOL finished) {
                        
                        [window.rootViewController.view removeFromSuperview];
                        window.rootViewController = nil;
                        
                        // 上乗せしたウィンドウを破棄
                        objc_setAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        
                        // メインウィンドウをキーウィンドウにする
                        UIWindow *nextWindow = [[UIApplication sharedApplication].delegate window];
                        [nextWindow makeKeyAndVisible];
                    }];

}


#pragma mark - Public method
- (void)presentationDeviceView:(UIViewController*)viewController
{
    UIWindow *window = [[DeviceConnectWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.alpha = 0.2;
    window.transform = CGAffineTransformMakeScale(1.0, 1.0);
    window.rootViewController = viewController;
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    window.windowLevel = UIWindowLevelNormal + 5;
    
    [window makeKeyAndVisible];
    
    objc_setAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [UIView transitionWithView:window duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut animations:^{
        window.alpha = 1.;
        window.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];

}

@end
