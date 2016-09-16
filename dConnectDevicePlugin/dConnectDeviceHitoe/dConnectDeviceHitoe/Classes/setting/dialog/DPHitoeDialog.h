//
//  DPHitoeDialog.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>


@interface DPHitoeDialog : UIViewController {
}


+ (void)doShowForWindow:(UIWindow *)w
         storyboardName:(NSString*)storyboardName;
+ (void)doClose;
@end
