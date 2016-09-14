//
//  DPAWSIoTLocalServerManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@class DPAWSIoTLocalServerManager;

@protocol DPAWSIoTLocalServerManagerDelegate <NSObject>

-(void) localServerManager:(DPAWSIoTLocalServerManager *)manager didNotifiedSignaling:(NSString *)signaling;

@end

@interface DPAWSIoTLocalServerManager : NSObject

@property (nonatomic, assign) id<DPAWSIoTLocalServerManagerDelegate> delegate;

- (NSString *) createWebServer:(NSString *)address port:(int)port path:(NSString *)path;
- (void) destroy;
- (void) didReceivedSignaling:(NSString *)signaling;

@end
