//
//  DConnectAllowlistUtil.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DConnectAllowlistUtil.h"
#import "DConnectAllowlistViewController.h"

@implementation DConnectAllowlistUtil

+ (void) showOriginAllowlist
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle *bundle = DCBundle();
        UIStoryboard *storyBoard;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@-iPhone",
                                                           DConnectStoryboardName]
                                                   bundle:bundle];
        } else{
            storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@-iPad",
                                                           DConnectStoryboardName]
                                                   bundle:bundle];
        }
        
        UINavigationController *top = [storyBoard instantiateViewControllerWithIdentifier:@"OriginAllowlist"];
        UIViewController *rootView;
        DCPutPresentedViewController(rootView);
        [rootView presentViewController:top animated:YES completion:nil];
    });
}

@end
