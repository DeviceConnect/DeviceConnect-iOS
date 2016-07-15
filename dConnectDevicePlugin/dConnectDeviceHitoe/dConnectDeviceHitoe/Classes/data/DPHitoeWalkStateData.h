//
//  DPHitoeWalkStateData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHitoeWalkStateData : NSObject<NSCopying>
@property (nonatomic, assign) int step;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) double speed;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) double balance;
@property (nonatomic, assign) long timeStamp;
@property (nonatomic, strong) NSString *timeStampString;
@end
