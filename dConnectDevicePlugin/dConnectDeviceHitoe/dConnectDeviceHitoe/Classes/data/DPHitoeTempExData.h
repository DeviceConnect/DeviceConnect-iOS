//
//  DPHitoeTempExData.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHitoeTempExData : NSObject<NSCopying>
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSMutableArray *dataList;
@end
