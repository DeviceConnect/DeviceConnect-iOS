/**
 * @file  SampleCameraEventObserver.m
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "SampleCameraEventObserver.h"
#import "SampleCameraApi.h"

static SampleCameraEventObserver *_instance;

@implementation SampleCameraEventObserver {
    BOOL _isStarted;
    BOOL _isFirstCall;
    id<SampleEventObserverDelegate> _eventDelegate;

    // current status
    NSArray *_availableApiList;
    NSString *_cameraStatus;
    BOOL _liveviewStatus;
    NSString *_shootMode;
    int _zoomPosition;
    NSString *_storageId;
}

+ (SampleCameraEventObserver *)getInstance
{
    if (!_instance) {
        _instance = [[SampleCameraEventObserver alloc] init];
    }
    return _instance;
}

- (BOOL)startWithDelegate:(id<SampleEventObserverDelegate>)eventDelegate
{
    if (!_isStarted) {
//        NSLog(@"SampleEventObserver started");
        _isStarted = YES;
        _isFirstCall = YES;

        _availableApiList = nil;
        _cameraStatus = nil;
        _liveviewStatus = NO;
        _shootMode = nil;
        _zoomPosition = -1;
        _storageId = nil;
        _eventDelegate = eventDelegate;
        [self call];
        return YES;
    }

    // Already long polling. If new delegate is set, notify latest status
    if (![_eventDelegate isEqual:eventDelegate]) {
        _eventDelegate = eventDelegate;
        [self notifyCurrentStatus];
    }
    return NO;
}

- (void)call
{
    if (_isStarted) {
        [SampleCameraApi getEvent:self longPollingFlag:!_isFirstCall];
        _isFirstCall = NO;
    }
}

- (void)stop
{
//    NSLog(@"SampleEventObserver stopped");
    _eventDelegate = nil;
}

- (void)parseMessage:(NSData *)response apiName:(NSString *)apiName
{
    NSString *responseText =
        [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//    NSLog(@"SampleCameraEventObserver parseMessage = %@, apiname=%@",
//          responseText, apiName);
    if (_isStarted) {
        NSError *e = nil;
        NSDictionary *jsonDict = [NSJSONSerialization
            JSONObjectWithData:response
                       options:NSJSONReadingMutableContainers
                         error:&e];
        if (!e) {
            if ([jsonDict[@"error"] isKindOfClass:[NSArray class]]) {
                // For developer : check for error codes and restart event if
                // necessary
                NSArray *error = jsonDict[@"error"];
                if (error.count >= 1) {
                    if ([error[0] isKindOfClass:[NSNumber class]]) {
                        // This error is created in HttpAsynchronousRequest
                        if ([error[0] intValue] == 16) {
                            if ([_eventDelegate
                                    respondsToSelector:
                                        @selector(
                                            didFailParseMessageWithError:)]) {
                                [_eventDelegate didFailParseMessageWithError:e];
                            }
                            [self stop];
                            _isStarted = NO;
                            // Transport Error. Not Request Any More
                            return;
                        } else if ([error[0] intValue] == 40402) {
                            NSLog(@"SampleCameraEventObserver 40402");
                            [NSThread sleepForTimeInterval:5.0];
                        }
                    }
                }
            }
            if ([jsonDict[@"result"] isKindOfClass:[NSArray class]]) {
                NSArray *result = jsonDict[@"result"];

                // check for all event callbacks required by the application.
                // api list
                NSArray *availableApiList = [self findAvailableApiList:result];
                if (availableApiList != nil) {
                    _availableApiList = availableApiList;
                    if ([_eventDelegate
                            respondsToSelector:
                                @selector(didAvailableApiListChanged:)]) {
                        [_eventDelegate
                            didAvailableApiListChanged:_availableApiList];
                    }
                }

                // camera status
                NSString *cameraStatus = [self findCameraStatus:result];
                if (cameraStatus != nil &&
                    ![cameraStatus isEqualToString:_cameraStatus]) {

                    _cameraStatus = cameraStatus;
                    if ([_eventDelegate
                            respondsToSelector:@selector(
                                                   didCameraStatusChanged:)]) {
                        [_eventDelegate didCameraStatusChanged:_cameraStatus];
                    }
                }

                // liveview status
                BOOL liveviewStatus = [self findLiveviewStatus:result];
                if (liveviewStatus != _liveviewStatus) {
                    _liveviewStatus = liveviewStatus;
                    if ([_eventDelegate
                            respondsToSelector:
                                @selector(didLiveviewStatusChanged:)]) {
                        [_eventDelegate
                            didLiveviewStatusChanged:_liveviewStatus];
                    }
                }

                // shoot mode
                NSString *shootMode = [self findShootMode:result];
                if (shootMode != nil &&
                    ![shootMode isEqualToString:_shootMode]) {
                    _shootMode = shootMode;
                    if ([_eventDelegate
                            respondsToSelector:@selector(
                                                   didShootModeChanged:)]) {
                        [_eventDelegate didShootModeChanged:_shootMode];
                    }
                }

                // zoom position
                int zoomPosition = [self findZoomInformation:result];
                if (zoomPosition != -1) {
                    _zoomPosition = zoomPosition;
                    if ([_eventDelegate
                            respondsToSelector:@selector(
                                                   didZoomPositionChanged:)]) {
                        [_eventDelegate didZoomPositionChanged:_zoomPosition];
                    }
                }

                // storage id
                NSString *storageId = [self findStorageInformation:result];
                if (storageId != nil &&
                    ![storageId isEqualToString:_storageId]) {
                    _storageId = storageId;
                    if ([_eventDelegate
                            respondsToSelector:
                                @selector(didStorageInformationChanged:)]) {
                        [_eventDelegate
                            didStorageInformationChanged:_storageId];
                    }
                }
            }
            [self call];
        } else {
            if ([_eventDelegate
                    respondsToSelector:@selector(
                                           didFailParseMessageWithError:)]) {
                [_eventDelegate didFailParseMessageWithError:e];
            }
            [self stop];
        }
    }
}

- (void)notifyCurrentStatus
{
    NSLog(@"notifyCurrentStatus");
    if (_availableApiList != nil &&
        [_eventDelegate
            respondsToSelector:@selector(didAvailableApiListChanged:)]) {
        [_eventDelegate didAvailableApiListChanged:_availableApiList];
    }

    if (_cameraStatus != nil &&
        [_eventDelegate
            respondsToSelector:@selector(didCameraStatusChanged:)]) {
        [_eventDelegate didCameraStatusChanged:_cameraStatus];
    }

    if ([_eventDelegate
            respondsToSelector:@selector(didLiveviewStatusChanged:)]) {
        [_eventDelegate didLiveviewStatusChanged:_liveviewStatus];
    }

    if (_shootMode != nil &&
        [_eventDelegate respondsToSelector:@selector(didShootModeChanged:)]) {
        [_eventDelegate didShootModeChanged:_shootMode];
    }

    if (_zoomPosition != -1 &&
        [_eventDelegate
            respondsToSelector:@selector(didZoomPositionChanged:)]) {
        [_eventDelegate didZoomPositionChanged:_zoomPosition];
    }

    if (_storageId != nil &&
        [_eventDelegate
            respondsToSelector:@selector(didStorageInformationChanged:)]) {
        [_eventDelegate didStorageInformationChanged:_storageId];
    }
}

// Finds and extracts a list of available APIs from reply JSON data.
// As for getEvent v1.0, results[0] => "availableApiList"
- (NSArray *)findAvailableApiList:(NSArray *)response
{
    NSArray *availableApiList = nil;
    int indexOfAvailableApiList = 0;
    if (indexOfAvailableApiList < response.count &&
        [response[indexOfAvailableApiList]
            isKindOfClass:[NSDictionary class]]) {
        NSDictionary *typeObj = response[indexOfAvailableApiList];
        if ([typeObj[@"type"] isKindOfClass:[NSString class]]) {
            if ([typeObj[@"type"] isEqualToString:@"availableApiList"]) {
                if ([typeObj[@"names"] isKindOfClass:[NSArray class]]) {
                    availableApiList = typeObj[@"names"];
                }
            }
        }
    }
    return availableApiList;
}

// Finds and extracts a value of Camera Status from reply JSON data.
// As for getEvent v1.0, results[1] => "cameraStatus"
- (NSString *)findCameraStatus:(NSArray *)response
{
    NSString *cameraStatus = nil;
    int indexOfCameraStatus = 1;
    if (indexOfCameraStatus < response.count &&
        [response[indexOfCameraStatus] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *typeObj = response[indexOfCameraStatus];
        if ([typeObj[@"type"] isKindOfClass:[NSString class]]) {
            if ([typeObj[@"type"] isEqualToString:@"cameraStatus"]) {
                if ([typeObj[@"cameraStatus"] isKindOfClass:[NSString class]]) {
                    cameraStatus = typeObj[@"cameraStatus"];
                }
            }
        }
    }
    return cameraStatus;
}

// Finds and extracts a value of Liveview Status from reply JSON data.
// As for getEvent v1.0, results[3] => "liveviewStatus"
- (BOOL)findLiveviewStatus:(NSArray *)response
{
    BOOL liveviewStatus = NO;
    int indexOfLiveviewStatus = 3;
    if (indexOfLiveviewStatus < response.count &&
        [response[indexOfLiveviewStatus] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *typeObj = response[indexOfLiveviewStatus];
        if ([typeObj[@"type"] isKindOfClass:[NSString class]]) {
            if ([typeObj[@"type"] isEqualToString:@"liveviewStatus"]) {
                if ([typeObj[@"liveviewStatus"]
                        isKindOfClass:[NSNumber class]] &&
                    strcmp([typeObj[@"liveviewStatus"] objCType], "c") == 0) {
                    liveviewStatus = (BOOL)typeObj[@"liveviewStatus"];
                }
            }
        }
    }
    return liveviewStatus;
}

// Finds and extracts a value of Zoom Information from reply JSON data.
// As for getEvent v1.0, results[2] => "zoomInformation"
- (int)findZoomInformation:(NSArray *)response
{
    int zoomPosition = -1;
    int indexOfZoomInformation = 2;
    if (indexOfZoomInformation < response.count &&
        [response[indexOfZoomInformation] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *typeObj = response[indexOfZoomInformation];
        if ([typeObj[@"type"] isKindOfClass:[NSString class]]) {
            if ([typeObj[@"type"] isEqualToString:@"zoomInformation"]) {
                if ([typeObj[@"zoomPosition"] isKindOfClass:[NSNumber class]]) {
                    NSNumber *zoomPositionNum =
                        (NSNumber *)typeObj[@"zoomPosition"];
                    zoomPosition = [zoomPositionNum intValue];
                }
            }
        }
    }
    return zoomPosition;
}

// Finds and extracts a value of Camera Status from reply JSON data.
// As for getEvent v1.0, results[21] => "shootMode"
- (NSString *)findShootMode:(NSArray *)response
{
    NSString *shootMode;
    int indexOfShootMode = 21;
    if (indexOfShootMode < response.count &&
        [response[indexOfShootMode] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *typeObj = response[indexOfShootMode];
        if ([typeObj[@"type"] isKindOfClass:[NSString class]]) {
            if ([typeObj[@"type"] isEqualToString:@"shootMode"]) {
                if ([typeObj[@"currentShootMode"]
                        isKindOfClass:[NSString class]]) {
                    shootMode = typeObj[@"currentShootMode"];
                }
            }
        }
    }
    return shootMode;
}

// Finds and extracts a value of Camera Status from reply JSON data.
// As for getEvent v1.0, results[10] => "storageInformation"
- (NSString *)findStorageInformation:(NSArray *)response
{
    NSString *storageId = nil;
    int indexOfStorageInformation = 10;
    if (indexOfStorageInformation < response.count &&
        [response[indexOfStorageInformation] isKindOfClass:[NSArray class]]) {
        NSArray *storages = response[indexOfStorageInformation];
        if (storages.count > 0) {
            if ([storages[0] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *storageInfo = storages[0];
                if ([storageInfo[@"storageID"]
                        isKindOfClass:[NSString class]]) {
                    storageId = storageInfo[@"storageID"];
                }
            }
        }
    }
    return storageId;
}

@end
