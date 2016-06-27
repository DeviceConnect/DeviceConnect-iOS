//
//  ViewController.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "GHHeaderView.h"
#import <SafariServices/SafariServices.h>

@interface ViewController : UIViewController<GHHeaderViewDelegate, SFSafariViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>


@end

