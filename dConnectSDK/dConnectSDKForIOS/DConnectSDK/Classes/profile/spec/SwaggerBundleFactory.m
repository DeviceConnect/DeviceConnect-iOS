//
//  SwaggerBundleFactory.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/30.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

// TODO: 高野さんのアドバイスを聞いた後に実装する。

//#import "SwaggerBundleFactory.h"
//
//static const NSString * KEY_PATHS = @"paths";
//
//
//@interface SwaggerBundleFactory()
//
//@property(nonatomic, strong) NSDictionary *bundle;
//
//@end
//
//@implementation SwaggerBundleFactory
//
//- (instancetype) initWithJsonObj: (NSDictionary *) jsonObj {
//    
//    self = [super init];
//    if (self) {
//        [self setBundle: jsonObj];
//    }
//    return self;
//}
//
//- (NSDictionary *) createBundle: (NSDictionary *) jsonObj filter: (DConnectApiSpecFilter) filter {
//    
//    // TODO: JSON解析したデータをMutableで編集できるか確認必要
//    NSMutableDictionary *tmpBundle = [_bundle mutableCopy];
//    NSMutableDictionary *pathsObj = tmpBundle[KEY_PATHS];
//    if (!pathsObj) {
//        return tmpBundle;
//    }
//    NSArray *pathNames = [pathsObj allKeys];
//    if (!pathNames) {
//        return tmpBundle;
//    }
//    for (NSString *pathName in pathNames) {
//        NSMutableDictionary *pathObj = pathsObj[pathName];
//        if (!pathObj) {
//            continue;
//        }
//        NSArray *methods = DConnectSpecMethods;
//        for (NSString *method in methods) {
//            NSString *methodName = [method lowercaseString];
//            NSDictionary *methodObj = pathObj[methodName];
//            if (!methodObj) {
//                continue;
//            }
//            
//            if (!filter(pathName, methodName)) {
//                [pathObj removeObjectForKey: methodName];
//            }
//        }
//        if ([pathObj count] == 0) {
//            [pathsObj removeObjectForKey: pathName];
//        }
//    }
//    return tmpBundle;
//}
//
//- (NSDictionary *) toBundle: (NSDictionary *) jsonObj {
//    
//    NSMutableDictionary *bundle = [NSMutableDictionary  dictionary];
//    
//    for (NSString *name in [jsonObj allKeys]) {
//
//        id value = jsonObj[name];
//        if ([value isKindOfClass: [NSArray class]]) {
//            NSArray *array = (NSArray *)value;
//            [self putArray:bundle name:name jsonArray:array];
//        } if ([value isKindOfClass: [NSDictionary class]]) {
//            bundle[name] = (NSDictionary *)value;
//        }
///*
//        Serializableは対応必要？
//        else if (value instanceof Serializable) {
//            bundle.putSerializable(name, (Serializable) value);
//        }
//*/
//    }
//    
//    return bundle;
//}
//
//- (void) putArray: (NSMutableDictionary *)bundle name:(NSString *)name jsonArray:(NSArray *)jsonArray {
//
//    // iOSではJSONデータはNSArray,NSDictionaryになっているのでここでは変換不要？
//    bundle[name] = jsonArray;
//    
///*
//    if (jsonArray.length() == 0) {
//        bundle.putParcelableArray(name, new Bundle[0]);
//    } else {
//        final Class base = getBaseClass(jsonArray);
//        final int length = jsonArray.length();
//        if (base == Integer.class) {
//            int[] array = new int[length];
//            for (int i = 0; i < length; i++) {
//                array[i] = jsonArray.getInt(i);
//            }
//            bundle.putIntArray(name, array);
//        } else if (base == Long.class) {
//            long[] array = new long[length];
//            for (int i = 0; i < length; i++) {
//                array[i] = jsonArray.getLong(i);
//            }
//            bundle.putLongArray(name, array);
//        } else if (base == Double.class) {
//            double[] array = new double[length];
//            for (int i = 0; i < length; i++) {
//                array[i] = jsonArray.getDouble(i);
//            }
//            bundle.putDoubleArray(name, array);
//        } else if (base == String.class) {
//            String[] array = new String[length];
//            for (int i = 0; i < length; i++) {
//                array[i] = jsonArray.getString(i);
//            }
//            bundle.putStringArray(name, array);
//        } else if (base == JSONObject.class) {
//            Bundle[] array = new Bundle[length];
//            for (int i = 0; i < length; i++) {
//                array[i] = toBundle(jsonArray.getJSONObject(i));
//            }
//            bundle.putParcelableArray(name, array);
//        }
//    }
//*/
//}
//
//@end
