//
//  DPHitoeService.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectFileManager.h>
#import "DPHitoeDevice.h"

@interface DPHitoeService : DConnectService
- (instancetype) initWithDevice:(DPHitoeDevice *)device;
- (void)setOnline:(BOOL)isOnline;
@end
