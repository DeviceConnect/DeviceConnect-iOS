//
//  DeviceIconViewModel.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
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
