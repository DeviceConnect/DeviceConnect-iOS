//
//  DPHostFileDescriptorContext.h
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHostFileDescriptorContext : NSObject
/*!
 @brief 編集中のFileHandlerオブジェクト。
 */
@property (nonatomic) NSFileHandle *fileHandler;
/*!
 @brief 編集中のFileHandlerの書き込みフラグ状態。
 */
@property (nonatomic) NSString *flag;
@end
