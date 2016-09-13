//
//  DPHitoePinCodeDialog.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <UIKit/UIKit.h>
#import "DPHitoeDialog.h"
#import "DPHitoeDevice.h"


@interface DPHitoePinCodeDialog : DPHitoeDialog
+(void)showPinCodeDialogWithCompletion:(void  (^)(NSString *pinCode))completion;
+(void)closePinCodesDialog;

@end
