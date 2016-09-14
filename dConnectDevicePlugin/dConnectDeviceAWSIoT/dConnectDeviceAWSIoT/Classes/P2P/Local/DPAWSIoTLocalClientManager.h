//
//  DPAWSIoTLocalClientManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@protocol DPAWSIoTLocalClientManagerDelegate <NSObject>

-(void)didReceivedAddress:(NSString *)address port:(int)port;

@end


@interface DPAWSIoTLocalClientManager : NSObject

@property (nonatomic, assign) id<DPAWSIoTLocalClientManagerDelegate> delegate;


- (void) destroy;
- (void) didReceivedSignaling:(NSString *)signaling;

@end
