//
//  DPHueSettingViewController3.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHueSettingViewController3.h"
@interface DPHueSettingViewController3 ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lightSearchingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *lightOffIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lightOnIconImageView;

#pragma mark - Portrait Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portImageCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portMessageCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portInfoCenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portInfoRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portInfoBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portImageLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portMessageLeft;
#pragma mark - Landscape Constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landInfoTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landInfoRight;

#pragma mark - Common Constraints
@end

@implementation DPHueSettingViewController3

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
                           _portMessageCenter,
                           _portInfoCenter, nil];
    } else {
        portConstraints = [NSArray arrayWithObjects:
                           _portInfoBottom,
                           _portImageCenter,
                           _portInfoCenter, nil];
    }
    landConstraints = [NSArray arrayWithObjects:
                       _landInfoRight,
                       _landInfoTop, nil];

}




- (IBAction)searchLight:(id)sender
{
    [self showLightListPage];
    
}

//縦向き座標調整
- (void)setLayoutConstraintPortrait
{
    if (self.iphone) {
        if ([super iphone5]) {
            _portImageLeft.constant = 58;
            _portMessageLeft.constant = 58;
            _portInfoRight.constant = 44;
            _portInfoBottom.constant = 14;
        } else if ([super iphone6]) {
            _portImageLeft.constant = 88;
            _portMessageLeft.constant = 88;
            _portInfoRight.constant = 75;
            _portInfoBottom.constant = 14;
        } else if ([super iphone6p]) {
            _portImageLeft.constant = 98;
            _portMessageLeft.constant = 98;
            _portInfoRight.constant = 95;
            _portInfoBottom.constant = 14;
        }
    }else{
        if ([super ipadMini]) {
            _portImageLeft.constant = 204;
        } else {
            _portImageLeft.constant = 268;
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

    }else{
        if ([super ipadMini]) {
            _portImageLeft.constant = 80;
        } else {
            _portImageLeft.constant = 268;
        }

    }
}

-(void)startIndicator
{
    [_lightSearchingIndicator startAnimating];
    _lightSearchingIndicator.hidden = NO;
}

-(void)stopIndicator
{
    [_lightSearchingIndicator stopAnimating];
    _lightSearchingIndicator.hidden = YES;
}
@end
