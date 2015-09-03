//
//  DPIRKitVirtualDevice.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPIRKitVirtualDevice : NSObject


@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *categoryName;

@end
