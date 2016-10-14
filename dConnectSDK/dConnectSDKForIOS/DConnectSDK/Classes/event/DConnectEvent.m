//
//  DConnectEvent.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectEvent.h"

@implementation DConnectEvent

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[DConnectEvent class]]) {
        return NO;
    }
    
    DConnectEvent *other = (DConnectEvent *) object;
    
    BOOL interfaceMatch = NO;
    if ((_interface == nil && other.interface == nil)
        || (_interface != nil && [_interface isEqualToString:other.interface]))
    {
        interfaceMatch = YES;
    }
    
    BOOL serviceIdMatch = NO;
    if ((_serviceId == nil && other.serviceId == nil)
        || (_serviceId != nil && [_serviceId isEqualToString:other.serviceId]))
    {
        serviceIdMatch = YES;
    }
    
    return ([_profile isEqualToString:other.profile] &&
            interfaceMatch &&
            [_attribute isEqualToString:other.attribute] &&
            serviceIdMatch &&
            [_origin isEqualToString:other.origin]);
    
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:_profile forKey:@"profile"];
    [aCoder encodeObject:_interface forKey:@"interface"];
    [aCoder encodeObject:_attribute forKey:@"attribute"];
    [aCoder encodeObject:_serviceId forKey:@"serviceId"];
    [aCoder encodeObject:_accessToken forKey:@"accessToken"];
    [aCoder encodeObject:_origin forKey:@"origin"];
    [aCoder encodeObject:_createDate forKey:@"createDate"];
    [aCoder encodeObject:_updateDate forKey:@"updateDate"];
}

- (id)initWithCoder:(NSCoder *)aDecode {
    
    self = [super init];
    
    if (self) {
        _profile = [aDecode decodeObjectOfClass:[NSString class] forKey:@"profile"];
        _interface = [aDecode decodeObjectOfClass:[NSString class] forKey:@"interface"];
        _attribute = [aDecode decodeObjectOfClass:[NSString class] forKey:@"attribute"];
        _serviceId = [aDecode decodeObjectOfClass:[NSString class] forKey:@"serviceId"];
        _accessToken = [aDecode decodeObjectOfClass:[NSString class] forKey:@"accessToken"];
        _origin = [aDecode decodeObjectOfClass:[NSString class] forKey:@"origin"];
        _createDate = [aDecode decodeObjectOfClass:[NSDate class] forKey:@"createDate"];
        _updateDate = [aDecode decodeObjectOfClass:[NSDate class] forKey:@"updateDate"];
    }
    
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL) supportsSecureCoding {
    return YES;
}

@end
