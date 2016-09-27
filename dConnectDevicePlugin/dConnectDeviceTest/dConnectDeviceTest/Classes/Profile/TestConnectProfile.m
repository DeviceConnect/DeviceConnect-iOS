//
//  TestConnectProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestConnectProfile.h"
#import "DeviceTestPlugin.h"

@implementation TestConnectProfile

#pragma mark - init

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestConnectProfile *weakSelf = self;
        
        // API登録(didReceiveGetWifiRequest相当)
        NSString *getWifiRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectConnectProfileAttrWifi];
        [self addGetPath: getWifiRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectConnectProfile setEnable:YES target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetBluetoothRequest相当)
        NSString *getBluetoothRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectConnectProfileAttrBluetooth];
        [self addGetPath: getBluetoothRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
           
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectConnectProfile setEnable:YES target:response];
            }
            return YES;
        }];
        
        // API登録(didReceiveGetBLERequest相当)
        NSString *getBLERequestApiPath = [self apiPath: nil
                                         attributeName: DConnectConnectProfileAttrBLE];
        [self addGetPath: getBLERequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectConnectProfile setEnable:YES target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetNFCRequest相当)
        NSString *getNFCRequestApiPath = [self apiPath: nil
                                         attributeName: DConnectConnectProfileAttrNFC];
        [self addGetPath: getNFCRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectConnectProfile setEnable:YES target:response];
            }
            return YES;
        }];
        
        // API登録(didReceivePutWiFiRequest相当)
        NSString *putWifiRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectConnectProfileAttrWifi];
        [self addPutPath: putWifiRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];

        // API登録(didReceivePutBluetoothRequest相当)
        NSString *putBluetoothRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectConnectProfileAttrBluetooth];
        [self addPutPath: putBluetoothRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            return YES;
        }];
        
        // API登録(didReceivePutBluetoothDiscoverableRequest相当)
        NSString *putBluetoothDiscoverableRequestApiPath =
                            [self apiPath: DConnectConnectProfileInterfaceBluetooth
                            attributeName: DConnectConnectProfileAttrDiscoverable];
        [self addPutPath: putBluetoothDiscoverableRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            return YES;
        }];
        
        // API登録(didReceivePutBLERequest相当)
        NSString *putBLERequestApiPath =
        [self apiPath: nil
        attributeName: DConnectConnectProfileAttrBLE];
        [self addPutPath: putBLERequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            return YES;
        }];

        // API登録(didReceivePutNFCRequest相当)
        NSString *putNFCRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectConnectProfileAttrNFC];
        [self addPutPath: putNFCRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            return YES;
        }];
        
        // API登録(didReceivePutOnWifiChangeRequest相当)
        NSString *putOnWifiChangeRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectConnectProfileAttrOnWifiChange];
        [self addPutPath: putOnWifiChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectConnectProfileAttrOnWifiChange forKey:DConnectMessageAttribute];
                
                DConnectMessage *connectStatus = [DConnectMessage message];
                [DConnectConnectProfile setEnable:YES target:connectStatus];
                
                [DConnectConnectProfile setConnectStatus:connectStatus target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnBluetoothChangeRequest相当)
        NSString *putOnBluetoothChangeRequestApiPath = [self apiPath: nil
                                                       attributeName: DConnectConnectProfileAttrOnBluetoothChange];
        [self addPutPath: putOnBluetoothChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectConnectProfileAttrOnBluetoothChange forKey:DConnectMessageAttribute];
                
                DConnectMessage *connectStatus = [DConnectMessage message];
                [DConnectConnectProfile setEnable:YES target:connectStatus];
                
                [DConnectConnectProfile setConnectStatus:connectStatus target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnBLEChangeRequest相当)
        NSString *putOnBLEChangeRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectConnectProfileAttrOnBLEChange];
        [self addPutPath: putOnBLEChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectConnectProfileAttrOnBLEChange forKey:DConnectMessageAttribute];
                
                DConnectMessage *connectStatus = [DConnectMessage message];
                [DConnectConnectProfile setEnable:YES target:connectStatus];
                
                [DConnectConnectProfile setConnectStatus:connectStatus target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnNFCChangeRequest相当)
        NSString *putOnNFCChangeRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectConnectProfileAttrOnNFCChange];
        [self addPutPath: putOnNFCChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectConnectProfileAttrOnNFCChange forKey:DConnectMessageAttribute];
                
                DConnectMessage *connectStatus = [DConnectMessage message];
                [DConnectConnectProfile setEnable:YES target:connectStatus];
                
                [DConnectConnectProfile setConnectStatus:connectStatus target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteWiFiRequest相当)
        NSString *deleteWiFiRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectConnectProfileAttrWifi];
        [self addDeletePath: deleteWiFiRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteBluetoothRequest相当)
        NSString *deleteBluetoothRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectConnectProfileAttrBluetooth];
        [self addDeletePath: deleteBluetoothRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteBluetoothDiscoverableRequest相当)
        NSString *deleteBluetoothDiscoverableRequestApiPath =
                [self apiPath: DConnectConnectProfileInterfaceBluetooth
                attributeName: DConnectConnectProfileAttrDiscoverable];
        [self addDeletePath: deleteBluetoothDiscoverableRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteBLERequest相当)
        NSString *deleteBLERequestApiPath =
                [self apiPath: nil
                attributeName: DConnectConnectProfileAttrBLE];
        [self addDeletePath: deleteBLERequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteNFCRequest相当)
        NSString *deleteNFCRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectConnectProfileAttrNFC];
        [self addDeletePath: deleteNFCRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnWifiChangeRequest相当)
        NSString *deleteOnWifiChangeRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectConnectProfileAttrOnWifiChange];
        [self addDeletePath: deleteOnWifiChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnBluetoothChangeRequest相当)
        NSString *deleteOnBluetoothChangeRequestApiPath = [self apiPath: nil
                                                          attributeName: DConnectConnectProfileAttrOnBluetoothChange];
        [self addDeletePath: deleteOnBluetoothChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnBLEChangeRequest相当)
        NSString *deleteOnBLEChangeRequestApiPath = [self apiPath: nil
                                                    attributeName: DConnectConnectProfileAttrOnBLEChange];
        [self addDeletePath: deleteOnBLEChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnNFCChangeRequest相当)
        NSString *deleteOnNFCChangeRequestApiPath = [self apiPath: nil
                                                    attributeName: DConnectConnectProfileAttrOnNFCChange];
        [self addDeletePath: deleteOnNFCChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            return YES;
        }];
    }
    
    return self;
}

@end
