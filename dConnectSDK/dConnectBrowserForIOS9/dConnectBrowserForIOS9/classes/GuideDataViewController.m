//
//  GuideDataViewController.m
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import "GuideDataViewController.h"

@interface GuideDataViewController ()

@end

@implementation GuideDataViewController
+ (instancetype)instantiateWithFilename:(NSString*)filename
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"InitialGuide" bundle:[NSBundle mainBundle]];
    GuideDataViewController *controller = (GuideDataViewController*)[storyboard instantiateViewControllerWithIdentifier:@"GuideDataViewController"];
    controller.imageView.image = [UIImage imageNamed:filename];
    return controller;
}

- (IBAction)didTappedCloseButton:(UIButton *)sender {
    _closeButtonCallback();
}

- (void)dealloc
{
    _closeButtonCallback = nil;
}

@end
