//
//  WebViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "WebViewController.h"
#import <DConnectSDK/DConnectSDK.h>
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
    self.webView.UIDelegate = self;
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest *request = navigationAction.request;
    NSURL *url = request.URL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
    if ([url.scheme isEqualToString:@"file"]) {
        // SSL通信フラグの存在確認
        NSArray<NSURLQueryItem *> *items = components.queryItems;
        for (NSURLQueryItem *item in items) {
            // すでに設定されている場合はここで終了. (コールバックの無限ループ回避)
            if ([item.name isEqualToString:@"ssl"]) {
                decisionHandler(WKNavigationActionPolicyAllow);
                return;
            }
        }
        
        // SSL通信フラグをHTMLアプリ側へ共有.
        BOOL useSSL = [DConnectManager sharedManager].settings.useSSL;
        NSURL *newURL = [[self components:components appendSSL:useSSL] URL];
        [webView loadRequest:[NSURLRequest requestWithURL:newURL]];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (NSURLComponents *)components:(NSURLComponents *)components appendSSL:(BOOL)useSSL
{
    // URLにsslパラメータを追加
    NSMutableArray<NSURLQueryItem *> *items = [NSMutableArray arrayWithArray:components.queryItems];
    NSURLQueryItem *ssl = [NSURLQueryItem queryItemWithName:@"ssl" value:(useSSL ? @"on" : @"off")];
    [items addObject:ssl];
    components.queryItems = items;
    return components;
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
- (void)viewWillAppear:(BOOL)animated {
    // デバイスプラグインの設定画面で、全体のナビゲーションバーの色を変えられた時のために、Browserデフォルトの色に戻す。
    self.navigationController.navigationBar.barTintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.tintColor =  [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].tintColor = [UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000];
    [UITabBar appearance].translucent = NO;
    [UITabBar appearance].barTintColor = [UIColor whiteColor];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.000 green:0.549 blue:0.890 alpha:1.000]];
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

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
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
