//
//  DPAWSIoTLocalClientManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@class DPAWSIoTLocalClientManager;

@protocol DPAWSIoTLocalClientManagerDelegate <NSObject>

-(void) localClientManager:(DPAWSIoTLocalClientManager *)manager didNotifiedSignaling:(NSString *)signaling;

@end


@interface DPAWSIoTLocalClientManager : NSObject

@property (nonatomic, assign) id<DPAWSIoTLocalClientManagerDelegate> delegate;

- (void) destroy;
- (void) didReceivedSignaling:(NSString *)signaling dataSource:(id)dataSource;

@end
