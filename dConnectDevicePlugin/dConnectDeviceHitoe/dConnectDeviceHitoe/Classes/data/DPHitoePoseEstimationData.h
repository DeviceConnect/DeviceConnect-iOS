//
//  DPHitoePoseEstimationData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
@interface DPHitoePoseEstimationData : NSObject<NSCopying>
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) long long timeStamp;
@property (nonatomic, strong) NSString *timeStampString;
- (DConnectMessage*)toDConnectMessage;

@end
