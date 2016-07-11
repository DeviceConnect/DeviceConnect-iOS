//
//  DPHitoePoseEstimationData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHitoePoseEstimationData : NSObject
@property (nonatomic, copy) NSString *state;
@property (nonatomic, assign) long timeStamp;
@property (nonatomic, copy) NSString *timeStampString;
@end
