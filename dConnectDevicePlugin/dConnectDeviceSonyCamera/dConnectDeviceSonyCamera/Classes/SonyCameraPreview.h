//
//  SonyCameraPreview.h
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@class SonyCameraRemoteApiUtil;

@interface SonyCameraPreview : NSObject

- (instancetype)initWithRemoteApi:(SonyCameraRemoteApiUtil *)remoteApi;

- (void) startPreview;
- (void) stopPreview;

@end
