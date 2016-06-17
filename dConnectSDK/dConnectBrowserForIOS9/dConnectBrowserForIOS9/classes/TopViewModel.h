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

- (void)initialSetup;
- (void)finishOriginBlock;
- (NSString*)checkUrlString:(NSString*)url;
- (NSString*)makeURLFromNotification:(NSNotification*)notif;

@end
