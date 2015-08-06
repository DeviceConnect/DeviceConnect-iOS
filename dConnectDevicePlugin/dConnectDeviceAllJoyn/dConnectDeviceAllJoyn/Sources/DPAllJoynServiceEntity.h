//
//  DPAllJoynServiceEntity.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AJNSessionOptions.h>


@class AJNMessageArgument;


@interface DPAllJoynServiceEntity : NSObject

/**
 * Human-friendly service name.
 */
@property NSString *serviceName;
@property NSString *busName; // @NonNull
@property AJNSessionPort port;

@property AJNMessageArgument *aboutData;
// Flattened data from aboutData
@property NSString *appId;
@property NSString *defaultLanguage;
@property NSString *deviceName;
@property NSString *deviceId;
@property NSString *appName;
@property NSString *manufacturer;
@property NSString *modelNumber;
@property NSArray *supportedLanguages;
@property NSString *aboutDescription;
@property NSString *dateOfManufacture;
@property NSString *softwareVersion;
@property NSString *ajSoftwareVersion;
@property NSString *hardwareVersion;
@property NSString *supportUrl;

@property AJNMessageArgument *busObjectDescriptionArg; // @NonNull
// Remapped data from busObjectDescriptionArg
// object path -> key, interfaces -> value
@property NSDictionary *busObjectDescriptions;

@property NSDate *lastAlive;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithBusName:(NSString *)busName
                            port:(AJNSessionPort)port
                       aboutData:(AJNMessageArgument *)aboutData
           busObjectDescriptions:(AJNMessageArgument *)busObjectDescriptionArg
NS_DESIGNATED_INITIALIZER;

@end
