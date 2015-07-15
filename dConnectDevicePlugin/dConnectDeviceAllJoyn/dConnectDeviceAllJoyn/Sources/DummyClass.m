//
//  DummyClass.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DummyClass.h"

@implementation DummyClass

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.testProperty = @"testProperty";
    }
    return self;
}

- (UIStoryboard *) storyboard {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    @try {
        return [UIStoryboard storyboardWithName:@"Storyboard"
                                         bundle:frameworkBundle];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        return nil;
    }
}

- (UIImage *) image {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if ([UIImage instancesRespondToSelector:
         @selector(imageNamed:
                   inBundle:
                   compatibleWithTraitCollection:)])
    {
        @try {
            return [UIImage imageNamed:@"testImage"
                              inBundle:frameworkBundle
         compatibleWithTraitCollection:nil];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
            return nil;
        }
    } else {
        NSLog(@"UIImage is not new.");
        return nil;
    }
}

@end
