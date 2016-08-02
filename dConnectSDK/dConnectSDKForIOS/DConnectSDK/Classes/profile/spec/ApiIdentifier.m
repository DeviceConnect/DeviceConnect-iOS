//
//  ApiIdentifier.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ApiIdentifier.h"

@interface ApiIdentifier() {
    
    NSString *mPath;
    
    DConnectSpecMethod mMethod;
}

@end

@implementation ApiIdentifier

- (instancetype)initWithPath: (NSString *)path method: (DConnectSpecMethod) method {

    self = [super init];
    if (self) {
        
        if (!path) {
            @throw @"path is nil.";
        }
        
        // 初期値設定
        mPath = path;
        mMethod = method;
    }
    return self;
}

- (instancetype)initWithPathAndMethodString: (NSString *)path method: (NSString *) method {

    // 引数に問題があれば例外をスローする
    DConnectSpecMethod enMethod = [DConnectSpecConstants parseMethod: method];
    
    self = [self initWithPath: path method: enMethod];
    return self;
}

- (NSString *) apiIdentifierString {
    
    NSString *str = [NSString stringWithFormat: @"%@-%@", mPath, [DConnectSpecConstants toMethodString: mMethod]];
    
    return str;
}


/*
@Override
public int hashCode() {
    int result = mPath.toLowerCase().hashCode();
    result = 31 * result + mMethod.hashCode();
    return result;
}
*/

/*
@Override
public boolean equals(final Object o) {
    if (this == o) {
        return true;
    }
    if (!(o instanceof ApiIdentifier)) {
        return false;
    }
    ApiIdentifier that = ((ApiIdentifier) o);
    return mPath.equalsIgnoreCase(that.mPath) && mMethod == that.mMethod;
}
*/



@end
