//
//  DPAllJoynLightProfile.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynLightProfile.h"

#import <AllJoynFramework_iOS.h>
#import "DPAllJoynColorUtility.h"
#import "AJNLSFControllerService.h"
#import "AJNLSFLamp.h"
#import "DPAllJoynLightingResponseCode.h"
#import "DPAllJoynMessageConverter.h"
#import "DPAllJoynServiceEntity.h"
#import "DPAllJoynSupportCheck.h"


typedef NS_ENUM(NSUInteger, DPAllJoynLightServiceType) {
    DPAllJoynLightServiceTypeSingleLamp,
    DPAllJoynLightServiceTypeLampController,
    DPAllJoynLightServiceTypeUnknown,
};


// TODO: Use property LampID in org.allseen.LSF.LampDetails instead.
static NSString *const DPAllJoynLightProfileLightIDSelf = @"self";


// #############################################################################
// Interfaces
// #############################################################################
#pragma mark - Interfaces


@interface DPAllJoynLightProfile () {
    DPAllJoynHandler *_handler;
}
@end


// #############################################################################
#pragma mark -


@interface DPAllJoynLampGroup : NSObject

@property NSString *groupID;
@property NSString *name;
@property NSMutableSet *lampIDs;
@property NSMutableSet *lampGroupIDs;
@property NSString *config;

@end


// #############################################################################
#pragma mark -


@interface DPAllJoynLamp : NSObject

@property NSString *ID;
@property NSString *name;
@property NSNumber *on;
@property NSString *config;

@end


// #############################################################################
// Implementations
// #############################################################################
#pragma mark - Implementations


// TODO: Change the type of parameter 'brightness' to NSNumber.
// Though brightness is optional, it has a valid value (1.0) even if it
// was omitted. It should be nullable.
@implementation DPAllJoynLightProfile

- (instancetype)initWithHandler:(DPAllJoynHandler *)handler
{
    if (!handler) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _handler = handler;
        __weak DPAllJoynLightProfile *weakSelf = self;
        __weak DPAllJoynHandler *weakHandler = handler;
        
        // API登録(didReceiveGetLightRequest相当)
        NSString *getLightRequestApiPath = [self apiPath: nil
                                           attributeName: nil];
        [self addGetPath: getLightRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         if (!serviceId) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }
                         
                         DPAllJoynServiceEntity *service =
                         weakHandler.discoveredAllJoynServices[serviceId];
                         
                         if (!service) {
                             [response setErrorToNotFoundService];
                             return YES;
                         }
                         
                         switch ([weakSelf serviceTypeFromService:service]) {
                                 
                             case DPAllJoynLightServiceTypeSingleLamp: {
                                 [weakSelf
                                  didReceiveGetLightRequestForSingleLampWithResponse:response
                                  service:service];
                                 return NO;
                             }
                                 
                             case DPAllJoynLightServiceTypeLampController: {
                                 [weakSelf
                                  didReceiveGetLightRequestForLampControllerWithResponse:response
                                  service:service];
                                 return NO;
                             }
                                 
                             case DPAllJoynLightServiceTypeUnknown:
                             default: {
                                 [response setErrorToNotSupportAction];
                                 return YES;
                             }
                                 
                         }
                     }];

        // API登録(didReceivePostLightRequest相当)
        NSString *postLightRequestApiPath = [self apiPath: nil
                                            attributeName: nil];
        [self addPostPath: postLightRequestApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                         NSNumber *brightness = [DConnectLightProfile brightnessFromRequest: request];
                         NSString *color = [DConnectLightProfile colorFromRequest: request];
                         NSArray *flashing = [DConnectLightProfile parsePattern: [DConnectLightProfile flashingFromRequest: request] isId:NO];

                         if (flashing && ![weakSelf checkFlash:response flashing:flashing]) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }
                         
                         if (!serviceId) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }
                         
                         DPAllJoynServiceEntity *service = weakHandler.discoveredAllJoynServices[serviceId];
                         if (!service) {
                             [response setErrorToNotFoundService];
                             return YES;
                         }
                         
                         if (!lightId) {
                             [response setErrorToInvalidRequestParameterWithMessage:
                              @"Parameter 'lightId' must be specified."];
                             return YES;
                         }
                        
                         if (color
                             && (color.length != 6
                                 || ![[NSScanner scannerWithString:color] scanHexInt:nil]))
                         {
                             [response setErrorToInvalidRequestParameterWithMessage:
                              @"Parameter 'color' is invalid."];
                             [[DConnectManager sharedManager] sendResponse:response];
                             return YES;
                         }

                         switch ([weakSelf serviceTypeFromService:service]) {
                                 
                             case DPAllJoynLightServiceTypeSingleLamp: {
                                 [weakSelf
                                  didReceivePostLightRequestForSingleLampWithResponse:response
                                  service:service lightId:lightId brightness:brightness
                                  color:color flashing:flashing];
                                 return NO;
                             }
                                 
                             case DPAllJoynLightServiceTypeLampController: {
                                 [weakSelf
                                  didReceivePostLightRequestForLampControllerWithResponse:response
                                  service:service lightId:lightId brightness:brightness
                                  color:color flashing:flashing];
                                 return NO;
                             }
                                 
                             case DPAllJoynLightServiceTypeUnknown:
                             default: {
                                 [response setErrorToNotSupportAction];
                                 return YES;
                             }
                                 
                         }
                     }];
        
        // API登録(didReceivePutLightRequest相当)
        NSString *putLightRequestApiPath = [self apiPath: nil
                                           attributeName: nil];
        [self addPutPath: putLightRequestApiPath
                      api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *serviceId = [request serviceId];
                          NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                          NSNumber *brightness = [DConnectLightProfile brightnessFromRequest: request];
                          NSString *name = [request stringForKey:DConnectLightProfileParamName];
                          NSString *color = [request stringForKey:DConnectLightProfileParamColor];
                          NSArray *flashing = [DConnectLightProfile parsePattern: [DConnectLightProfile flashingFromRequest: request] isId:NO];

                          if (flashing && ![weakSelf checkFlash:response flashing:flashing]) {
                              [response setErrorToInvalidRequestParameter];
                              return YES;
                          }
                          
                          if (!serviceId) {
                              [response setErrorToEmptyServiceId];
                              return YES;
                          }
                          
                          DPAllJoynServiceEntity *service = weakHandler.discoveredAllJoynServices[serviceId];
                          
                          if (!service) {
                              [response setErrorToNotFoundService];
                              return YES;
                          }
                          
                          if (!lightId) {
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"Parameter 'lightId' must be specified."];
                              return YES;
                          }
                          
                          if (color
                              && (color.length != 6
                                  || ![[NSScanner scannerWithString:color] scanHexInt:nil]))
                          {
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"Parameter 'color' is invalid."];
                              [[DConnectManager sharedManager] sendResponse:response];
                              return YES;
                          }
                          
                          if (!name || (name && name.length == 0)) {
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"Parameter 'name' is invalid."];
                              return YES;
                          }
                          
                          switch ([weakSelf serviceTypeFromService:service]) {
                                  
                              case DPAllJoynLightServiceTypeSingleLamp: {
                                  [weakSelf
                                   didReceivePutLightRequestForSingleLampWithResponse:response
                                   service:service lightId:lightId name:name brightness:brightness
                                   color:color flashing:flashing];
                                  return NO;
                              }
                                  
                              case DPAllJoynLightServiceTypeLampController: {
                                  [weakSelf
                                   didReceivePutLightRequestForLampControllerWithResponse:response
                                   service:service lightId:lightId name:name brightness:brightness
                                   color:color flashing:flashing];
                                  return NO;
                              }
                                  
                              case DPAllJoynLightServiceTypeUnknown:
                              default: {
                                  [response setErrorToNotSupportAction];
                                  return YES;
                              }
                                  
                          }
                      }];
        
        // API登録(didReceiveDeleteLightRequest相当)
        NSString *deleteLightRequestApiPath = [self apiPath: nil
                                              attributeName: nil];
        [self addDeletePath: deleteLightRequestApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];

                         if (!serviceId) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }
                         
                         DPAllJoynServiceEntity *service = weakHandler.discoveredAllJoynServices[serviceId];
                         
                         if (!service) {
                             [response setErrorToNotFoundService];
                             return YES;
                         }
                         
                         if (!lightId) {
                             [response setErrorToInvalidRequestParameterWithMessage:
                              @"Parameter 'lightId' must be specified."];
                             return YES;
                         }
                         
                         switch ([weakSelf serviceTypeFromService:service]) {
                                 
                             case DPAllJoynLightServiceTypeSingleLamp: {
                                 [weakSelf
                                  didReceiveDeleteLightRequestForSingleLampWithResponse:response
                                  service:service lightId:lightId];
                                 return NO;
                             }
                                 
                             case DPAllJoynLightServiceTypeLampController: {
                                 [weakSelf
                                  didReceiveDeleteLightRequestForLampControllerWithResponse:response
                                  service:service lightId:lightId];
                                 return NO;
                             }
                                 
                             case DPAllJoynLightServiceTypeUnknown:
                             default: {
                                 [response setErrorToNotSupportAction];
                                 return YES;
                             }
                                 
                         }
                     }];
    }
    return self;
}


/*!
 Check if certain API fuctionality in AllJoyn Lighting service framework are available.
 - Dimmable: brightness can be variably changed.
 - Color: color of the light can be variably changed.
 @return A dictionary with availability check results. If availability check failed, nil will be returned.
 */
- (NSDictionary *)checkFunctionalityWithService:(DPAllJoynServiceEntity *)service
                                      sessionID:(AJNSessionId)sessionID
                                        lightID:(NSString *)lightID
                                           type:(DPAllJoynLightServiceType)type
{
    switch (type) {
        case DPAllJoynLightServiceTypeSingleLamp: {
            LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
            [_handler proxyObjectWithService:service
                            proxyObjectClass:LSFLampObjectProxy.class
                                   interface:@"org.allseen.LSF.LampDetails"
                                   sessionID:sessionID];
            if (!proxy) {
                DCLogError(@"Failed to perform AllJoyn API parameter availability check (1).");
                return nil;
            }
            
            return @{@"Dimmable" : @(proxy.Dimmable),
                     @"Color" : @(proxy.Color)};
        }
        case DPAllJoynLightServiceTypeLampController: {
            LSFControllerServiceObjectProxy *proxy =
            (LSFControllerServiceObjectProxy *)
            [_handler proxyObjectWithService:service
                            proxyObjectClass:LSFControllerServiceObjectProxy.class
                                   interface:@"org.allseen.LSF.ControllerService.Lamp"
                                   sessionID:sessionID];
            if (!proxy) {
                DCLogError(@"Failed to perform AllJoyn API parameter availability check (2).");
                return nil;
            }
            
            NSNumber *responseCode;
            NSString *ignored;
            AJNMessageArgument *details;
            [proxy getLampDetailsWithLampID:lightID
                               responseCode:&responseCode
                                     lampID:&ignored
                                lampDetails:&details];
            
            if (!responseCode
                || responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
                return nil;
            }
            
            NSMutableDictionary *functionalities =
            [NSMutableDictionary dictionary];
            if (details) {
                NSDictionary *detailsDict = (NSDictionary *)
                [DPAllJoynMessageConverter objectWithAJNMessageArgument:details];
                if (detailsDict) {
                    for (NSString *key in @[@"Dimmable", @"Color"]) {
                        if (detailsDict[key]) {
                            functionalities[key] = detailsDict[key];
                        }
                    }
                }
            }
            return functionalities;
        }
            
        default:
            return nil;
    }
}


- (DPAllJoynLightServiceType)serviceTypeFromService:
(DPAllJoynServiceEntity *)service
{
    if ([DPAllJoynSupportCheck
         areAJInterfacesSupported:@[@"org.allseen.LSF.ControllerService.Lamp"]
         withService:service]) {
        return DPAllJoynLightServiceTypeLampController;
    } else if ([DPAllJoynSupportCheck
                areAJInterfacesSupported:@[@"org.allseen.LSF.LampState"]
                withService:service]) {
        return DPAllJoynLightServiceTypeSingleLamp;
    }
    
    return DPAllJoynLightServiceTypeUnknown;
}


- (void) didReceiveGetLightRequestForSingleLampWithResponse:(DConnectResponseMessage *)response
                                                    service:(DPAllJoynServiceEntity *)service
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.LampState ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         DConnectArray *lights = [DConnectArray array];
         DConnectMessage *light = [DConnectMessage message];
         [DConnectLightProfile setLightId:DPAllJoynLightProfileLightIDSelf target:light];
         [DConnectLightProfile setLightName:service.serviceName target:light];
         [DConnectLightProfile setLightConfig:@"" target:light];
         [DConnectLightProfile setLightOn:proxy.OnOff target:light];
         [lights addMessage:light];
         
         [DConnectLightProfile setLights:lights target:response];
         [response setResult:DConnectMessageResultTypeOk];
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}

- (void) didReceiveGetLightRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                        service:(DPAllJoynServiceEntity *)service
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         NSNumber *responseCode = nil;
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService.Lamp"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService.Lamp ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         DConnectArray *lights = [DConnectArray array];
         AJNMessageArgument *lampIDs;
         [proxy getAllLampIDsWithResponseCode:&responseCode lampIDs:&lampIDs];
         if (!responseCode || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain lamp IDs (1)."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         NSArray *lampIDArr =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampIDs];
         if (!lampIDArr) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain lamp IDs (2)."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         for (NSString *lampID in lampIDArr) {
             
             //////////////////////////////////////////////////
             // Obtain lamp name.
             //
             NSString *lampName;
             {
                 NSString *lampIDOut;
                 NSString *languageOut;
                 [proxy getLampNameWithLampID:lampID
                                     language:service.defaultLanguage
                                 responseCode:&responseCode
                                       lampID:&lampIDOut
                                     language:&languageOut
                                     lampName:&lampName];
                 if (!responseCode
                     || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
                     DCLogWarn2(@"LightProfile:GET:lightReqForLampController",
                                @"Failed to obtain lamp name. Skipping this lamp...");
                     continue;
                 }
                 responseCode = nil;
             }
             
             //////////////////////////////////////////////////
             // Obtain lamp on/off state.
             //
             BOOL onOffState;
             {
                 NSString *lampIDOut;
                 AJNMessageArgument *onOffStateArg;
                 [proxy getLampStateWithLampID:lampID
                                  responseCode:&responseCode
                                        lampID:&lampIDOut
                                     lampState:&onOffStateArg];
                 if (!responseCode
                     || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
                     DCLogWarn2(@"LightProfile:GET:lightReqForLampController",
                                @"Failed to obtain lamp states."
                                " Skipping this lamp...");
                     continue;
                 }
                 responseCode = nil;
                 
                 NSDictionary *states =
                 [DPAllJoynMessageConverter objectWithAJNMessageArgument:onOffStateArg];
                 if (!states[@"OnOff"]) {
                     DCLogWarn2(@"LightProfile:GET:lightReqForLampController",
                                @"Failed to obtain on/off state."
                                " Skipping this lamp...");
                     continue;
                 }
                 onOffState = [states[@"OnOff"] boolValue];
             }
             
             DConnectMessage *light = [DConnectMessage message];
             [DConnectLightProfile setLightId:lampID target:light];
             [DConnectLightProfile setLightName:lampName target:light];
             [DConnectLightProfile setLightConfig:@"" target:light];
             [DConnectLightProfile setLightOn:onOffState target:light];
             [lights addMessage:light];
         }
         [DConnectLightProfile setLights:lights target:response];
         [response setResult:DConnectMessageResultTypeOk];
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceivePostLightRequestForSingleLampWithResponse:(DConnectResponseMessage *)response
                                                     service:(DPAllJoynServiceEntity *)service
                                                     lightId:(NSString *)lightId
                                                  brightness:(NSNumber *)brightness
                                                       color:(NSString *)color
                                                    flashing:(NSArray *)flashing
{
    //////////////////////////////////////////////////
    // Validity check
    //
    if (![lightId isEqualToString:DPAllJoynLightProfileLightIDSelf]) {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"A light with ID specified by 'lightId' not found."];
        [[DConnectManager sharedManager] sendResponse:response];
        return;
    }
    
    //////////////////////////////////////////////////
    // Querying
    //
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];
         
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.LampState ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         NSDictionary *functionality =
         [self checkFunctionalityWithService:service
                                   sessionID:sessionId.unsignedIntValue
                                     lightID:lightId
                                        type:DPAllJoynLightServiceTypeSingleLamp];
         
         // MsgArg lacks copy operator, so std::vector can not be used for
         // storing new states...
         MsgArg newStates[4];
         size_t count = 0;
         MsgArg tmp1;
         MsgArg tmp2 = MsgArg("b", YES);
         tmp1.Set("{sv}", "OnOff", &tmp2);
         newStates[count] = tmp1;
         ++count;
         
         if (brightness) {
             if (functionality[@"Dimmable"]) {
                 double brightnessScaled = brightness.doubleValue * 0xffffffffL;
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
                 tmp1.Set("{sv}", "Brightness", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:POST:lightReqForSingleLamp",
                            @"Light dimming is not supported in this AllJoyn service. "
                            "Parameter 'brightness' is ignored.");
             }
         }
         
         if (color) {
             if (functionality[@"Color"]) {
                 NSDictionary *hsb = [DPAllJoynColorUtility HSBFromRGB:color];
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"hue"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Hue", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"saturation"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Saturation", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:POST:lightReqForSingleLamp",
                            @"Light coloring is not supported in this AllJoyn service. "
                            "Parameter 'color' is ignored.");
             }
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         NSNumber *responseCode = [proxy transitionLamsStateWithTimestamp:@0
                                                                 newState:newState
                                                         transitionPeriod:@10];

         if (flashing && flashing.count > 0) {
             for (int i = 0; i < flashing.count; i++) {
                 int delay = [flashing[i] intValue];
                 if (i % 2 == 0) {
                     proxy.OnOff = YES;
                     sleep(delay / 1000);
                 } else {
                     proxy.OnOff = NO;
                     sleep(delay / 1000);
                 }
             }
         }
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to change status (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceivePostLightRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                         service:(DPAllJoynServiceEntity *)service
                                                         lightId:(NSString *)lightId
                                                      brightness:(NSNumber *)brightness
                                                           color:(NSString *)color
                                                        flashing:(NSArray *)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         NSNumber *responseCode = nil;
         NSString *ignored;
         
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         AJNMessageArgument *lampIDsArg;
         [proxy getAllLampIDsWithResponseCode:&responseCode lampIDs:&lampIDsArg];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to obtain lamp IDs."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to obtain lamp IDs (code: %@).",
               responseCode]];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         NSArray *lampIDs =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampIDsArg];
         if (!lampIDs || ![lampIDs containsObject:lightId]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"A light with ID specified by 'lightId' not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         NSDictionary *functionality =
         [self checkFunctionalityWithService:service
                                   sessionID:sessionId.unsignedIntValue
                                     lightID:lightId
                                        type:DPAllJoynLightServiceTypeLampController];
         
         // MsgArg lacks copy operator, so std::vector can not be used for
         // storing new states...
         MsgArg newStates[3];
         size_t count = 0;
         MsgArg tmp1;
         MsgArg tmp2 = MsgArg("b", YES);
         tmp1.Set("{sv}", "OnOff", &tmp2);
         newStates[count] = tmp1;
         ++count;
         
         if (brightness) {
             if (functionality[@"Dimmable"]) {
                 double brightnessScaled = brightness.doubleValue * 0xffffffffL;
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
                 tmp1.Set("{sv}", "Brightness", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:POST:lightReqForSingleLamp",
                            @"Light dimming is not supported in this AllJoyn service. "
                            "Parameter 'brightness' is ignored.");
             }
         }
         
         if (color) {
             if (functionality[@"Color"]) {
                 NSDictionary *hsb = [DPAllJoynColorUtility HSBFromRGB:color];
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"hue"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Hue", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"saturation"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Saturation", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:POST:lightReqForSingleLamp",
                            @"Light coloring is not supported in this AllJoyn service. "
                            "Parameter 'color' is ignored.");
             }
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         [proxy transitionLampStateWithLampID:lightId
                                    lampState:newState
                             transitionPeriod:@10
                                 responseCode:&responseCode
                                       lampID:&ignored];
         
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to change status (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


// TODO: Implement name change functionality using AllJoyn Config service.
- (void) didReceivePutLightRequestForSingleLampWithResponse:(DConnectResponseMessage *)response
                                                    service:(DPAllJoynServiceEntity *)service
                                                    lightId:(NSString *)lightId
                                                       name:(NSString *)name
                                                 brightness:(NSNumber *)brightness
                                                      color:(NSString *)color
                                                   flashing:(NSArray *)flashing
{
    //////////////////////////////////////////////////
    // Validity check
    //
    if (![lightId isEqualToString:DPAllJoynLightProfileLightIDSelf]) {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"A light with ID specified by 'lightId' not found."];
        [[DConnectManager sharedManager] sendResponse:response];
        return;
    }
    if (name) {
        DCLogWarn(@"Parameter 'name' is not supported. Ignored...");
    }
    
    //////////////////////////////////////////////////
    // Querying
    //
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.LampState ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         NSDictionary *functionality =
         [self checkFunctionalityWithService:service
                                   sessionID:sessionId.unsignedIntValue
                                     lightID:lightId
                                        type:DPAllJoynLightServiceTypeSingleLamp];
         
         // MsgArg lacks copy operator, so std::vector can not be used for
         // storing new states...
         MsgArg newStates[3];
         size_t count = 0;
         MsgArg tmp1;
         MsgArg tmp2;
         
         if (brightness) {
             if (functionality[@"Dimmable"]) {
                 double brightnessScaled = brightness.doubleValue * 0xffffffffL;
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
                 tmp1.Set("{sv}", "Brightness", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:PUT:lightReqForSingleLamp",
                            @"Light dimming is not supported in this AllJoyn service. "
                            "Parameter 'brightness' is ignored.");
             }
         }
         
         if (color) {
             if (functionality[@"Color"]) {
                 NSDictionary *hsb = [DPAllJoynColorUtility HSBFromRGB:color];
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"hue"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Hue", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"saturation"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Saturation", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:PUT:lightReqForSingleLamp",
                            @"Light coloring is not supported in this AllJoyn service. "
                            "Parameter 'color' is ignored.");
             }
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         NSNumber *responseCode =
         [proxy transitionLamsStateWithTimestamp:@0
                                        newState:newState
                                transitionPeriod:@10];
         if (flashing && flashing.count > 0) {
             for (int i = 0; i < flashing.count; i++) {
                 int delay = [flashing[i] intValue];
                 if (i % 2 == 0) {
                     proxy.OnOff = YES;
                     sleep(delay / 1000);
                 } else {
                     proxy.OnOff = NO;
                     sleep(delay / 1000);
                 }
             }
         }

         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to change status (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceivePutLightRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                        service:(DPAllJoynServiceEntity *)service
                                                        lightId:(NSString *)lightId
                                                           name:(NSString *)name
                                                     brightness:(NSNumber *)brightness
                                                          color:(NSString *)color
                                                       flashing:(NSArray *)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         NSNumber *responseCode = nil;
         NSString *ignored;
         
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         AJNMessageArgument *lampIDsArg;
         [proxy getAllLampIDsWithResponseCode:&responseCode lampIDs:&lampIDsArg];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to obtain lamp IDs."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to obtain lamp IDs (code: %@).",
               responseCode]];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         NSArray *lampIDs =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampIDsArg];
         if (!lampIDs || ![lampIDs containsObject:lightId]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"A light with ID specified by 'lightId' not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         NSDictionary *functionality =
         [self checkFunctionalityWithService:service
                                   sessionID:sessionId.unsignedIntValue
                                     lightID:lightId
                                        type:DPAllJoynLightServiceTypeLampController];
         
         // MsgArg lacks copy operator, so std::vector can not be used for
         // storing new states...
         MsgArg newStates[3];
         size_t count = 0;
         MsgArg tmp1;
         MsgArg tmp2;
         
         if (brightness) {
             if (functionality[@"Dimmable"]) {
                 double brightnessScaled = brightness.doubleValue * 0xffffffffL;
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
                 tmp1.Set("{sv}", "Brightness", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:PUT:lightReqForSingleLamp",
                            @"Light dimming is not supported in this AllJoyn service. "
                            "Parameter 'brightness' is ignored.");
             }
         }
         
         if (color) {
             if (functionality[@"Color"]) {
                 NSDictionary *hsb = [DPAllJoynColorUtility HSBFromRGB:color];
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"hue"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Hue", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
                 
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", [hsb[@"saturation"] unsignedIntValue]);
                 tmp1.Set("{sv}", "Saturation", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
             } else {
                 DCLogWarn2(@"LightProfile:PUT:lightReqForSingleLamp",
                            @"Light coloring is not supported in this AllJoyn service. "
                            "Parameter 'color' is ignored.");
             }
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         [proxy transitionLampStateWithLampID:lightId
                                    lampState:newState
                             transitionPeriod:@10
                                 responseCode:&responseCode
                                       lampID:&ignored];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to change status (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         if (name) {
             NSString *ignored;
             [proxy setLampNameWithLampID:lightId
                                 lampName:name
                                 language:service.defaultLanguage
                             responseCode:&responseCode
                                   lampID:&ignored
                                 language:&ignored];
             if (!responseCode) {
                 [response setErrorToUnknownWithMessage:@"Failed to change name."];
             }
             else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
                 [response setErrorToUnknownWithMessage:
                  [NSString stringWithFormat:@"Failed to change name (code: %@).",
                   responseCode]];
             }
             else {
                 [response setResult:DConnectMessageResultTypeOk];
             }
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceiveDeleteLightRequestForSingleLampWithResponse:(DConnectResponseMessage *)response
                                                       service:(DPAllJoynServiceEntity *)service
                                                       lightId:(NSString *)lightId
{
    //////////////////////////////////////////////////
    // Validity check
    //
    if (![lightId isEqualToString:DPAllJoynLightProfileLightIDSelf]) {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"A light with ID specified by 'lightId' not found."];
        [[DConnectManager sharedManager] sendResponse:response];
        return;
    }
    
    //////////////////////////////////////////////////
    // Querying
    //
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.LampState ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         proxy.OnOff = NO;
         
         [response setResult:DConnectMessageResultTypeOk];
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceiveDeleteLightRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                           service:(DPAllJoynServiceEntity *)service
                                                           lightId:(NSString *)lightId
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         NSNumber *responseCode;
         NSString *ignored;
         
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         AJNMessageArgument *lampIDsArg;
         [proxy getAllLampIDsWithResponseCode:&responseCode lampIDs:&lampIDsArg];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to obtain lamp IDs."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to obtain lamp IDs (code: %@).",
               responseCode]];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         NSArray *lampIDs =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampIDsArg];
         if (!lampIDs || ![lampIDs containsObject:lightId]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"A light with ID specified by 'lightId' not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         MsgArg newStates[1];
         MsgArg tmp1;
         MsgArg tmp2("b", NO);
         tmp1.Set("{sv}", "OnOff", &tmp2);
         newStates[0] = tmp1;
         MsgArg newStateArg("a{sv}", 1, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         
         [proxy transitionLampStateWithLampID:lightId
                                    lampState:newState
                             transitionPeriod:@10
                                 responseCode:&responseCode
                                       lampID:&ignored];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:
               @"Failed to turn off the light with lightID \"%@\".", lightId]];
             
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:
               @"Failed to turn off the light with lightID \"%@\" (code: %@).",
               lightId, responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void)didReceiveGetLightGroupRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                            service:(DPAllJoynServiceEntity *)service
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         NSNumber *responseCode;
         NSArray *lampGroupIDArr;
         {
             AJNMessageArgument *lampGroupIDs;
             [proxy getAllLampGroupIDsWithResponseCode:&responseCode
                                          lampGroupIDs:&lampGroupIDs];
             if (!responseCode
                 || responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
                 [response setErrorToUnknownWithMessage:
                  @"Failed to obtain light group IDs (1)."];
                 [[DConnectManager sharedManager] sendResponse:response];
                 return;
             }
             lampGroupIDArr =
             [DPAllJoynMessageConverter
              objectWithAJNMessageArgument:lampGroupIDs];
         }
         
         //////////////////////////////////////////////////
         // Obtain lamp group info.
         //
         NSMutableDictionary *lampGroups = [NSMutableDictionary dictionary];
         for (size_t i = 0; i < lampGroupIDArr.count; ++i, responseCode = nil) {
             DPAllJoynLampGroup *lampGroup = [DPAllJoynLampGroup new];
             
             lampGroup.groupID = lampGroupIDArr[i];
             
             {
                 NSString *lampGroupName;
                 NSString *ignored;
                 [proxy getLampGroupNameWithLampGroupID:lampGroup.groupID
                                               language:service.defaultLanguage
                                           responseCode:&responseCode
                                          lampIDGroupID:&ignored
                                               language:&ignored
                                          lampGroupName:&lampGroupName];
                 if (!responseCode
                     || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
                     DCLogWarn2(@"LightProfile:GET:lightGroupReqForLampController",
                                @"Failed to obtain lamp group name. "
                                "Skipping this lamp group...");
                     continue;
                 }
                 responseCode = nil;
                 lampGroup.name = lampGroupName;
             }
             
             AJNMessageArgument *lampIDs;
             AJNMessageArgument *lampGroupIDs;
             NSString *ignored;
             [proxy getLampGroupWithLampGroupID:lampGroup.groupID
                                   responseCode:&responseCode
                                    lampGroupID:&ignored
                                         lampID:&lampIDs
                                   lampGroupIDs:&lampGroupIDs];
             
             if (!responseCode
                 || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
                 DCLogWarn2(@"LightProfile:GET:lightGroupReqForLampController",
                            @"Failed to obtain IDs of lamps and lamp groups "
                            "contained in a lamp group. "
                            "Skipping this lamp group...");
                 continue;
             }
             responseCode = nil;
             lampGroup.lampIDs =
             [NSMutableSet setWithArray:
              [DPAllJoynMessageConverter
               objectWithAJNMessageArgument:lampIDs]];
             lampGroup.lampGroupIDs =
             [NSMutableSet setWithArray:
              [DPAllJoynMessageConverter
               objectWithAJNMessageArgument:lampGroupIDs]];
             
             lampGroup.config = @"";
             
             lampGroups[lampGroup.groupID] = lampGroup;
         }
         
         //////////////////////////////////////////////////
         // Expand lamp IDs contained in lamp groups.
         //
         for (DPAllJoynLampGroup *searchTarget in lampGroups.allValues) {
             for (DPAllJoynLampGroup *expandTarget in lampGroups.allValues) {
                 if ([searchTarget.groupID isEqualToString:expandTarget.groupID]) {
                     continue;
                 }
                 if ([expandTarget.lampGroupIDs containsObject:searchTarget.groupID]) {
                     [expandTarget.lampIDs addObjectsFromArray:searchTarget.lampIDs.allObjects];
                     [expandTarget.lampGroupIDs addObjectsFromArray:searchTarget.lampGroupIDs.allObjects];
                     [expandTarget.lampGroupIDs removeObject:searchTarget.groupID];
                 }
             }
         }
         
         //////////////////////////////////////////////////
         // Obtain lamp info.
         //
         NSMutableDictionary *lamps = [NSMutableDictionary dictionary];
         for (DPAllJoynLampGroup *lampGroup in lampGroups.allValues) {
             for (NSString *lampID in lampGroup.lampIDs) {
                 if (lamps[lampID]) {
                     continue;
                 }
                 
                 DPAllJoynLamp *lamp = [DPAllJoynLamp new];
                 NSString *ignored;
                 
                 NSString *name;
                 [proxy getLampNameWithLampID:lampID
                                     language:service.defaultLanguage
                                 responseCode:&responseCode
                                       lampID:&ignored
                                     language:&ignored
                                     lampName:&name];
                 if (!responseCode
                     || responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
                     DCLogWarn2(@"LightProfile:GET:lightGroupReqForLampController",
                                @"Failed to obtain lamp name. Skipping this lamp...");
                 } else {
                     lamp.name = name;
                 }
                 responseCode = nil;
                 
                 AJNMessageArgument *lampState;
                 [proxy getLampStateWithLampID:lampID
                                  responseCode:&responseCode
                                        lampID:&ignored
                                     lampState:&lampState];
                 if (!responseCode
                     || responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
                     DCLogWarn2(@"LightProfile:GET:lightGroupReqForLampController",
                                @"Failed to obtain lamp state. Skipping this lamp...");
                 } else {
                     NSDictionary *states =
                     [DPAllJoynMessageConverter
                      objectWithAJNMessageArgument:lampState];
                     if (!states[@"OnOff"]) {
                         DCLogWarn2(@"LightProfile:GET:lightGroupReqForLampController",
                                    @"Failed to obtain on/off state."
                                    " Skipping this lamp...");
                     } else {
                         lamp.on = states[@"OnOff"];
                     }
                 }
                 responseCode = nil;
                 
                 lamp.config = @"";
                 
                 lamps[lampID] = lamp;
             }
         }
         
         DConnectArray *lightGroups = [DConnectArray array];
         for (DPAllJoynLampGroup *lampGroup in lampGroups.allValues) {
             DConnectMessage *lightGroupMsg = [DConnectMessage message];
             
             [DConnectLightProfile setLightGroupId:lampGroup.groupID target:lightGroupMsg];
             [DConnectLightProfile setLightGroupName:lampGroup.name target:lightGroupMsg];
             DConnectArray *lights = [DConnectArray array];
             for (NSString *lampID in lampGroup.lampIDs) {
                 DPAllJoynLamp *lamp = lamps[lampID];
                 
                 DConnectMessage *light = [DConnectMessage message];
                 
                 [DConnectLightProfile setLightId:lamp.ID target:light];
                 if (lamp.name) {
                     [DConnectLightProfile setLightName:lamp.name target:light];
                 }
                 if (lamp.on) {
                     [DConnectLightProfile setLightOn:lamp.on.boolValue target:light];
                 }
                 [DConnectLightProfile setLightConfig:@"" target:light];
                 [lights addMessage:light];
             }
             [DConnectLightProfile setLights:lights target:lightGroupMsg];
             [DConnectLightProfile setLightConfig:lampGroup.config target:lightGroupMsg];
             [lightGroups addMessage:lightGroupMsg];
         }
         [DConnectLightProfile setLightGroups:lightGroups target:response];
         
         [response setResult:DConnectMessageResultTypeOk];
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void)didReceivePostLightGroupRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                             service:(DPAllJoynServiceEntity *)service
                                                             groupID:(NSString *)groupId
                                                          brightness:(NSNumber *)brightness
                                                               color:(NSString *)color
                                                            flashing:(NSArray *)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         NSNumber *responseCode;
         NSString *ignored;
         
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         AJNMessageArgument *lampGroupIDsArg;
         [proxy getAllLampGroupIDsWithResponseCode:&responseCode
                                      lampGroupIDs:&lampGroupIDsArg];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to obtain lamp group IDs."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to obtain lamp group IDs (code: %@).",
               responseCode]];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         NSArray *lampGroupIDs =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampGroupIDsArg];
         if (!lampGroupIDs || ![lampGroupIDs containsObject:groupId]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"A light group with ID specified by 'groupId' not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         MsgArg newStates[3];
         size_t count = 0;
         MsgArg tmp1;
         MsgArg tmp2 = MsgArg("b", YES);
         tmp1.Set("{sv}", "OnOff", &tmp2);
         newStates[count] = tmp1;
         ++count;
         
         if (brightness) {
             double brightnessScaled = brightness.doubleValue * 0xffffffffL;
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
             tmp1.Set("{sv}", "Brightness", &tmp2);
             newStates[count] = tmp1;
             ++count;
         }
         
         if (color) {
             NSDictionary *hsb = [DPAllJoynColorUtility HSBFromRGB:color];
             
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", [hsb[@"hue"] unsignedIntValue]);
             tmp1.Set("{sv}", "Hue", &tmp2);
             newStates[count] = tmp1;
             ++count;
             
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", [hsb[@"saturation"] unsignedIntValue]);
             tmp1.Set("{sv}", "Saturation", &tmp2);
             newStates[count] = tmp1;
             ++count;
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         [proxy transitionLampGroupStateWithLampGroupID:groupId
                                              lampState:newState
                                       transitionPeriod:@10
                                           responseCode:&responseCode
                                            lampGroupID:&ignored];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to change group state."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to change group state (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void)didReceivePutLightGroupRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                            service:(DPAllJoynServiceEntity *)service
                                                            groupID:(NSString *)groupId
                                                               name:(NSString *)name
                                                         brightness:(NSNumber *)brightness
                                                              color:(NSString *)color
                                                           flashing:(NSArray *)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         NSNumber *responseCode;
         NSString *ignored;
         
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         AJNMessageArgument *lampGroupIDsArg;
         [proxy getAllLampGroupIDsWithResponseCode:&responseCode
                                      lampGroupIDs:&lampGroupIDsArg];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to obtain lamp group IDs."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to obtain lamp group IDs (code: %@).",
               responseCode]];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         NSArray *lampGroupIDs =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampGroupIDsArg];
         if (!lampGroupIDs || ![lampGroupIDs containsObject:groupId]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"A light group with ID specified by 'groupId' not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         MsgArg newStates[2];
         size_t count = 0;
         MsgArg tmp1;
         MsgArg tmp2;
         
         if (brightness) {
             double brightnessScaled = brightness.doubleValue * 0xffffffffL;
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
             tmp1.Set("{sv}", "Brightness", &tmp2);
             newStates[count] = tmp1;
             ++count;
         }
         
         if (color) {
             NSDictionary *hsb = [DPAllJoynColorUtility HSBFromRGB:color];
             
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", [hsb[@"hue"] unsignedIntValue]);
             tmp1.Set("{sv}", "Hue", &tmp2);
             newStates[count] = tmp1;
             ++count;
             
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", [hsb[@"saturation"] unsignedIntValue]);
             tmp1.Set("{sv}", "Saturation", &tmp2);
             newStates[count] = tmp1;
             ++count;
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         [proxy transitionLampGroupStateWithLampGroupID:groupId
                                              lampState:newState
                                       transitionPeriod:@10
                                           responseCode:&responseCode
                                            lampGroupID:&ignored];
         if (!responseCode
             || responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:@"Failed to change group state."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         if (name) {
             [proxy setLampGroupNameWithLampID:groupId
                                      lampName:name
                                      language:service.defaultLanguage
                                  responseCode:&responseCode
                                        lampID:&ignored
                                      language:&ignored];
             if (!responseCode
                 || responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
                 [response setErrorToUnknownWithMessage:@"Failed to change group name."];
                 [[DConnectManager sharedManager] sendResponse:response];
                 return;
             }
         }
         
         [response setResult:DConnectMessageResultTypeOk];
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void)didReceiveDeleteLightGroupRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                               service:(DPAllJoynServiceEntity *)service
                                                               groupID:(NSString *)groupID
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         NSNumber *responseCode;
         NSString *ignored;
         
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         AJNMessageArgument *lampGroupIDsArg;
         [proxy getAllLampGroupIDsWithResponseCode:&responseCode
                                      lampGroupIDs:&lampGroupIDsArg];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to obtain lamp group IDs."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to obtain lamp group IDs (code: %@).",
               responseCode]];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         NSArray *lampGroupIDs =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampGroupIDsArg];
         if (!lampGroupIDs || ![lampGroupIDs containsObject:groupID]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"A light group with ID specified by 'groupId' not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         MsgArg newStates[1];
         size_t count = 0;
         MsgArg tmp1;
         MsgArg tmp2 = MsgArg("b", NO);
         tmp1.Set("{sv}", "OnOff", &tmp2);
         newStates[count] = tmp1;
         ++count;
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         [proxy transitionLampGroupStateWithLampGroupID:groupID
                                              lampState:newState
                                       transitionPeriod:@10
                                           responseCode:&responseCode
                                            lampGroupID:&ignored];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to change group state."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to change group state (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void)didReceivePostLightGroupCreateRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                                   service:(DPAllJoynServiceEntity *)service
                                                                  lightIDs:(NSArray *)lightIDs
                                                                 groupName:(NSString *)groupName
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         NSNumber *responseCode;
         NSString *lampGroupID;
         AJNMessageArgument *lampIDsArg =
         [DPAllJoynMessageConverter AJNMessageArgumentWithObject:lightIDs
                                                       signature:@"as"];
         AJNMessageArgument *lampGroupIDsArg =
         [DPAllJoynMessageConverter AJNMessageArgumentWithObject:@[]
                                                       signature:@"as"];
         [proxy createLampGroupWithLampIDs:lampIDsArg
                              lampGroupIDs:lampGroupIDsArg
                             lampGroupName:groupName
                                  language:service.defaultLanguage
                              responseCode:&responseCode
                               lampGroupID:&lampGroupID];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to create a light group."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to create a light group (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void)didReceiveDeleteLightGroupClearRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                                    service:(DPAllJoynServiceEntity *)service
                                                                    groupID:(NSString *)groupID
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         NSNumber *responseCode;
         NSString *ignored;
         
         if (!sessionId) {
             [response setErrorToUnknownWithMessage:@"Failed to join a session."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];
         if (!proxy) {
             [response setErrorToUnknownWithMessage:
              @"Failed to obtain a proxy object for org.allseen.LSF.ControllerService ."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         AJNMessageArgument *lampGroupIDsArg;
         [proxy getAllLampGroupIDsWithResponseCode:&responseCode
                                      lampGroupIDs:&lampGroupIDsArg];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to obtain lamp group IDs."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to obtain lamp group IDs (code: %@).",
               responseCode]];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         NSArray *lampGroupIDs =
         [DPAllJoynMessageConverter objectWithAJNMessageArgument:lampGroupIDsArg];
         if (!lampGroupIDs || ![lampGroupIDs containsObject:groupID]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"A light group with ID specified by 'groupId' not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;
         
         [proxy deleteLampGroupWithLampGroupID:groupID
                                  responseCode:&responseCode
                                   lampGroupID:&ignored];
         if (!responseCode) {
             [response setErrorToUnknownWithMessage:@"Failed to delete the light group."];
         }
         else if (responseCode.unsignedIntValue != DPAllJoynLightResponseCodeOK) {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:@"Failed to delete the light group (code: %@).",
               responseCode]];
         }
         else {
             [response setResult:DConnectMessageResultTypeOk];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}



@end


@implementation DPAllJoynLampGroup
@end


@implementation DPAllJoynLamp
@end
