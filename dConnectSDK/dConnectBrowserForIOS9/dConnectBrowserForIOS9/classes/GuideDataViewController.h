//
//  GuideDataViewController.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
