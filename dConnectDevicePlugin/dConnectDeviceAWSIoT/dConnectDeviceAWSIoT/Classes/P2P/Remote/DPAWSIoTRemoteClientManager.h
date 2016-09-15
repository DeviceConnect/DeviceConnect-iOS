//
//  DPAWSIoTRemoteClientManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@class DPAWSIoTRemoteClientManager;

@protocol DPAWSIoTRemoteClientManagerDelegate <NSObject>

-(void) remoteClientManager:(DPAWSIoTRemoteClientManager *)client didNotifiedSignaling:(NSString *)signaling to:(NSString *)uuid;

@end


@interface DPAWSIoTRemoteClientManager : NSObject

@property (nonatomic, assign) id<DPAWSIoTRemoteClientManagerDelegate> delegate;

- (void) destroy;
- (void) didReceivedSignaling:(NSString *)signaling dataSource:(id)dataSource to:(NSString *)uuid;

@end
