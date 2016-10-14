//
//  GHDevicePluginViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/07.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHDevicePluginViewModel : NSObject
@property (nonatomic, strong) NSArray* datasource;
- (NSDictionary*)makePlguinAndProfiles:(NSInteger)index;
@end
