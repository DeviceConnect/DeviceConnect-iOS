//
//  DPGuideViewController.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPGuideViewController.h"
@interface DPGuideViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;

@end

@implementation DPGuideViewController

// View表示時
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self rotateOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

// View回転時
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self rotateOrientation:toInterfaceOrientation];
}

// 位置合わせ
- (void)rotateOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (!_horizontalSpace) return;
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait
        | toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        // 上下のスペーサー復活
        if (![[self.view constraints] containsObject:_verticalSpace]
            && [_verticalSpace isKindOfClass:[NSLayoutConstraint class]]) {
            [self.view addConstraint:_verticalSpace];
        }
        // 下の位置
        _horizontalSpace.constant = 239;
    } else {
        // 上下のスペーサー除去
        if ([_verticalSpace isKindOfClass:[NSLayoutConstraint class]]) {
            [self.view removeConstraint:_verticalSpace];
        }
        // 右の位置
        _horizontalSpace.constant = -10;
    }
    // Topからの位置
    _topSpace.constant = self.navigationController.navigationBar.frame.size.height + 31;
}

// メッセージ表示
- (void)showAlertWithTitleKey:(NSString*)titleKey messageKey:(NSString*)messageKey
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceSphero_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString* disconnectTitle = [bundle localizedStringForKey:titleKey value:nil table:nil];
    NSString* failMessage = [bundle localizedStringForKey:messageKey value:nil table:nil];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:disconnectTitle
                                 message:failMessage
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:nil];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
