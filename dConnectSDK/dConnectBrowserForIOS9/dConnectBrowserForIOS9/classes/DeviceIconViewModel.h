//
//  DeviceIconViewModel.h
//  dConnectBrowserForIOS9
//
//  Created by Tetsuya Hirano on 2016/07/01.
//  Copyright © 2016年 GClue,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DeviceIconViewModel : NSObject

@property(nonatomic, strong) DConnectMessage* message;
@property(nonatomic) NSString* name;
@property(nonatomic) NSString* idName;
@property(nonatomic) NSString* type;
@property(nonatomic) UIImage* iconImage;
@property(nonatomic) NSString* typeIconFilename;
@property(nonatomic) BOOL isOnline;

@end
