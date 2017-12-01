//
//  BookmarkIconViewModel.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "Page.h"
#import "GHData.h"

@interface BookmarkIconViewModel : NSObject
@property (weak, nonatomic) Page* page;
- (void)bookmarkIconImage:(void (^)(UIImage*))completion;
- (void)updateOpenDate;
@end
