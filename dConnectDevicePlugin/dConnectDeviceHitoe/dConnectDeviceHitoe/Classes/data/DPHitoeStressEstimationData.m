//
//  DPHitoeStressEstimationData.m
//  dConnectDeviceHitoe
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeStressEstimationData.h"

@implementation DPHitoeStressEstimationData
- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}
@end
