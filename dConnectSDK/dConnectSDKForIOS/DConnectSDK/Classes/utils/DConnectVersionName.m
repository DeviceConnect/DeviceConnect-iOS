//
//  DConnectVersionName.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectVersionName.h"

@interface DConnectVersionName()

@property(nonatomic, strong) NSArray *version;

@property(nonatomic, strong) NSString *expression;

@end

@implementation DConnectVersionName

- (instancetype) initWithVersion: (NSArray *) version {
    
    self = [super init];
    if (self) {
        self.version = version;
        
        NSMutableString *exp = [NSMutableString string];
        for (int i = 0; i < [self.version count]; i++) {
            if (i > 0) {
                [exp appendString:@"."];
            }
            NSNumber *no = (NSNumber *) version[i];
            [exp appendString:[NSString stringWithFormat: @"%d", [no intValue]]];
        }
        self.expression = exp;
    }
    return self;
    
}

+ (DConnectVersionName *) parse: (NSString *) versionName {
    if (!versionName) {
        return nil;
    }
    NSArray *array = [versionName componentsSeparatedByString:@"."];
    if (array.count != 3) {
        return nil;
    }

    NSMutableArray *version = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        
        if (![self isNumber: array[i]]) {
            return nil;
        }
        
        version[i] = [NSNumber numberWithInteger: [array[i] integerValue]];
        if (version[i] < 0) {
            return nil;
        }
    }
    return [[DConnectVersionName alloc] initWithVersion: version];
}

- (NSString *) toString {
    return self.expression;
}

- (BOOL) isEqualToVersion: (NSObject *) o {

    if (self == o) {
        return YES;
    }
    if (![o isKindOfClass: [DConnectVersionName class]]) {
        return NO;
    }
    
    DConnectVersionName *that = (DConnectVersionName *)o;
    return [self.expression isEqualToString: that.toString];
}

#pragma mark - Private Methods.

+ (BOOL)isNumber:(NSString *)text {
    
    if (![text isKindOfClass: [NSString class]]) {
        return NO;
    }
    
    NSCharacterSet *digitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"+-0123456789."];
    
    NSScanner *aScanner = [NSScanner localizedScannerWithString:text];
    [aScanner setCharactersToBeSkipped:nil];
    
    [aScanner scanCharactersFromSet:digitCharSet intoString:NULL];
    return [aScanner isAtEnd];
}

@end
