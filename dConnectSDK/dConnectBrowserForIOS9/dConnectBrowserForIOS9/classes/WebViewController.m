//
//  WebViewController.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (nonatomic, strong) WKWebView* webView;
@end

@implementation WebViewController

- (instancetype)initWithURL:(NSString*)urlString
{
    self = [super init];
    if (self) {
        [self setupWebView: urlString];
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
- (void)setupWebView:(NSString*)urlString
{
    self.webView = [[WKWebView alloc]init];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self loadRequest: urlString];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
