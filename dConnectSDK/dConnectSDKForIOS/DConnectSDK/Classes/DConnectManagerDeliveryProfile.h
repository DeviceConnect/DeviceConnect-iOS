//
//  DConnectManagerDeliveryProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProfile.h"
#import "DConnectEventBroker.h"

/**
 * デバイスプラグインにリクエストを配送するためのプロファイル.
 */
@interface DConnectManagerDeliveryProfile : DConnectProfile

@property(nonatomic, weak) DConnectEventBroker *eventBroker;

@property(nonatomic, weak) DConnectWebSocket *webSocket;

@end
