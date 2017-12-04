//
//  PebbleSettingView04Controller.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "PebbleSettingView04Controller.h"
#import "pebble_device_plugin_defines.h"

@interface PebbleSettingView04Controller ()
- (IBAction)getTopPugin:(id)sender;
- (IBAction)getToPebble:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *installButton;
@property (nonatomic) UIDocumentInteractionController *docInterCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHorizontal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *
textHeight;

@end
#define Sideways_Image_w 30
#define Portrait_Image_w 99
#define TEXT_W 20
#define TEXT_H 100

@implementation PebbleSettingView04Controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setPage:[UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    
    [self setPage:UIInterfaceOrientationIsPortrait(interfaceOrientation)];
}
-(void)setPage:(BOOL)isPortrait{
    int iphon4_h=IPONE4_H;
    CGRect rect = [[UIScreen mainScreen] bounds];
    int height = (int)rect.size.height;
    int margin=0;
    if(height>iphon4_h){
        margin=(height-iphon4_h);
        
    }
    
    
    if (isPortrait) {
        
        _leadingConstraint.constant = Portrait_Image_w;
        _textHorizontal.constant=TEXT_W;
        _textHeight.constant=TEXT_H+margin;
    } else {
        
        _textHorizontal.constant=TEXT_W+(margin/3);
        _textHeight.constant=TEXT_H;
        _leadingConstraint.constant =(margin/3)+ Sideways_Image_w;
    }    //回転時に処理したい内容
    
}


-(IBAction)getTopPugin:(id)sender {
//pebble側アプリのインストール
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDevicePebble_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *dataFilePath = [bundle pathForResource:@"dConnectDevicePebble" ofType:@"pbw"];
    
    NSURL *url = [NSURL fileURLWithPath:dataFilePath];
    self.docInterCon = [UIDocumentInteractionController interactionControllerWithURL:url];
    BOOL isValid = [self.docInterCon presentOpenInMenuFromRect:self.installButton.frame inView:self.view animated:NO];
    if (!isValid) {
        //pebble管理アプリが無い時のアラートを生成
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"\"3.Pebble管理アプリの実行\"を行ってください"
                                     message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* closeButton = [UIAlertAction
                                    actionWithTitle:@"Close"
                                    style:UIAlertActionStyleDefault
                                    handler:nil];
        
        [alert addAction:closeButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}

- (IBAction)getToPebble:(id)sender {
    NSURL *myURL = [NSURL URLWithString: @"https://itunes.apple.com/jp/app/pebble/id957997620?mt=8"];
    
    [[UIApplication sharedApplication] openURL:myURL];
    
    
}
@end
