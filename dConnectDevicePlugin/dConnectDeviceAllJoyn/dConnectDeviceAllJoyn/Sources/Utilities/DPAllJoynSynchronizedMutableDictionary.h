//
//  DPAllJoynSynchronizedMutableDictionary.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

@interface DPAllJoynSynchronizedMutableDictionary : NSObject

@property(readonly) NSUInteger count;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNSDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (id)objectForKey:(id)aKey;
//- (NSEnumerator *)objectEnumerator;
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)removeObjectForKey:(id)aKey;
- (NSMutableDictionary *)cloneDictionary;

@end
