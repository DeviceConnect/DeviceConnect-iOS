//
//  BookmarkIconViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/17.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Page.h"

@interface BookmarkIconViewModel : NSObject
@property (weak, nonatomic) Page* page;
- (void)bookmarkIconImage:(void (^)(UIImage*))completion;
@end
