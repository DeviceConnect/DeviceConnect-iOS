//
//  DPAWSIoTRemoteClientManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPAWSIoTRemoteClientManager : NSObject

- (void) destroy;
- (void) didReceivedSignaling:(NSString *)signaling;

@end
