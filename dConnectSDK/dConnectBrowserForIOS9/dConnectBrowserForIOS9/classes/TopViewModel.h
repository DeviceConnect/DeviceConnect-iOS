//
//  TopViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/06/17.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHURLManager.h"

@interface TopViewModel : NSObject
@property (strong, nonatomic) NSMutableArray* datasource;
@property (nonatomic, strong) GHURLManager *manager;
@property (nonatomic) NSString* url;
@property (nonatomic, readonly) BOOL isBookmarksEmpty;
@property (nonatomic, readonly) BOOL isDeviceEmpty;

- (void)initialSetup;
- (void)saveOriginBlock;
- (NSString*)checkUrlString:(NSString*)url;
- (NSString*)makeURLFromNotification:(NSNotification*)notif;
- (void)updateDatasource;
- (BOOL)isNeedOpenInitialGuide;

@end
