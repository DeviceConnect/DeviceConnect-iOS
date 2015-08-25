//
//  DPThetaOmnidirectionalImage.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/20.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
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
    NSLog(@"receive");
    [data appendData:nsdata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"failed");
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
