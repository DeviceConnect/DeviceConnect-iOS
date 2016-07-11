//
//  DPHitoeStressEstimationData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHitoeStressEstimationData : NSObject
@property (nonatomic,assign) double lfhf;
@property (nonatomic, assign) long timeStamp;
@property (nonatomic, copy) NSString *timeStampString;
@end
