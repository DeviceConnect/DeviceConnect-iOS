//
//  DPAllJoynSynchronizedMutableDictionary.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynSynchronizedMutableDictionary.h"


@interface DPAllJoynSynchronizedMutableDictionary () {
    @private
    NSMutableDictionary *_internalDictionary;
    NSLock *_lock;
}

@end


@implementation DPAllJoynSynchronizedMutableDictionary

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_internalDictionary = [NSMutableDictionary new];
        self->_lock = [NSLock new];
    }
    return self;
}


- (instancetype)initWithNSDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self->_internalDictionary =
        [NSMutableDictionary dictionaryWithDictionary:dictionary];
        self->_lock = [NSLock new];
    }
    return self;
}


- (NSUInteger) count
{
    [_lock lock];
    NSUInteger count = _internalDictionary.count;
    [_lock unlock];
    return count;
}


- (id)objectForKey:(id)aKey
{
    [_lock lock];
    id object = _internalDictionary[aKey];
    [_lock unlock];
    return object;
}


//- (NSEnumerator *)objectEnumerator
//{
//    
//}


- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    [_lock lock];
    _internalDictionary[aKey] = anObject;
    [_lock unlock];
}


- (void)removeObjectForKey:(id)aKey
{
    [_lock lock];
    [_internalDictionary removeObjectForKey:aKey];
    [_lock unlock];
}


- (NSMutableDictionary *)cloneDictionary
{
    [_lock lock];
    NSMutableDictionary *dictionary =
    [NSMutableDictionary dictionaryWithDictionary:_internalDictionary];
    [_lock unlock];
    return dictionary;
}

@end
