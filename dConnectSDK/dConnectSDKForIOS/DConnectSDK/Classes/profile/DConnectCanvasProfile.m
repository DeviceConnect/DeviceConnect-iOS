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
NSString *const DConnectCanvasProfileParamURI = @"uri";
NSString *const DConnectCanvasProfileParamX        = @"x";
NSString *const DConnectCanvasProfileParamY        = @"y";
NSString *const DConnectCanvasProfileParamMode     = @"mode";

// Parameter(Mode)
NSString *const DConnectCanvasProfileModeScales = @"scales";
NSString *const DConnectCanvasProfileModeFills  = @"fills";


@implementation DConnectCanvasProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectCanvasProfileName;
}

#pragma mark - Setter

+ (void) setMIMEType:(NSString *)mimeType target:(DConnectMessage *)message {
    [message setString:mimeType forKey:DConnectCanvasProfileParamMIMEType];
}

+ (void) setData:(NSData *)data target:(DConnectMessage *)message {
    [message setData:data forKey:DConnectCanvasProfileParamData];
}

+ (void) setURI:(NSString *)uri target:(DConnectMessage *)message {
    [message setString:uri forKey:DConnectCanvasProfileParamURI];
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

+ (NSString *) uriFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectCanvasProfileParamURI];
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

- (BOOL) isMimeTypeWithString: (NSString *)mimeTypeString {

    // create characterset
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString: @"-_."];
    
    // check
    NSArray *splits = [mimeTypeString componentsSeparatedByString:@"/"];
    if (splits != nil) {
        NSInteger count = [splits count];
        if (count >= 2) {
            for (int i = 0; i < count; i++) {
                NSString *split = [splits objectAtIndex: i];
                NSCharacterSet *charsetSplit = [NSCharacterSet characterSetWithCharactersInString: split];
                
                if (![characterSet isSupersetOfSet: charsetSplit]) {
                    return NO;
                }
            }
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
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
