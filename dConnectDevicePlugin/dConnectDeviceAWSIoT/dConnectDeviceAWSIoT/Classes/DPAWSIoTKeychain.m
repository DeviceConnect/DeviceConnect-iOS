//
//  DPAWSIoTKeychain.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Security/Security.h>
#import "DPAWSIoTKeychain.h"

#define kKeychainService @"DPAWSIoTKeychain"

@implementation DPAWSIoTKeychain

// 共通query
+ (NSMutableDictionary*)queryWithKey:(NSString*)key
{
	NSMutableDictionary* query = [NSMutableDictionary dictionary];
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:kKeychainService forKey:(__bridge id)kSecAttrService];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];
	return query;
}

// アイテム更新
+ (BOOL)updateValue:(NSString*)value key:(NSString*)key
{
	// update
	NSMutableDictionary *query = [DPAWSIoTKeychain queryWithKey:key];
	NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
	[attributes setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
	[attributes setObject:[NSDate date] forKey:(__bridge id)kSecAttrModificationDate];
	OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
	
	// keyがなければ追加
	if (status == errSecItemNotFound) {
		[query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
		[query setObject:[NSDate date] forKey:(__bridge id)kSecAttrModificationDate];
		OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, nil);
		if (status != noErr) {
			// 失敗...
			NSLog(@"*ERROR* failed to add data to keychain");
			return NO;
		}
	}
	return YES;
}

// アイテム削除
+ (BOOL)deleteWithKey:(NSString*)key
{
	NSMutableDictionary *query = [DPAWSIoTKeychain queryWithKey:key];
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	return status==noErr;
}

// アイテム検索
+ (NSString*)findWithKey:(NSString*)key
{
	NSMutableDictionary *query = [DPAWSIoTKeychain queryWithKey:key];
	[query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
	CFDataRef attributes;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&attributes);
	if (status == noErr) {
		NSData* data = (__bridge_transfer NSData*)attributes;
		return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	} else {
		return nil;
	}
}

@end
