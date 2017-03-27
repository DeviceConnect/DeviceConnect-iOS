//
//  DPHostTouchProfile.h
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DPHostTouchProfile : DConnectTouchProfile
extern NSString *const DPHostTouchProfileEnumStart;
extern NSString *const DPHostTouchProfileEnumEnd;
extern NSString *const DPHostTouchProfileEnumDoubleTap;
extern NSString *const DPHosttTouchProfileEnumMove;
extern NSString *const DPHostTouchProfileEnumCancel;
extern NSString *const DPHostTouchProfileAttrOnTouchChange;
- (void) sendTouchEvent:(DConnectMessage *)eventMsg;
- (void) setTouchCache:(NSString *)attr
             touchData:(DConnectMessage *)touchData;

@end
