//
//  DPHueSettingViewController2.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueSettingViewController2.h"

@interface DPHueSettingViewController2 ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pushlinkWaitIndicator;
@property (weak, nonatomic) IBOutlet UIView *searchingView;
@property (weak, nonatomic) IBOutlet UIImageView *pushlinkIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *selectedMacAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedIpAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorizeStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
#pragma mark - Portrait Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portImageLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portMessageLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portInfoRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portInfoBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portImageCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portMessageCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portInfoCenter;

#pragma mark - Landscape Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landInfoRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landInfoTop;

#pragma mark - Common Constraints

@end

@implementation DPHueSettingViewController2


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([super iphone]) {
        portConstraints = [NSArray arrayWithObjects:
                           _portInfoRight,
                           _portInfoBottom,
                           _portImageCenter,
                           _portInfoCenter,
                           _portMessageCenter,
                           _portInfoCenter, nil];
    } else {
        portConstraints = [NSArray arrayWithObjects:
                           _portInfoBottom,
                           _portImageCenter,
                           _portInfoCenter,
                           _portMessageCenter,
                           _portInfoCenter, nil];

    }
    landConstraints = [NSArray arrayWithObjects:
                       _landInfoRight,
                       _landInfoTop, nil];

    [manager deallocPHNotificationManagerWithReceiver:self];
    [self startHueAuthentication];
}

- (IBAction)registerAppNameForHueBridge:(id)sender
{
    [self startHueAuthentication];
}

- (void)startHueAuthentication
{
    if (![self isSelectedItemBridge]) {
        return;
    }
    [self startIndicator];
    DPHueItemBridge *item = [self getSelectedItemBridge];
    _selectedIpAddressLabel.text = item.ipAddress;
    _selectedMacAddressLabel.text = item.bridgeId;
    _authorizeStateLabel.text = @"---";
    [manager            startPushlinkWithReceiver:self
            pushlinkAuthenticationSuccessSelector:@selector(didPushlinkAuthenticationSuccess)
             pushlinkAuthenticationFailedSelector:@selector(didPushlinkAuthenticationFailed)
                pushlinkNoLocalConnectionSelector:@selector(didPushlinkNoLocalConnection)
                    pushlinkNoLocalBridgeSelector:@selector(didPushlinkNoLocalConnection)
                 pushlinkButtonNotPressedSelector:@selector(didPushlinkButtonNotPressed)];
}


- (void)didPushlinkAuthenticationSuccess
{
    [manager disableHeartbeat];
    _statusLabel.text = @"ライト検索中!!";
    _authorizeStateLabel.text = DPHueLocalizedString(_bundle, @"HueBridgeAuthorized");
    [self  initHueSdk];
}

- (void)initHueSdk
{
    DPHueItemBridge *item = [self getSelectedItemBridge];
    [[DPHueManager sharedManager] initHue];
    [[DPHueManager sharedManager] startAuthenticateBridgeWithIpAddress:item.ipAddress
                                                            bridgeId:item.bridgeId
                                                              receiver:self
                                        localConnectionSuccessSelector:@selector(didBridgeAuthenticationSuccess)
                                                     noLocalConnection:@selector(didFailed)
                                                      notAuthenticated:@selector(didFailed)];
}

- (void)didBridgeAuthenticationSuccess
{
    [self stopIndicator];
    [self showAleart:DPHueLocalizedString(_bundle, @"HueRegisterApp")];
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
            [[DPHueManager sharedManager] deallocHueSDK];
        });
    });
    [self showLightSearchPage];
}

- (void)didFailed
{
    [self stopIndicator];

    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
            [[DPHueManager sharedManager] deallocHueSDK];
        });
    });
    [self showLightSearchPage];
}


- (void)didPushlinkAuthenticationFailed
{
    [manager disableHeartbeat];
    [self stopIndicator];

    _authorizeStateLabel.text = DPHueLocalizedString(_bundle, @"HueFailAuthorize");
    [self showAleart:DPHueLocalizedString(_bundle, @"HueFailRegisterApp")];

}

- (void)didPushlinkNoLocalConnection
{
    [manager disableHeartbeat];
    [self stopIndicator];

    _authorizeStateLabel.text = DPHueLocalizedString(_bundle, @"HueFailAuthorize");;
    [self showAleart:DPHueLocalizedString(_bundle, @"HueNotConnectingBridge")];

}

- (void)didPushlinkNoLocalBridge
{
    [manager disableHeartbeat];
    [self stopIndicator];

    _authorizeStateLabel.text = DPHueLocalizedString(_bundle, @"HueFailAuthorize");
    [self showAleart:DPHueLocalizedString(_bundle, @"HueNotFoundBridge")];

}
- (void)didPushlinkButtonNotPressed
{
    //nop
}




//縦向き座標調整
- (void)setLayoutConstraintPortrait
{
    if (self.iphone) {
        if ([super iphone5]) {
            _portImageLeft.constant = 32;
            _portMessageLeft.constant = 32;
            _portInfoRight.constant = 35;
            _portInfoBottom.constant = 4;
        } else if ([super iphone6]) {
            _portImageLeft.constant = 62;
            _portMessageLeft.constant = 62;
            _portInfoRight.constant = 65;
            _portInfoBottom.constant = 45;
        } else if ([super iphone6p]) {
            _portImageLeft.constant = 72;
            _portMessageLeft.constant = 72;
            _portInfoRight.constant = 85;
            _portInfoBottom.constant = 55;
        }
 
    }else{
        if ([super ipadMini]) {
            _portImageLeft.constant = 128;
            _portMessageLeft.constant = 128;
        } else {
            _portImageLeft.constant = 268;
            _portMessageLeft.constant = 268;
        }
    }

}

//横向き座標調整
- (void)setLayoutConstraintLandscape
{
    if (self.iphone) {
        if ([super iphone5]) {
            _landInfoRight.constant = 34;
            _landInfoTop.constant = 45;
        } else if ([super iphone6]) {
            _landInfoRight.constant = 84;
            _landInfoTop.constant = 25;
        } else if ([super iphone6p]) {
            _landInfoRight.constant = 114;
            _landInfoTop.constant = 15;
        }

    } else {
        if ([super ipadMini]) {
            _portImageLeft.constant = 30;
            _portMessageLeft.constant = 30;
        } else {
            _portImageLeft.constant = 250;
            _portMessageLeft.constant = 250;
        }
    }

}
-(void)startIndicator
{
    [_pushlinkWaitIndicator startAnimating];
    
    _searchingView.hidden = NO;
}

-(void)stopIndicator
{
    [_pushlinkWaitIndicator stopAnimating];
    _searchingView.hidden = YES;
}

@end
