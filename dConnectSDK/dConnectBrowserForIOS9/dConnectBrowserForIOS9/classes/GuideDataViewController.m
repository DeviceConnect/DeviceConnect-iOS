//
//  GuideDataViewController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GuideDataViewController.h"

@interface GuideDataViewController ()
@property (nonatomic, strong) NSString* filename;
@end

@implementation GuideDataViewController
+ (instancetype)instantiateWithFilename:(NSString*)filename
                        withPageNaumber:(NSInteger)pageNumber
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialGuide" bundle:[NSBundle mainBundle]];
    GuideDataViewController *controller = (GuideDataViewController*)[storyboard instantiateViewControllerWithIdentifier:@"GuideDataViewController"];
    controller.filename = filename;
    controller.pageNumber = pageNumber;
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed: self.filename];
}

@end
