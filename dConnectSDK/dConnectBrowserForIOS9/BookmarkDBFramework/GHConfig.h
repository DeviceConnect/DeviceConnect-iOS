//
//  GHConfig.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "GHUtils.h"

@protocol GHConfig <NSObject>

#define TYPE_FAVORITE @"favorite"
#define TYPE_BOOKMARK @"bookmark"
#define TYPE_HISTORY  @"history"
#define TYPE_FOLDER   @"folder"
#define TYPE_BOOKMARK_FOLDER @"bookmark_folder"

#define IS_FIRST_LAUNCH @"is_first_launch"

#define IS_MANAGER_LAUNCH @"is_manager_launch"
#define IS_ORIGIN_BLOCKING @"is_origin_blocking"

#define PAGE_URL @"pageurl"

//Categoryキー
#define CATEGORY_FAVORITE @"favorite"
#define CATEGORY_HISTORY  @"history"

//通知キー
#define ADD_BOOKMARK @"addbookmark"
#define SHOW_WEBPAGE @"showwebpage"
#define SHOW_PRINT @"print"
#define CLEAR_HISTORY @"clear_history"

#define PRIORITY 100
@end
