//
//  DConnectServiceListViewCell.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>

@interface DConnectServiceListViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *serviceNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *onlineStatusLabel;
@end
