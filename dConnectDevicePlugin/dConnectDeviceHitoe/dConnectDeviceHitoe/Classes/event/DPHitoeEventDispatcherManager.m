//
//  DPHitoeEventDispatcherManager.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeEventDispatcherManager.h"

@interface DPHitoeEventDispatcherManager()
@property (nonatomic, strong) NSMutableDictionary *eventMap;
@end
@implementation DPHitoeEventDispatcherManager

- (void)addEventDispatcherForServiceId:(NSString *)serviceId dispatcher:(DPHitoeEventDispatcher*)dispatcher {
    if (!_eventMap) {
        _eventMap = [NSMutableDictionary dictionary];
    }
    if ([self containsEventDispacherForServiceId:serviceId]) {
        return;
    }
    _eventMap[serviceId] = dispatcher;
    [dispatcher start];
}
- (void)removeEventDispacherForServiceId:(NSString*)serviceId {
    if (!_eventMap) {
        _eventMap = [NSMutableDictionary dictionary];
    }
    DPHitoeEventDispatcher *dispatcher = _eventMap[serviceId];
    if (dispatcher) {
        [dispatcher stop];
        [_eventMap removeObjectForKey:serviceId];
    }
}
- (void)removeAllEventDispatcher {
    if (!_eventMap) {
        _eventMap = [NSMutableDictionary dictionary];
    }
    for (DPHitoeEventDispatcher *dispatcher in _eventMap) {
        [dispatcher stop];
    }
    [_eventMap removeAllObjects];
}
- (BOOL)containsEventDispacherForServiceId:(NSString*)serviceId {
    if (!_eventMap) {
        _eventMap = [NSMutableDictionary dictionary];
    }
    return (_eventMap[serviceId] != nil);
}
- (void)sendEventForServiceId:(NSString*)serviceId message:(DConnectMessage*)message {
    if (!_eventMap) {
        _eventMap = [NSMutableDictionary dictionary];
    }
    DPHitoeEventDispatcher *dispatcher = _eventMap[serviceId];
    if (dispatcher) {
        [dispatcher sendEventForMessge:message];
    }
}

@end
