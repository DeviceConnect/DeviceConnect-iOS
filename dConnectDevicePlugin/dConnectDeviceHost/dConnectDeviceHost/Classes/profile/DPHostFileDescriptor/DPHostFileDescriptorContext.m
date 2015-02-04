//
//  DPHostFileDescriptorContext.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHostFileDescriptorContext.h"

@implementation DPHostFileDescriptorContext
- (id) init {
    self = [super init];
    if (self) {
        _fileHandler = nil;
        _flag = nil;
    }
    return self;
}

@end
