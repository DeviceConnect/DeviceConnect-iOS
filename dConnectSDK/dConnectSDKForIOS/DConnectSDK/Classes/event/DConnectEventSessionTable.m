//
//  DConnectEventSessionTable.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectEventSessionTable.h"
#import "DConnectEventSession.h"

@interface DConnectEventSessionTable()

@property(nonatomic, strong) NSMutableArray<__kindof DConnectEventSession *> *eventSessions;

@end

@implementation DConnectEventSessionTable

- (instancetype) init {
    
    self = [super init];
    if (self) {
        self.eventSessions = [NSMutableArray array];
    }
    return self;
}

- (NSArray *) all {
    return self.eventSessions;
}

- (NSArray *) findEventSessionsForPlugin: (DConnectDevicePlugin *) plugin {
   
    NSMutableArray *result = [NSMutableArray array];
    @synchronized (self.eventSessions) {
        for (DConnectEventSession *session in self.eventSessions) {
            if ([plugin.pluginId isEqualToString: session.pluginId]) {
                [result addObject: session];
            }
        }
    }
    return result;
}

- (void) add: (DConnectEventSession *) session {
    @synchronized(self.eventSessions) {
        [self.eventSessions addObject: session];
    }
}

- (void) remove: (DConnectEventSession *) session {
    @synchronized (self.eventSessions) {
        [self.eventSessions removeObject: session];
    }
}

@end

