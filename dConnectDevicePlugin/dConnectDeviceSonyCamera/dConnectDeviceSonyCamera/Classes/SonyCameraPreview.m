//
//  SonyCameraPreview.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraPreview.h"
#import "SampleRemoteApi.h"
#import "RemoteApiList.h"
#import "DeviceList.h"
#import "SampleLiveviewManager.h"
#import "SonyCameraRemoteApiUtil.h"


@interface SonyCameraPreview () <SampleLiveviewDelegate>

@end


@implementation SonyCameraPreview {
    SonyCameraRemoteApiUtil *_remoteApi;
}

- (instancetype)initWithRemoteApi:(SonyCameraRemoteApiUtil *)remoteApi
{
    self = [super init];
    if (self) {
        _remoteApi = remoteApi;
    }
    return self;
}

@end
