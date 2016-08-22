//
//  DPIRKitSystemProfile.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import <DConnectSDK/DConnectSystemProfile.h>

@interface DPIRKitSystemProfile : DConnectSystemProfile

- (id)initWithDataSource: (id<DConnectSystemProfileDataSource>) dataSource;

@end
