//
//  DConnectAddOriginViewController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAddOriginViewController.h"
#import "DConnectOrigin.h"
#import "DConnectOriginParser.h"
#import "DConnectWhitelist.h"

@interface DConnectAddOriginViewController ()

@end

@implementation DConnectAddOriginViewController

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier
                                   sender:(id)sender
{
    NSString *originExp = _originField.text;
    if (originExp.length == 0) {
        return NO;
    }
    NSString *title = _titleField.text;
    if (title.length == 0) {
        title = originExp;
    }
    id<DConnectOrigin> origin = [DConnectOriginParser parse:originExp];
    DConnectWhitelist *whitelist = [DConnectWhitelist sharedWhitelist];
    [whitelist addOrigin:origin title:title];
    return YES;
}

@end
