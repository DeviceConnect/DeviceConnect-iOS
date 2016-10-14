//
//  DConnectBaseCacheController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectBaseCacheController.h"

@implementation DConnectBaseCacheController

- (BOOL) checkParameterOfEvent:(DConnectEvent *)event {
    
    if (event == nil
        || event.profile == nil
        || event.attribute == nil
        || event.origin == nil)
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - DConnectEventCacheController

- (DConnectEventError) addEvent:(DConnectEvent *)event {
    return DConnectEventErrorFailed;
}

- (DConnectEventError) removeEvent:(DConnectEvent *)event {
    return DConnectEventErrorFailed;
}

- (BOOL) removeEventsForOrigin:(NSString *)origin {
    return NO;
}

- (BOOL) removeAll {
    return NO;
}


- (DConnectEvent *) eventForServiceId:(NSString *)serviceId profile:(NSString *)profile
                           interface:(NSString *)interface attribute:(NSString *)attribute
                          origin:(NSString *)origin
{
    return nil;
}

- (NSArray *) eventsForServiceId:(NSString *)serviceId profile:(NSString *)profile
                      interface:(NSString *)interface attribute:(NSString *)attribute
{
    return nil;
}

- (void) flush {
    // do nothing.
}


@end
