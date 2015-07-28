//
//  DPIRKitDialog.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface DPIRKitDialog : UIViewController {
}

+ (void)doShowForWindow:(UIWindow *)w
         storyboardName:(NSString*)storyboardName;
+ (void)doClose;
@end
