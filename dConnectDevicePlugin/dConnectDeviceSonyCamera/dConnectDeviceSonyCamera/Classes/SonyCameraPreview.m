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
#import "SonyCameraSimpleHttpServer.h"


@interface SonyCameraPreview () <SampleLiveviewDelegate>

@end


@implementation SonyCameraPreview {
    SonyCameraRemoteApiUtil *_remoteApi;
    SonyCameraSimpleHttpServer *_httpServer;
}

- (instancetype)initWithRemoteApi:(SonyCameraRemoteApiUtil *)remoteApi
{
    self = [super init];
    if (self) {
        _remoteApi = remoteApi;
        _httpServer = nil;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL) startPreviewWithTimeSlice:(NSNumber *)timeSlice
{
    if (_httpServer) {
        [_httpServer stop];
        _httpServer = nil;
    }

    _httpServer = [SonyCameraSimpleHttpServer new];
    _httpServer.listenPort = 10000;
    if (timeSlice) {
        _httpServer.timeSlice = [timeSlice integerValue];
    }
    BOOL result = [_httpServer start];
    if (!result) {
        return NO;
    }
    
    result = [self startLiveView];
    if (!result) {
        [_httpServer stop];
        _httpServer = nil;
        return NO;
    }

    return YES;
}

- (void) stopPreview
{
    if (_httpServer) {
        [_httpServer stop];
        _httpServer = nil;
    }

    if ([_remoteApi isStartedLiveView]) {
        [_remoteApi actStopLiveView];
    }
}

- (BOOL) isRunning
{
    return _httpServer && [_remoteApi isStartedLiveView];
}

- (NSString *)getUrl
{
    if (_httpServer) {
        return [_httpServer getUrl];
    }
    return nil;
}


#pragma mark - Private Methods

- (BOOL) startLiveView {
    return [_remoteApi actStartLiveView:self];
}

#pragma mark - SampleLiveviewDelegate Methods

- (void) didReceivedData:(NSData *)imageData
{
    if (_httpServer) {
        [_httpServer offerData:imageData];
    }
}

- (void) didReceivedError
{
    DCLogInfo(@"Preview occurred an error.");
}

@end
