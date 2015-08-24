//
//  DPAllJoynMessageConverter.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynMessageConverter.h"

#import <AllJoynFramework_iOS.h>


@implementation DPAllJoynMessageConverter

// TODO: Cyclic reference check for complex type (e.g. MsgArg)
+ (id)objectWithMsArg:(const MsgArg *)msgArg
{
    if (!msgArg) {
        return nil;
    }
    
    NSString *signature = @(msgArg->Signature().c_str());
    if ([signature isEqualToString:@"y"]) {
        return @((uint32_t)msgArg->v_byte);
    }
    else if ([signature isEqualToString:@"b"]) {
        return @((BOOL)msgArg->v_bool);
    }
    else if ([signature isEqualToString:@"n"]) {
        return @(msgArg->v_int16);
    }
    else if ([signature isEqualToString:@"q"]) {
        return @(msgArg->v_uint16);
    }
    else if ([signature isEqualToString:@"i"]) {
        return @(msgArg->v_int32);
    }
    else if ([signature isEqualToString:@"u"]) {
        return @(msgArg->v_uint32);
    }
    else if ([signature isEqualToString:@"x"]) {
        return @(msgArg->v_int64);
    }
    else if ([signature isEqualToString:@"t"]) {
        return @(msgArg->v_uint64);
    }
    else if ([signature isEqualToString:@"d"]) {
        return @(msgArg->v_double);
    }
    else if ([signature isEqualToString:@"s"]) {
        return @(msgArg->v_string.str);
    }
    else if ([signature isEqualToString:@"o"]) {
        return @(msgArg->v_objPath.str);
    }
    else if ([signature isEqualToString:@"g"]) {
        return @(msgArg->v_signature.sig);
    }
    // TODO: Generalize conversion of a..., a{...} and a(...)
    else if ([signature isEqualToString:@"as"]) {
        size_t size;
        MsgArg *entries;
        QStatus status = msgArg->Get("as", &size, &entries);
        if (ER_OK != status) {
            return nil;
        }
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:size];
        for (size_t i = 0; i < size; ++i) {
            [array addObject:@(entries[i].v_string.str)];
        }
        return array;
    }
    else if ([signature isEqualToString:@"a{sv}"]) {
        size_t size;
        MsgArg *entries;
        QStatus status;
        status = msgArg->Get("a{sv}", &size, &entries);
        if (ER_OK != status) {
            return nil;
        }
        NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithCapacity:size];
        for (size_t i = 0; i < size; ++i) {
            char *keyCStr;
            MsgArg *valArg;
            status = entries[i].Get("{sv}", &keyCStr, &valArg);
            if (ER_OK != status) {
                return nil;
            }
            
            id val = [DPAllJoynMessageConverter objectWithMsArg:valArg];
            if (val) {
                dict[@(keyCStr)] = val;
            } else {
                // return nil;
                DCLogWarn(@"Failed to obtain an object.");
                continue;
            }
        }
        return dict;
    } else {
        return nil;
    }
}


+ (id)objectWithAJNMessageArgument:(AJNMessageArgument *)msgArg
{
    if (!msgArg) {
        return nil;
    }
    
    return [DPAllJoynMessageConverter objectWithMsArg:(MsgArg *)msgArg.handle];
}


+ (AJNMessageArgument *)AJNMessageArgumentWithObject:(id)obj
                                           signature:(NSString*)signature
{
    if ([signature isEqualToString:@"as"]) {
        if (![obj isKindOfClass:NSArray.class]) {
            return nil;
        }
        NSArray *arrayObj = (NSArray *)obj;
        const char **strArr = new const char*[arrayObj.count];
        for (size_t i = 0; i < arrayObj.count; ++i) {
            id val = arrayObj[i];
            if (![val isKindOfClass:NSString.class]) {
                return nil;
            }
            NSString *valStr = (NSString *)val;
            char *dst = new char[valStr.length + 1];
            [valStr getCString:dst maxLength:valStr.length + 1
                      encoding:NSUTF8StringEncoding];
            strArr[i] = dst;
        }
        MsgArg *msgArg = new MsgArg("as", arrayObj.count, strArr);
        return [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)msgArg
                              shouldDeleteHandleOnDealloc:YES];
    } else {
        return nil;
    }
}

@end
