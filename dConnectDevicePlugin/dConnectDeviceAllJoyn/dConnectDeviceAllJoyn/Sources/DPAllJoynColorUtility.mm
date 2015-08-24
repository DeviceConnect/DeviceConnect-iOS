//
//  DPAllJoynColorUtility.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynColorUtility.h"

#import <AllJoynFramework_iOS.h>
#import <DCMDevicePluginSDK/DCMDevicePluginSDK.h>
#import "DPAllJoynConst.h"
#import "DPAllJoynServiceEntity.h"
#import "NSArray+Query.h"


@implementation DPAllJoynColorUtility

+ (NSDictionary *)HSBFromRGB:(NSString *)rgb
{
    NSMutableDictionary *hsb = [NSMutableDictionary dictionaryWithCapacity:3];
    uint32_t r, g, b;
    NSScanner *scanner;
    scanner =
    [NSScanner scannerWithString:[rgb substringWithRange:NSMakeRange(0, 2)]];
    [scanner scanHexInt:&r];
    scanner =
    [NSScanner scannerWithString:[rgb substringWithRange:NSMakeRange(2, 2)]];
    [scanner scanHexInt:&g];
    scanner =
    [NSScanner scannerWithString:[rgb substringWithRange:NSMakeRange(4, 2)]];
    [scanner scanHexInt:&b];
    uint32_t maxChroma = MAX(MAX(r, g), b);
    uint32_t minChroma = MIN(MIN(r, g), b);
    uint32_t diff = maxChroma - minChroma;
    
    // Hue
    // [0, 360] -> [0, 0xffffffff]
    float hue;
    if (diff == 0) {
        hue = 0;
    } else if (maxChroma == r) {
        float tmp = ((float)g - b) / diff;
        if (tmp < 0) {
            tmp += 6 * ceilf(-tmp / 6.0);
        } else {
            tmp -= 6 * floorf(tmp / 6.0);
        }
        hue = tmp;
    } else if (maxChroma == g) {
        hue = ((float)b - r) / diff + 2;
    } else {
        hue = ((float)r - g) / diff + 4;
    }
    hue *= 0xffffffffL;
    hue = floorf(hue / 6);
    // Arithmetic overflow check
    if (hue > 0xffffffffL) {
        hue = 0xffffffffL;
    }
    hsb[@"hue"] = @((uint32_t)hue);
    
    // Saturation
    if (maxChroma == 0) {
        hsb[@"saturation"] = @0;
    } else {
        // [0, 255] -> [0, 0xffffffff]
        float sat = diff;
        sat *= 0xffffffffL;
        sat = floorf(sat / maxChroma);
        // Arithmetic overflow check
        if (sat > 0xffffffffL) {
            sat = 0xffffffffL;
        }
        hsb[@"saturation"] = @((uint32_t)sat);
    }
    
    // Brightness
    // [0, 255] -> [0, 0xffffffff]
    float brightness = maxChroma;
    brightness *= 0xffffffffL;
    brightness = floorf(brightness / 0xffL);
    // Arithmetic overflow check
    if (brightness > 0xffffffffL) {
        brightness = 0xffffffffL;
    }
    hsb[@"brightness"] = @((uint32_t)brightness);
    
    return hsb;
}

@end
