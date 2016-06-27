//
//  GuideDataViewController.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GuideDataViewController.h"

@interface GuideDataViewController ()
@property (nonatomic, strong) NSString* filename;
@property (nonatomic) BOOL isLastPage;
@end

@implementation GuideDataViewController
+ (instancetype)instantiateWithFilename:(NSString*)filename
                        withPageNaumber:(NSInteger)pageNumber
                             isLastPage:(BOOL)isLastPage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialGuide" bundle:[NSBundle mainBundle]];
    GuideDataViewController *controller = (GuideDataViewController*)[storyboard instantiateViewControllerWithIdentifier:@"GuideDataViewController"];
    controller.filename = filename;
    controller.isLastPage = isLastPage;
    controller.pageNumber = pageNumber;
    return controller;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.closeButton.layer.cornerRadius = 8;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = [UIImage imageNamed: self.filename];
    [self setCloseButtonEnabled: self.isLastPage];
}

- (void)setCloseButtonEnabled:(BOOL)isEnabled
{
    self.closeButton.hidden = !isEnabled;
    self.closeButton.enabled = isEnabled;
}

- (IBAction)didTappedCloseButton:(UIButton *)sender {
    _closeButtonCallback();
}

- (void)dealloc
{
    _closeButtonCallback = nil;
}

@end
