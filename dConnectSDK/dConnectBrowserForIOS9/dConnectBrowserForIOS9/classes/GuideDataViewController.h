//
//  GuideDataViewController.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/24.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CloseButtonCallback)();
@interface GuideDataViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic) NSInteger pageNumber;
@property (copy, nonatomic) CloseButtonCallback closeButtonCallback;

+ (instancetype)instantiateWithFilename:(NSString*)filename
                        withPageNaumber:(NSInteger)pageNumber;

@end
