//
//  DPIRKitManager.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitManager.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitDevice.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "NSString+Hex.h"
#import "DPIRKitConst.h"
#import "DPIRKitService.h"
#import "DPIRKitVirtualService.h"
#import "DPIRKitVirtualDevice.h"

NSString *const DPIRKitInternetHost = @"api.getirkit.com";
NSString *const DPIRKitDeviceHost = @"192.168.1.1";
NSString *const DPIRKitServiceType = @"_irkit._tcp.";
NSString *const DPIRKitDomain = @"local.";
NSString *const DPIRKitModuleKey = @"Server";
NSString *const DPIRKitModuleValue = @"IRKit";

const NSTimeInterval DPIRKitResolveTimeout = 0.5;
const NSTimeInterval DPIRKitHttpRequestTimeout = 5;
const int DPIRKitMaxWiFiSSIDLength = 32;
const int DPIRKitMaxWiFiPasswordLength = 63;
const int DPIRKitMaxKeyLength = 32;

NSString *const DPIRKitUDKeySSID = @"org.deviceconnect.ios.DPIRKit.ssid";
NSString *const DPIRKitUDKeySecType = @"org.deviceconnect.ios.DPIRKit.security";
NSString *const DPIRKitUDKeyPassword = @"org.deviceconnect.ios.DPIRKit.password";
NSString *const DPIRKitUDKeyClientKey = @"org.deviceconnect.ios.DPIRKit.client_key";
NSString *const DPIRKitUDKeyDeviceKey = @"org.deviceconnect.ios.DPIRKit.device_key";
NSString *const DPIRKitUDKeyServiceId = @"org.deviceconnect.ios.DPIRKit.device_id";

NSString *const DPIRKitXRequestedWithHeaderName = @"X-Requested-With";
NSString *const DPIRKitXRequestedWithHeaderValue = @"IRKit Device Plug-in";

struct DPIRKitCRCInfo
{
    uint8_t security;
    char ssid[DPIRKitMaxWiFiSSIDLength + 1];
    char password[DPIRKitMaxWiFiPasswordLength + 1];
    bool wifi_is_set;
    bool wifi_was_valid;
    char temp_key[DPIRKitMaxKeyLength + 1];
} __attribute__((packed));

@interface DPIRKitManager()<NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    NSMutableDictionary *_services;
    NSMutableDictionary *_devices;
    NSNetServiceBrowser *_browser;
}

- (NSDictionary *) dictionaryWithJSONData:(NSData *)jsonData;

- (NSMutableURLRequest *) requestWithHost:(NSString *)host path:(NSString *)path;
- (NSURLRequest *) createGetRequestWithHost:(NSString *)host path:(NSString *)path;
- (NSURLRequest *) createPostRequestWithHost:(NSString *)host path:(NSString *)path body:(NSString *)body;

// WiFi接続用シリアライズ

- (NSString *) securityCodeForType:(DPIRKitWiFiSecurityType)type;
- (NSString *) regdomain;
- (uint8_t) crc8WithData:(uint8_t *)data size:(uint16_t) size;

@end

@implementation DPIRKitManager

#pragma mark - Initialization

- (id) init {
    
    self = [super init];
    
    if (self) {
        // UIスレッドで生成しないといけないため、使用側でUIスレッドで作成する。
        _services = [NSMutableDictionary dictionary];
        _devices = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Private Methods

- (NSMutableURLRequest *) requestWithHost:(NSString *)host path:(NSString *)path {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", host, path]];
    return [NSMutableURLRequest requestWithURL:url];
}

- (NSURLRequest *) createGetRequestWithHost:(NSString *)host path:(NSString *)path {
    
    NSMutableURLRequest *req = [self requestWithHost:host path:path];
    
    req.HTTPMethod = @"GET";
    req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    req.timeoutInterval = DPIRKitHttpRequestTimeout;
    [req setValue:DPIRKitXRequestedWithHeaderValue forHTTPHeaderField:DPIRKitXRequestedWithHeaderName];
    
    return req;
}

- (NSURLRequest *) createPostRequestWithHost:(NSString *)host path:(NSString *)path body:(NSString *)body {
    
    NSMutableURLRequest *req = [self requestWithHost:host path:path];
    req.HTTPMethod = @"POST";
    req.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    req.timeoutInterval = DPIRKitHttpRequestTimeout;
    [req setValue:DPIRKitXRequestedWithHeaderValue forHTTPHeaderField:DPIRKitXRequestedWithHeaderName];
    req.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    
    return req;
}

- (NSDictionary *) dictionaryWithJSONData:(NSData *)jsonData {
    
    @try {
        id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:NSJSONReadingAllowFragments
                                                       error:nil];
        if (![jsonObj isKindOfClass:[NSDictionary class]]) {
            DPIRLog(@"not json");
            return nil;
        }
        
        NSDictionary *json = (NSDictionary *) jsonObj;
        return json;
    }
    @catch (NSException *exception) {
        DPIRLog(@"json error : %@", exception);
        return nil;
    }
}

#pragma mark Serialize
- (NSString *) securityCodeForType:(DPIRKitWiFiSecurityType)type {
    if (type == DPIRKitWiFiSecurityTypeNone) {
        return @"0";
    } else if (type == DPIRKitWiFiSecurityTypeWEP) {
        return @"2";
    }
    return @"8";
}

- (NSString *)regdomain {
    NSString *regdomain;
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *countryCode = [[carrier isoCountryCode] uppercaseString];
    
    if (!countryCode) {
        countryCode = [[[NSLocale currentLocale] objectForKey: NSLocaleCountryCode] uppercaseString];
    }
    if ([countryCode isEqualToString: @"JP"]) {
        regdomain = @"2";
    } else if ([@[@"CA", @"MX", @"US", @"AU", @"HK", @"IN", @"MY",
                @"NZ", @"PH", @"TW", @"RU", @"AR", @"BR", @"CL",
                @"CO", @"CR", @"DO", @"DM", @"EC", @"PA", @"PY",
                @"PE", @"PR", @"VE"] containsObject : countryCode])
    {
        regdomain = @"0";
    }
    else {
        regdomain = @"1";
    }
    return regdomain;
}

- (uint8_t) crc8WithData:(uint8_t *)data size:(uint16_t)size {
    
    uint8_t crc;
    
    crc = 0x00;
    
    while (size--) {
        crc ^= *data++;
        
        for (uint8_t i = 0; i < 8; i++) {
            if (crc & 0x80) {
                crc = (crc << 1) ^ 0x31;
            }
            else {
                crc <<= 1;
            }
        }
    }
    
    return crc;
}

#pragma mark - Public Methods
#pragma mark Static Methods

+ (DPIRKitManager *) sharedInstance {
    
    static DPIRKitManager *instance;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[DPIRKitManager alloc] init];
    });
    
    return instance;
}

#pragma mark Instance Methods

- (void) startDetection {
    DPIRLog(@"startDetection");
    [_services removeAllObjects];
    if (_browser) {
        [self stopDetection];
    }
    _browser = [NSNetServiceBrowser new];
    _browser.delegate = self;
    [_browser searchForServicesOfType:DPIRKitServiceType inDomain:DPIRKitDomain];
}

- (void) stopDetection {
    DPIRLog(@"stopDetection");
    [_browser stop];
    [_browser removeFromRunLoop:[NSRunLoop currentRunLoop]
                        forMode:NSRunLoopCommonModes];
    _browser = nil;
}

- (void) fetchMessageWithHostName:(NSString *)hostName completion:(void (^)(NSString *))completion {
    
    __weak typeof(self) _self = self;
    DPIR_ASYNC_S
    
    NSURLRequest *req = [_self createGetRequestWithHost:hostName path:@"/messages"];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // レスポンスが成功か失敗かを見てそれぞれ処理を行う
        if (response && ! error) {
            completion([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            DPIRLog(@"Get Message : no-body");
            completion(nil);
        }
        
    }] resume];
    DPIR_ASYNC_E
}

- (void) sendMessage:(NSString *)message
        withHostName:(NSString *)hostName
          completion:(void (^)(BOOL))completion
{
    __weak typeof(self) _self = self;
    DPIR_ASYNC_S
    
    NSURLRequest *req = [_self createPostRequestWithHost:hostName path:@"/messages" body:message];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!response || ((NSHTTPURLResponse *) response).statusCode != 200) {
            DPIRLog(@"Post request failed.");
            completion(NO);
        } else {
            DPIRLog(@"Message posted.");
            completion(YES);
        }
        
    }] resume];
    DPIR_ASYNC_E
}

- (void) fetchClientKeyWithCompletion:(void (^)(NSString *, DPIRKitConnectionErrorCode))completion {
    
    DPIR_ASYNC_S
    
    NSString *param = [NSString stringWithFormat:@"apikey=%@", _apiKey];
    NSURLRequest *req = [self createPostRequestWithHost:DPIRKitInternetHost path:@"/1/clients" body:param];
    // DConnectのAPIから呼ばれず、設定画面から呼ぶことになるので長めに設定しておく。
    ((NSMutableURLRequest *)req).timeoutInterval = 30;
    __block NSString *clientKey = nil;
    

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error && (error.code == NSURLErrorTimedOut) && [error.domain isEqualToString: NSURLErrorDomain]) {
            completion(nil, DPIRKitConnectionErrorCodeServerNotReachable);
            return;
        }
        
        if (data) {
            @try {
                id jsonObj = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
                if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *json = (NSDictionary *) jsonObj;
                    clientKey = json[@"clientkey"];
                }
            }
            @catch (NSException *exception) {
                clientKey = nil;
            }
        }
        
        if (clientKey) {
            completion(clientKey, DPIRKitConnectionErrorCodeNone);
        } else {
            completion(nil, DPIRKitConnectionErrorCodeFailed);
        }
        
    }] resume];
    DPIR_ASYNC_E
    
}

- (void) createNewDeviceWithClientKey:(NSString *)clientKey
                           completion:(void (^)(NSString *serviceId, NSString *deviceKey,
                                                DPIRKitConnectionErrorCode errorCode))completion
{
    
    __weak typeof(self) _self = self;
    
    DPIR_ASYNC_S
    
    __block NSString *serviceId = nil;
    __block NSString *deviceKey = nil;
    
    NSString *param = [NSString stringWithFormat:@"clientkey=%@", clientKey];
    NSURLRequest *req = [_self createPostRequestWithHost:DPIRKitInternetHost path:@"/1/devices" body:param];
    // DConnectのAPIから呼ばれず、設定画面から呼ぶことになるので長めに設定しておく。
    ((NSMutableURLRequest *)req).timeoutInterval = 30;

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error && (error.code == NSURLErrorTimedOut) && [error.domain isEqualToString: NSURLErrorDomain]) {
            completion(nil, nil, DPIRKitConnectionErrorCodeServerNotReachable);
            return;
        }
        
        @try {
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *json = (NSDictionary *) jsonObj;
                deviceKey = json[@"devicekey"];
                serviceId = json[@"deviceid"];
            }
        }
        @catch (NSException *exception) {
            deviceKey = nil;
            serviceId = nil;
        }
        
        if (!serviceId || !deviceKey) {
            completion(nil, nil, DPIRKitConnectionErrorCodeFailed);
        } else {
            completion(serviceId, deviceKey, DPIRKitConnectionErrorCodeNone);
        }
        
    }] resume];
    DPIR_ASYNC_E
}

- (void) checkIfCurrentSSIDIsIRKitWithCompletion:(void (^)(BOOL, NSError *))callback
{
    
    __weak typeof(self) _self = self;
    
    DPIR_ASYNC_S
    
    NSURLRequest *req = [_self createGetRequestWithHost:DPIRKitDeviceHost path:@"/"];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL result = false;
        do {
            if (error) {
                break;
            }
            
            NSHTTPURLResponse *httpRes = (NSHTTPURLResponse *) response;
            DPIRLog(@"Headers : %@", httpRes.allHeaderFields);
            NSString *value = httpRes.allHeaderFields[DPIRKitModuleKey];
            NSArray *info = [value componentsSeparatedByString:@"/"];
            
            if (info.count != 2) {
                break;
            }
            
            NSString *moduleName = info[0];
            result = [moduleName isEqualToString:DPIRKitModuleValue];
            
        } while (false);
        
        callback(result, error);

        
    }] resume];
    
    DPIR_ASYNC_E
}

- (void) connectIRKitToWiFiWithSSID:(NSString *)ssid
                           password:(NSString *)password
                       securityType:(DPIRKitWiFiSecurityType)type
                          deviceKey:(NSString *)deviceKey
                         completion:(void (^)(BOOL, DPIRKitConnectionErrorCode))completion
{
    
    __weak typeof(self) _self = self;
    
    DPIR_ASYNC_S
    
    NSString *secCode = [_self securityCodeForType:type];
    NSString *ssidHex = [ssid stringByHexingWithLength:DPIRKitMaxWiFiSSIDLength + 1];
    
    NSString *tmpPassword = password;
    if (type == DPIRKitWiFiSecurityTypeWEP && (password.length == 5 || password.length == 13)) {
        tmpPassword = [password stringByHexingWithLength:DPIRKitMaxWiFiPasswordLength + 1];
    }
    
    NSString *passHex = [tmpPassword stringByHexingWithLength:DPIRKitMaxWiFiPasswordLength + 1];
    
    const char *ssidUTF8 = [ssid UTF8String];
    const char *passUTF8 = [tmpPassword UTF8String];
    const char *deviceKeyUTF8 = [deviceKey UTF8String];
    
    struct DPIRKitCRCInfo crced;
    memset(&crced, 0, sizeof(struct DPIRKitCRCInfo) );
    strncpy(crced.ssid, ssidUTF8, strnlen(ssidUTF8, DPIRKitMaxWiFiSSIDLength + 1));
    strncpy(crced.password, passUTF8,  strnlen(passUTF8, DPIRKitMaxWiFiPasswordLength + 1));
    strncpy(crced.temp_key, deviceKeyUTF8, strnlen(deviceKeyUTF8, DPIRKitMaxKeyLength + 1));
    crced.wifi_is_set = true;
    crced.wifi_was_valid = false;
    crced.security = type;
    uint8_t crc = [_self crc8WithData:(uint8_t *)&crced size:sizeof(struct DPIRKitCRCInfo)];
    NSString *crcHex = [NSString stringWithFormat: @"%02x", crc];
    
    NSArray *components = @[
                            secCode,
                            ssidHex,
                            passHex,
                            deviceKey,
                            [_self regdomain],
                            @"",
                            @"",
                            @"",
                            @"",
                            @"",
                            crcHex,
                            ];
    NSString *data = [[components componentsJoinedByString: @"/"] uppercaseString];
    DPIRLog(@"data : %@", data);
    NSURLRequest *req = [_self createPostRequestWithHost:DPIRKitDeviceHost path:@"/wifi" body:data];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            DPIRLog(@"error : %@", error);
            completion(NO, DPIRKitConnectionErrorCodeDeviceNotReachable);
            return;
        }
        
        if (((NSHTTPURLResponse *) response).statusCode == 200) {
            completion(YES, DPIRKitConnectionErrorCodeNone);
        } else {
            completion(NO, DPIRKitConnectionErrorCodeFailed);
        }
    }] resume];
    
    
    
    DPIR_ASYNC_E
}

- (void) checkIfIRKitIsConnectedToInternetWithClientKey:(NSString *)clientKey
                                             completion:(void (^)(BOOL))completion
{
    __weak typeof(self) _self = self;
    
    DPIR_ASYNC_S
    
    // IRKit本体まで取りにいくようにclearを指定しておく
    NSString *path = [NSString stringWithFormat:@"/1/messages?clientkey=%@&clear=1", clientKey];
    NSURLRequest *req = [_self createGetRequestWithHost:DPIRKitInternetHost path:path];
    ((NSMutableURLRequest *) req).timeoutInterval = 30;
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error || !data || data.length == 0) {
            DPIRLog(@"Device is not on internet.");
            completion(NO);
        } else {
            completion(YES);
        }
    }] resume];

    
    DPIR_ASYNC_E
    
    
}

- (void) checkIfIRKitIsConnectedToInternetWithClientKey:(NSString *)clientKey
                                               serviceId:(NSString *)serviceId
                                             completion:(void (^)(BOOL))completion
{
    
    __weak typeof(self) _self = self;
    
    DPIR_ASYNC_S
    
    NSString *param = [NSString stringWithFormat:@"clientkey=%@&deviceid=%@", clientKey, serviceId];
    
    NSURLRequest *req = [_self createPostRequestWithHost:DPIRKitInternetHost path:@"/1/door" body:param];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            DPIRLog(@"error : %@", error);
            completion(NO);
            return;
        }
        
        NSString *hostName = nil;
        @try {
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (![jsonObj isKindOfClass:[NSDictionary class]]) {
                DPIRLog(@"not json");
                completion(NO);
                return;
            }
            
            NSDictionary *json = (NSDictionary *) jsonObj;
            hostName = json[@"hostname"];
        }
        @catch (NSException *exception) {
            hostName = nil;
        }
        
        DPIRLog(@"hostname : %@", hostName);
        if (hostName) {
            completion(YES);
        } else {
            completion(NO);
        }
    }] resume];
    
    
    DPIR_ASYNC_E
}

- (void) fetchDeviceInfoWithDeviceHost:(NSString *)host
                        withCompletion:(void (^)(NSString *, NSString *))completion
{
    __weak typeof(self) _self = self;
    
    DPIR_ASYNC_S
    
    __block NSString *serviceId = nil;
    __block NSString *clientKey = nil;
    __block NSURLRequest *req = [_self createPostRequestWithHost:host path:@"/keys" body:@""];

    __block NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        do {
            if (!data) {
                break;
            }
            
            __block NSDictionary *json = [_self dictionaryWithJSONData:data];
            if (!json) {
                break;
            }
            
            NSString *clientToken = json[@"clienttoken"];
            if (!clientToken) {
                break;
            }
            
            req = [_self createPostRequestWithHost:DPIRKitInternetHost
                                              path:@"/1/keys"
                                              body:[NSString stringWithFormat:@"clienttoken=%@", clientToken]];
            ((NSMutableURLRequest *) req).timeoutInterval = 30;
            [[session dataTaskWithRequest:req  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                
                do {
                    if (!data) {
                        break;
                    }
                    
                    json = [_self dictionaryWithJSONData:data];
                    if (!json) {
                        break;
                    }
                    
                    serviceId = json[@"deviceid"];
                    clientKey = json[@"clientkey"];
                } while (NO);
                completion(serviceId, clientKey);
            }] resume];
        } while (NO);
    }] resume];
    DPIR_ASYNC_E
}




#pragma mark - NSNetServiceBrowserDelegate

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
            didFindService:(NSNetService *)aNetService
                moreComing:(BOOL)moreComing
{
    
    if (_detectionDelegate) {
        aNetService.delegate = self;
        [aNetService resolveWithTimeout:DPIRKitResolveTimeout];
        
        _services[aNetService.name] = aNetService;
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
          didRemoveService:(NSNetService *)aNetService
                moreComing:(BOOL)moreComing
{
    if (_detectionDelegate) {
        DPIRKitDevice *device = [DPIRKitDevice new];
         // 検索の度に大文字、小文字が変化するので統一しておく。
        device.name = [aNetService.name uppercaseString];
        [_detectionDelegate manager:self didLoseDevice:device];
    }
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
              didNotSearch:(NSDictionary *)errorDict
{
    [self stopDetection];
}

#pragma mark - NSNetServiceDelegate

- (void) netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [_services removeObjectForKey:sender.name];
}

- (void) netServiceDidResolveAddress:(NSNetService *)sender {
    DPIRKitDevice *device = [DPIRKitDevice new];
     // 検索の度に大文字、小文字が変化するので統一しておく。
    device.name = [sender.name uppercaseString];
    device.hostName = sender.hostName;
    DPIRKitDevice *irkit = _devices[device.name];
    
    if (!irkit) {
        _devices[device.name] = device;
    }

    [_detectionDelegate manager:self didFindDevice:device];
    [self netService:sender didNotResolve:@{}];
}

#pragma mark - get Devices

- (NSArray *)devicesAll {
    return [_devices allValues];
}

- (DPIRKitDevice *)deviceForServiceId:(NSString *)serviceId {
    return _devices[serviceId];
}

@end
