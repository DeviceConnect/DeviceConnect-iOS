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
