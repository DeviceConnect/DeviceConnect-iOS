//
//  DPAWSIoTKeychain.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPAWSIoTKeychain : NSObject

// アイテム更新
+ (BOOL)updateValue:(NSString*)value key:(NSString*)key;
// アイテム削除
+ (BOOL)deleteWithKey:(NSString*)key;
// アイテム検索
+ (NSString*)findWithKey:(NSString*)key;

@end
