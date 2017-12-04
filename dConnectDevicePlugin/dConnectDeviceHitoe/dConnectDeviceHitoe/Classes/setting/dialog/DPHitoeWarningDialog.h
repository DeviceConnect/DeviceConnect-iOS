//
//  DPHitoeWarningDialog.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeDialog.h"

@interface DPHitoeWarningDialog : DPHitoeDialog
extern NSString *const DPHitoeWarningNever;
+ (void)showHitoeWarningDialogWithComplition:(void(^)(void))completion;

@end
