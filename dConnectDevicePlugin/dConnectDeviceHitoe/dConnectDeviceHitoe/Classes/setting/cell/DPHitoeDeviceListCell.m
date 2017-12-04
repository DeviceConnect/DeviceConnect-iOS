//
//  DPHitoeDeviceListCell.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeDeviceListCell.h"

@interface DPHitoeDeviceListCell()
@end

@implementation DPHitoeDeviceListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(self.connect);
    [self.connect setBackgroundColor:[UIColor colorWithRed:0.00
                                                     green:0.63
                                                      blue:0.91
                                                     alpha:1.0]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
