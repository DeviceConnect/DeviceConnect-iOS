//
//  DPAllJoynMessageConverter.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

@class AJNMessageArgument;
namespace ajn {
class MsgArg;
}


@interface DPAllJoynMessageConverter : NSObject

+ (instancetype)alloc NS_UNAVAILABLE;
+ (instancetype)allocWithZone:(struct _NSZone *)zone NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (id)objectWithMsArg:(const ajn::MsgArg *)msgArg;
+ (id)objectWithAJNMessageArgument:(AJNMessageArgument *)msgArg;
+ (AJNMessageArgument *)AJNMessageArgumentWithObject:(id)obj
                                           signature:(NSString *)signature;

@end
