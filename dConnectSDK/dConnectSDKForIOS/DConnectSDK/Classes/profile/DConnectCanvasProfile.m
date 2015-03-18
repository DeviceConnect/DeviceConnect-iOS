//
//  DConnectCanvasProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectCanvasProfile.h"


// Profile Name
NSString *const DConnectCanvasProfileName = @"canvas";

// Atttribute
NSString *const DConnectCanvasProfileAttrDrawImage = @"drawimage";

// Parameter
NSString *const DConnectCanvasProfileParamMIMEType = @"mimeType";
NSString *const DConnectCanvasProfileParamData     = @"data";
NSString *const DConnectCanvasProfileParamX        = @"x";
NSString *const DConnectCanvasProfileParamY        = @"y";
NSString *const DConnectCanvasProfileParamMode     = @"mode";

// Parameter(Mode)
NSString *const DConnectCanvasProfileModeScales = @"scales";
NSString *const DConnectCanvasProfileModeFills  = @"fills";


@interface DConnectCanvasProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectCanvasProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectCanvasProfileName;
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    if ([attribute isEqualToString:DConnectCanvasProfileAttrDrawImage]) {
        
        if ([self hasMethod:@selector(profile:didReceivePostDrawImageRequest:response:serviceId:mimeType:data:imageX:imageY:mode:)
                   response:response])
        {
            NSData *data = [DConnectCanvasProfile dataFromRequest:request];
            NSString *serviceId = [request serviceId];
            NSString *mimeType = [DConnectCanvasProfile mimeTypeFromRequest:request];
            NSString *strX = [DConnectCanvasProfile xFromRequest: request];
            NSString *strY = [DConnectCanvasProfile yFromRequest: request];
            if (mimeType != nil && ![self checkMimeTypeFormat: mimeType]) {
                [response setErrorToInvalidRequestParameterWithMessage: @"mimeType format is incorrect."];
                return send;
            }
            if (strX != nil && ![self isFloatWithString: strX]) {
                [response setErrorToInvalidRequestParameterWithMessage: @"x is different type."];
                return send;
            }
            if (strY != nil && ![self isFloatWithString: strY]) {
                [response setErrorToInvalidRequestParameterWithMessage: @"y is different type."];
                return send;
            }
            double x = strX.doubleValue;
            double y = strY.doubleValue;
            NSString *mode = [DConnectCanvasProfile modeFromRequest: request];
            
            send = [_delegate profile:self didReceivePostDrawImageRequest:request response:response
                             serviceId:serviceId mimeType:mimeType data:data imageX:x imageY:y mode:mode];
        }

    } else {
        [response setErrorToUnknownAttribute];
    }
    
    return send;
}


- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    if ([attribute isEqualToString:DConnectCanvasProfileAttrDrawImage]) {
        
        if ([self hasMethod:@selector(profile:didReceiveDeleteDrawImageRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveDeleteDrawImageRequest:request
                             response:response
                            serviceId:serviceId];
        }
        
    } else {
        [response setErrorToUnknownAttribute];
    }
    
    return send;
}

#pragma mark - Setter

+ (void) setMIMEType:(NSString *)mimeType target:(DConnectMessage *)message {
    [message setString:mimeType forKey:DConnectCanvasProfileParamMIMEType];
}

+ (void) setData:(NSData *)data target:(DConnectMessage *)message {
    [message setData:data forKey:DConnectCanvasProfileParamData];
}

+ (void) setX:(double)x target:(DConnectMessage *)message {
    [message setDouble:x forKey:DConnectCanvasProfileParamX];
}

+ (void) setY:(double)y target:(DConnectMessage *)message {
    [message setDouble:y forKey:DConnectCanvasProfileParamY];
}

+ (void) setMode:(NSString *)mode target:(DConnectMessage *)message {
    [message setString:mode forKey:DConnectCanvasProfileParamMode];
}


#pragma mark - Getter

+ (NSString *) mimeTypeFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectCanvasProfileParamMIMEType];
}

+ (NSData *) dataFromRequest:(DConnectMessage *)request {
    return [request dataForKey:DConnectCanvasProfileParamData];
}

+ (NSString *) xFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectCanvasProfileParamX];
}

+ (NSString *) yFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectCanvasProfileParamY];
}

+ (NSString *) modeFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectCanvasProfileParamMode];
}

#pragma mark - Private Methods

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

- (BOOL) checkMimeTypeFormat: (NSString *)mimeType {
    
    NSRange match = [mimeType rangeOfString:@"^([a-z]+/[a-z])+$"
                                    options:NSRegularExpressionSearch];
    BOOL result = match.location != NSNotFound ? YES: NO;
    return result;
}

- (BOOL)isFloatWithString:(NSString *)numberString
{
    NSRange matchInteger = [numberString rangeOfString:@"^([0-9]*)?$"
                                               options:NSRegularExpressionSearch];
    NSRange matchFloat = [numberString rangeOfString:@"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$"
                                             options:NSRegularExpressionSearch];
    BOOL result = (matchFloat.location != NSNotFound || matchInteger.location != NSNotFound) ? YES: NO;
    return result;
}

@end
