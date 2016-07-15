//
//  GHBookmarkCell.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "GHData.h"

@interface GHBookmarkCell : UITableViewCell
@property (nonatomic, weak) Page *myPage;
- (void)configureCell:(Page *)page atIndexPath:(NSIndexPath *)indexPath isEditing:(BOOL)isEditing;
@end
