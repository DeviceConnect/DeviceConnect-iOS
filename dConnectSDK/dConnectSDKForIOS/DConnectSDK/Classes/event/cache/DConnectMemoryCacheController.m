//
//  DConnectMemoryCacheController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectMemoryCacheController.h"

NSString *const DConnectMemoryCacheControllerEmptyServiceId = @"";

@interface DConnectMemoryCacheController()

- (NSString *) serviceIdByCheckingServiceIdIsEmpty:(NSString *)serviceId;

@end
@implementation DConnectMemoryCacheController

#pragma mark - init

- (id) init {
    
    self = [super init];
    
    if (self) {
        _eventMap = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - DConnectEventCacheController

- (DConnectEventError) addEvent:(DConnectEvent *)event {
    
    if (![self checkParameterOfEvent:event]) {
        return DConnectEventErrorInvalidParameter;
    }
    
    DC_SYNC_START(self);
    
    NSString *serviceId = [self serviceIdByCheckingServiceIdIsEmpty:event.serviceId];
    NSMutableDictionary *events = [_eventMap objectForKey:serviceId];
    
    if (!events) {
        events = [NSMutableDictionary dictionary];
        _eventMap[serviceId] = events;
    }
    
    NSMutableString *path = [NSMutableString stringWithString:[event.profile lowercaseString]];
    if (event.interface) {
        [path appendString:[event.interface lowercaseString]];
    }
    [path appendString:[event.attribute lowercaseString]];
    
    NSMutableArray *eventList = [events objectForKey:[path lowercaseString]];
    if (!eventList) {
        eventList = [NSMutableArray array];
        events[[path lowercaseString]] = eventList;
    }
    
    for (DConnectEvent *e in eventList) {
        if ([e isEqual:event]) {
            e.accessToken = event.accessToken;
            e.updateDate = [NSDate date];
            return DConnectEventErrorNone;
        }
    }
    event.createDate = [NSDate date];
    event.updateDate = [NSDate date];
    [eventList addObject:event];
    
    DC_SYNC_END;
    
    return DConnectEventErrorNone;
}

- (BOOL) removeEventsForOrigin:(NSString *)origin {
    
    for (NSMutableDictionary *events in _eventMap.allValues) {
        for (NSMutableArray *eventList in events.allValues) {
            NSMutableArray *removes = [NSMutableArray array];
            for (DConnectEvent *event in eventList) {
                if ([event.origin isEqualToString:origin]) {
                    [removes addObject:event];
                }
            }
            if (removes.count != 0) {
                [eventList removeObjectsInArray:removes];
            }
        }
    }
    
    return YES;
}

- (BOOL) removeAll {
    [_eventMap removeAllObjects];
    return _eventMap.count == 0;
}

- (DConnectEventError) removeEvent:(DConnectEvent *)event {
    
    if (![self checkParameterOfEvent:event]) {
        return DConnectEventErrorInvalidParameter;
    }
    
    DC_SYNC_START(self);
    
    NSString *serviceId = [self serviceIdByCheckingServiceIdIsEmpty:event.serviceId];
    NSMutableDictionary *events = [_eventMap objectForKey:serviceId];
    
    if (!events) {
        return DConnectEventErrorNotFound;
    }
    
    NSMutableString *path = [NSMutableString stringWithString:[event.profile lowercaseString]];
    if (event.interface) {
        [path appendString:[event.interface lowercaseString]];
    }
    [path appendString:[event.attribute lowercaseString]];
    
    NSMutableArray *eventList = [events objectForKey:[path lowercaseString]];
    if (!eventList) {
        return DConnectEventErrorNotFound;
    }
    
    for (DConnectEvent *e in eventList) {
        if ([e isEqual:event]) {
            [eventList removeObject:e];
            if (eventList.count == 0) {
                [events removeObjectForKey:[path lowercaseString]];
            }
            return DConnectEventErrorNone;
        }
    }
    
    DC_SYNC_END;
    
    return DConnectEventErrorNotFound;
}

- (NSArray *) eventsForServiceId:(NSString *)serviceId
                        profile:(NSString *)profile
                      interface:(NSString *)interface
                      attribute:(NSString *)attribute
{
    
    DC_SYNC_START(self);
    
    NSString* sId = [self serviceIdByCheckingServiceIdIsEmpty:serviceId];
    NSMutableDictionary *events = [_eventMap objectForKey:sId];
    
    if (!events) {
        return @[];
    }
    
    NSMutableString *path = [NSMutableString stringWithString:[profile lowercaseString]];
    if (interface) {
        [path appendString:[interface lowercaseString]];
        
    }
    [path appendString:[attribute lowercaseString]];
    
    NSMutableArray *eventList = [events objectForKey:[path lowercaseString]];
    if (!eventList) {
        return @[];
    }
    
    return eventList;
    DC_SYNC_END;
}

- (DConnectEvent *) eventForServiceId:(NSString *)serviceId profile:(NSString *)profile
                           interface:(NSString *)interface attribute:(NSString *)attribute
                          origin:(NSString *)origin
{
    DConnectEvent *event = nil;
    DC_SYNC_START(self);
    
    do {
        NSArray *eventList = [self eventsForServiceId:serviceId
                                             profile:[profile lowercaseString]
                                           interface:[interface lowercaseString]
                                           attribute:[attribute lowercaseString]];
        
        for (DConnectEvent *e in eventList) {
            if ([event.origin isEqualToString:origin]) {
                event = e;
                break;
            }
        }
    } while (false);
    
    DC_SYNC_END;
    
    return event;
}

- (void) setEventMap:(NSMutableDictionary *)eventMap {
    // 常に正常に動かすため、nilは入れさせない。
    if (eventMap) {
        _eventMap = eventMap;
    }
}

#pragma mark - private

- (NSString *) serviceIdByCheckingServiceIdIsEmpty:(NSString *)serviceId
{
    NSString* sId = serviceId;
    if (!sId || sId.length == 0) {
        sId = DConnectMemoryCacheControllerEmptyServiceId;
    }
    
    return sId;
}

@end
