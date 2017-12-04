//
//  DPAWSIoTStunClient.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTStunClient.h"
#import "DPAWSIoTDomainResolution.h"
#import "DPAWSIoTUDPConnection.h"
#import "DPAWSIoTP2PUtil.h"

@interface DPAWSIoTStunClient () <DPAWSIoTUDPConnectionDelegate>

@end

@implementation DPAWSIoTStunClient {
    DPAWSIoTDomainResolution *_host;
    DPAWSIoTUDPConnection *_server;
    NSString *_stunAddress;
    NSString *_stunServer;
    int _stunPort;
    StunBindingRequestCallback _callback;
    AWSIoTUtilTimerCancelBlock _cancelBlock;
    int _retryCount;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _stunServer = @"stun1.l.google.com";
        _stunPort = 19302;
        _retryCount = 0;
    }
    return self;
}

- (void) bindingRequest:(StunBindingRequestCallback)callback
{
    _callback = callback;
    if (_stunAddress) {
        [self doBindingRequest:_stunAddress];
    } else {
        __weak typeof(self) weakSelf = self;

        _host = [DPAWSIoTDomainResolution new];
        [_host resolveHostName:_stunServer callback:^(int type, NSString *address) {
            if (address) {
                [weakSelf doBindingRequest:address];
            } else {
                callback(nil, 0);
            }
        }];
    }
}

#pragma mark - Private Method

- (void) timeout:(NSString *)address;
{
    [_server close];
    _server = nil;

    _retryCount++;
    if (_retryCount < 3) {
        [self doBindingRequest:address];
    } else {
        if (_callback) {
            _callback(nil, 0);
        }
    }
}

- (void) doBindingRequest:(NSString *)address
{
    _stunAddress = address;
    
    _server = [[DPAWSIoTUDPConnection alloc] initWithPort:0];
    _server.delegate = self;
    [_server open];
    
    __weak typeof(self) weakSelf = self;
    
    _cancelBlock = [DPAWSIoTP2PUtil asyncAfterDelay:3 block:^{
        [weakSelf timeout:address];
    }];
}

- (NSString *)extractIP:(NSData *)rawIP
{
    unsigned char *n = (unsigned char *)[rawIP bytes];
    int value1 = n[0];
    int value2 = n[1];
    int value3 = n[2];
    int value4 = n[3];
    return [NSString stringWithFormat:@"%d.%d.%d.%d", value1, value2, value3, value4];
}

- (NSString *)extractPort:(NSData *)rawPort
{
    unsigned port = 0;
    NSScanner *scanner = [NSScanner scannerWithString:[[rawPort description] substringWithRange:NSMakeRange(1, 4)]];
    [scanner scanHexInt:&port];
    
    return [NSString stringWithFormat:@"%d", port];
}

- (void) parse:(NSData *)data
{
    NSData *maddr = nil;
    NSData *mport = nil;
    NSData *xmaddr = nil;
    NSData *xmport = nil;
    
    int i = 20;
    
    NSData *mappedAddressData = [data subdataWithRange:NSMakeRange(i, 2)];
    
    if ([mappedAddressData isEqualToData:[NSData dataWithBytes:"\x00\x01" length:2]]) { // MAPPED-ADDRESS
        int maddrStartPos = i + 2 + 2 + 1 + 1;
        mport = [data subdataWithRange:NSMakeRange(maddrStartPos, 2)];
        maddr = [data subdataWithRange:NSMakeRange(maddrStartPos + 2, 4)];
    }
    
    if ([mappedAddressData isEqualToData:[NSData dataWithBytes:"\x80\x20" length:2]] || // XOR-MAPPED-ADDRESS
        [mappedAddressData isEqualToData:[NSData dataWithBytes:"\x00\x20" length:2]]) {
        int xmaddrStartPos = i + 2 + 2 + 1 + 1;
        xmport=[data subdataWithRange:NSMakeRange(xmaddrStartPos, 2)];
        xmaddr=[data subdataWithRange:NSMakeRange(xmaddrStartPos + 2, 4)];
    }
    
    NSString *ip = nil;
    NSString *port = nil;
    
    if (maddr != nil) {
        ip = [self extractIP:maddr];
        port = [self extractPort:mport];
    } else {
        NSLog(@"STUN No MAPPED-ADDRESS found.");
    }
    
    [_server close];
    _server = nil;
    _cancelBlock();
    _cancelBlock = nil;
    
    if (_callback) {
        _callback(ip, (int)[port integerValue]);
    }
}

#pragma mark - DPAWSIoTUDPConnectionDelegate

- (void) didConnect
{
    const char bindingRequest[2] = {0x0, 0x1};
    const char attribute[2] = {0x0, 0x08};
    const char changeRequest[2] = {0x0, 0x03};
    const char attributeSize[2] = {0x0, 0x04};
    const char attributeBody[4] = {0x0, 0x0, 0x0, 0x0};
    
    unsigned char uuidBytes[16];
    NSUUID *uuid = [NSUUID UUID];
    [uuid getUUIDBytes:uuidBytes];
    
    NSMutableData *request = [NSMutableData data];
    [request appendBytes:bindingRequest length:sizeof(bindingRequest)];
    [request appendBytes:attribute length:sizeof(attribute)];
    [request appendBytes:uuidBytes length:sizeof(uuidBytes)];
    [request appendBytes:changeRequest length:sizeof(changeRequest)];
    [request appendBytes:attributeSize length:sizeof(attributeSize)];
    [request appendBytes:attributeBody length:sizeof(attributeBody)];

    [_server sendData:(const char *)[request bytes] length:(int)[request length] to:_stunAddress port:_stunPort];
}

- (void) didNotConnect
{
    if (_callback) {
        _callback(nil, 0);
    }
}

- (void) didReceivedData:(NSData *)data address:(NSString *)address port:(int)port
{
    [self parse:data];
}

@end
