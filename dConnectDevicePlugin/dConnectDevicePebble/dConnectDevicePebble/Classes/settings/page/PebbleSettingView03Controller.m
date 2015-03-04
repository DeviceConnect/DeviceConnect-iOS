//
//  PebbleSettingView03Controller.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "PebbleSettingView03Controller.h"
#import "pebble_device_plugin_defines.h"

@interface PebbleSettingView03Controller ()
- (IBAction)getToPebble:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHorizontal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *
textHeight;

@end
#define Sideways_Image_w 20
#define Portrait_Image_w 95
#define TEXT_W 20
#define TEXT_H 85
@implementation PebbleSettingView03Controller

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
        
        _textHorizontal.constant=21+(margin/3);
        _textHeight.constant=TEXT_H-30;
        _leadingConstraint.constant =(margin/3)+ Sideways_Image_w;
    }    //回転時に処理したい内容
    
}


- (IBAction)getToPebble:(id)sender {
    NSURL *myURL = [NSURL URLWithString: @"https://itunes.apple.com/jp/app/pebble-smartwatch/id592012721?mt=8"];
    
    [[UIApplication sharedApplication] openURL:myURL];
    
    
}
@end
