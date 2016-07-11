//
//  DPHitoeManager.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeManager.h"
#import "DPHitoeConsts.h"


@interface DPHitoeManager() {
    HitoeSdkAPI *api;
}
@end
@implementation DPHitoeManager

#pragma mark - Initialize
+ (DPHitoeManager *)sharedInstance {
    static DPHitoeManager *instance;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        instance = [DPHitoeManager new];
    });
    return instance;
}

- (id) init {
    
    self = [super init];
    
    if (self) {
        api = [HitoeSdkAPI sharedManager];
        [api setAPIDelegate:self];
        _registeredDevices = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - Public method



#pragma mark - Hitoe delegate

- (void)cbCallback:(int)apiId
        apiResorce:(int)apiResorce
            object:(id)object {
    NSString *responseData = (NSString*) object;
    NSLog(@"%d:%d:%@", apiId, apiResorce, responseData);
    switch (apiId) {
        case DPHitoeApiIdGetAvailableSensor:
            break;
        case DPHitoeApiIdConnect:
            break;
        case DPHitoeApiIdDisconnect
            break;
        case DPHitoeApiIdGetAvailableData:
            break;
        case DPHitoeApiIdAddReceiver:
            break;
        case DPHitoeApiIdRemoveReceiver:
            break;
        default:
            break;
    }
}

- (void)onDataReceiver:(NSString *)connectionId
               dataKey:(NSString *)dataKey
                  data:(NSString *)data
            responseId:(int)responseId {
    
}
@end
