//
//  DConnectConst.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#define DC_SYNC_START(obj) @synchronized (obj) {
#define DC_SYNC_END }

#define DCBundle() \
[NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"DConnectManager")] pathForResource:@"DConnectSDK_resources" ofType:@"bundle"]]

#define DCLocalizedString(bundle, key) \
[bundle localizedStringForKey:key value:@"" table:nil]

#define DConnectIgnoreOrigins() \
@[@"file://"];

#define DConnectIgnoreProfiles() \
@[@"authorization", @"availability", @"files"];

#define DConnectPluginIgnoreProfiles() \
@[@"authorization", @"system", @"files", @"servicediscovery"];

#define DCPutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
    top = top.presentedViewController; \
}

// HTTPのリクエスト実行のタイムアウト 60秒
#define HTTP_REQUEST_TIMEOUT 60

/**
 storyboard名.
 */
extern NSString *const DConnectStoryboardName;

