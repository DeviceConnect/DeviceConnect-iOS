//
//  DPIRKitVirtualDeviceCreateDialog.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPIRKitDialog.h"

@interface DPIRKitVirtualDeviceCreateDialog : DPIRKitDialog<UITextFieldDelegate>
+(void)showWithServiceId:(NSString*)serviceId
                 categoryName:(NSString*)categoryName;
@end
