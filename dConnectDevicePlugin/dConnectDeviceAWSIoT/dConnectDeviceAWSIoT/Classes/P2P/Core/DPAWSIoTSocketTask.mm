//
//  DPAWSIoTSocketTask.mm
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTSocketTask.h"
#define BUFFER_SIZE 512

char const HEADER[4] = {
    0x01, 0x02, 0x03, 0x04
};

@implementation DPAWSIoTSocketTask {
    UDTSOCKET _socket;
    BOOL _closeFlag;
    
    NSString *_address;
    int _port;
    
    char _sendBuffer[4];
    char _recvBuffer[4];
}

- (instancetype) initWithSocket:(UDTSOCKET)socket
{
    self = [super init];
    if (self) {
        _socket = socket;
        _closeFlag = NO;
    }
    return self;
}

- (void) setAddress:(NSString *)address
{
    _address = address;
}

- (void) setPort:(int)port
{
    _port = port;
}

- (void) sendData:(const char *)data length:(int)length;
{
    [self sendData:data offset:0 length:length];
}

- (void) sendData:(const char *)data offset:(int)offset length:(int)length
{
    if (offset < 0 || length < 0) {
        NSLog(@"DPAWSIoTSocketTask send error .");
        return;
    }
    if (length == 0) {
        return;
    }
    [self intToByte:length to:_sendBuffer];
    if (UDT::ERROR == UDT::send(_socket, HEADER, 4, 0)) {
        NSLog(@"DPAWSIoTSocketTask send error .");
        return;
    }
    if (UDT::ERROR == UDT::send(_socket, _sendBuffer, 4, 0)) {
        NSLog(@"DPAWSIoTSocketTask send error .");
        return;
    }
    int _offset = offset;
    int _length;
    while (_offset < offset + length) {
        _length = offset + length - _offset;
        if (_length > BUFFER_SIZE) {
            _length = BUFFER_SIZE;
        }

        if (UDT::ERROR == UDT::send(_socket, data + _offset, _length, 0)) {
            NSLog(@"DPAWSIoTSocketTask send error .");
            return;
        }
        _offset += _length;
    }
}

- (void) execute
{
    char data[BUFFER_SIZE];
    
    if ([_delegate respondsToSelector:@selector(didConnectedAddress:port:)]) {
        [_delegate didConnectedAddress:_address port:_port];
    }
    while (!_closeFlag) {
        if (![self readHeader]) {
            NSLog(@"DPAWSIoTSocketTask header error.");
        }
        int size = [self readSize];
        if (size == -1) {
            NSLog(@"DPAWSIoTSocketTask size error.");
            break;
        }
        while (size > 0 && !_closeFlag) {
            int rs = UDT::recv(_socket, data, BUFFER_SIZE, 0);
            if (_closeFlag || UDT::ERROR == rs) {
                NSLog(@"DPAWSIoTSocketTask UDT error...");
                break;
            }
            size -= rs;
            if ([_delegate respondsToSelector:@selector(didReceivedData:length:)]) {
                [_delegate didReceivedData:(const char *)data length:(int)rs];
            }
        }
    }
    
    if ([_delegate respondsToSelector:@selector(didDisconnetedAdderss:port:)]) {
        [_delegate didDisconnetedAdderss:_address port:_port];
    }
}

- (void) close
{
    if (_closeFlag) {
        return;
    }
    _closeFlag = YES;
    _delegate = nil;
    
    UDT::close(_socket);
}

#pragma mark - Private Method

- (void) intToByte:(int)value to:(char *)buffer
{
    buffer[0] = (char) (value & 0xff);
    buffer[1] = (char) ((value >> 8) & 0xff);
    buffer[2] = (char) ((value >> 16) & 0xff);
    buffer[3] = (char) ((value >> 24) & 0xff);
}

- (int) byteToInt:(char *)buffer
{
    return (buffer[0] & 0xff) | ((buffer[1] & 0xff) << 8) | ((buffer[2] & 0xff) << 16) | ((buffer[3] & 0xff) << 24);
}

- (BOOL) readHeader
{
    int offset = 0;
    while (offset < 4) {
        int rs = UDT::recv(_socket, _recvBuffer + offset, 1, 0);
        if (UDT::ERROR == rs) {
            NSLog(@"DPAWSIoTSocketTask error...");
            return NO;
        }
        offset += rs;
    }
    return HEADER[0] == _recvBuffer[0] && HEADER[1] == _recvBuffer[1] && HEADER[2] == _recvBuffer[2] && HEADER[3] == _recvBuffer[3];
}

- (int) readSize
{
    int offset = 0;
    while (offset < 4) {
        int rs = UDT::recv(_socket, _recvBuffer + offset, 1, 0);
        if (UDT::ERROR == rs) {
            NSLog(@"DPAWSIoTSocketTask error...");
            return -1;
        }
        offset += rs;
    }
    return [self byteToInt:_recvBuffer];
}

@end
