//
//  DPHostGeolocationProfile.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <CoreLocation/CoreLocation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPHostGeolocationProfile : DConnectGeolocationProfile <CLLocationManagerDelegate>

@end
