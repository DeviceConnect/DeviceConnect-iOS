//
//  DConnectAddOriginViewController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectEditOriginViewController.h"
#import "DConnectOrigin.h"
#import "DConnectOriginParser.h"
#import "DConnectAllowlist.h"

@interface DConnectEditOriginViewController ()

@end

@implementation DConnectEditOriginViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    if (_originInfo) {
        [_titleField setText:_originInfo.title];
        [_originField setText:[_originInfo.origin stringify]];
    }
}

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
    _originInfo.origin = origin;
    _originInfo.title = title;
    DConnectAllowlist *allowlist = [DConnectAllowlist sharedAllowlist];
    if (_mode == DConnectEditOriginModeChange) {
        [allowlist updateOrigin:_originInfo];
    } else {
        [allowlist addOrigin:origin title:title];
    }
    return YES;
}

@end
