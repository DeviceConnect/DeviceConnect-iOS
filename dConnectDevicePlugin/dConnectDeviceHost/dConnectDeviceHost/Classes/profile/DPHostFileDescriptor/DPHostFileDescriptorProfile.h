//
//  DPHostFileDescriptorProfile.h
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DPHostFileDescriptorProfile : DConnectFileDescriptorProfile

/*!
 @param fileMgr dConnectファイルマネージャ
 */
- (instancetype)initWithFileManager:(DConnectFileManager *)fileMgr;

@end
