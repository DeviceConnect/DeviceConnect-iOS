//
//  DPThetaOmnidirectionalImage.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaOmnidirectionalImage.h"

@interface DPThetaOmnidirectionalImage() {
    NSMutableData *data;
    NSURLConnection *conn;
    DPOmniBlock omniCallback;
}
@end
@implementation DPThetaOmnidirectionalImage

- (instancetype)initWithURL:(NSURL*)url origin:(NSString*)origin callback:(DPOmniBlock)callback
{
    self = [super init];
    if (self) {
        omniCallback = callback;
        _image = [[NSMutableData alloc] init];
        data = [[NSMutableData alloc] init];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

        [request addValue:origin forHTTPHeaderField:@"X-GotAPI-Origin"];

        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)nsdata{
    [data appendData:nsdata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self abort];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    _image = data;
    [self abort];
}

-(void)abort{
    if(conn != nil){
        [conn cancel];
        conn = nil;
    }

    if (omniCallback) {
        omniCallback();
    }
}
@end
