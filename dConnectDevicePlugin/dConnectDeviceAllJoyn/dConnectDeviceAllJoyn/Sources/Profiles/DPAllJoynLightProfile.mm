//
//  DPAllJoynLightProfile.m
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


@interface DPAllJoynLightProfile () <DCMLightProfileDelegate> {
    DPAllJoynHandler *_handler;
}
@end


@interface DPAllJoynLampGroup : NSObject

@property NSString *groupID;
@property NSString *name;
@property NSMutableSet *lampIDs;
@property NSMutableSet *lampGroupIDs;
@property NSString *config;

@end


@interface DPAllJoynLamp : NSObject

@property NSString *ID;
@property NSString *name;
@property NSNumber *on;
@property NSString *config;

@end


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
        self.delegate = self;
        _handler = handler;
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
            QStatus status;
            LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
            [_handler proxyObjectWithService:service
                            proxyObjectClass:LSFLampObjectProxy.class
                                   interface:@"org.allseen.LSF.LampDetails"
                                   sessionID:sessionID];;
            status = [proxy introspectRemoteObject];
            if (ER_OK != status) {
                NSLog(@"Failed to perform AllJoyn API parameter availability check.");
                return nil;
            }
            
            return @{@"Dimmable" : @(proxy.Dimmable),
                     @"Color" : @(proxy.Color)};
        }
        case DPAllJoynLightServiceTypeLampController: {
            QStatus status;
            LSFControllerServiceObjectProxy *proxy =
            (LSFControllerServiceObjectProxy *)
            [_handler proxyObjectWithService:service
                            proxyObjectClass:LSFControllerServiceObjectProxy.class
                                   interface:@"org.allseen.LSF.ControllerService.Lamp"
                                   sessionID:sessionID];;
            status = [proxy introspectRemoteObject];
            if (ER_OK != status) {
                NSLog(@"Failed to perform AllJoyn API parameter availability check.");
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
                size_t size;
                MsgArg *detailArr;
                status = [details value:@"a{sv}", &size, &detailArr];
                if (ER_OK != status) {
                    NSLog(@"Failed to obtain light details.");
                    return nil;
                }
                for (size_t i = 0; i < size; ++i) {
                    char *keyCStr;
                    NSString *key;
                    MsgArg valArg;
                    status = detailArr[i].Get("{sv}", &keyCStr, &valArg);
                    if (ER_OK != status) {
                        NSLog(@"Failed to obtain a key-value pair.");
                        continue;
                    }
                    key = @(keyCStr);
                    if ([key isEqualToString:@"Dimmable"] ||
                        [key isEqualToString:@"Color"]) {
                        functionalities[key] = @(valArg.v_bool);
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
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];;
         QStatus status = [proxy introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         DConnectArray *lights = [DConnectArray array];
         DConnectMessage *light = [DConnectMessage message];
         [light setString:@"self" forKey:DCMLightProfileParamLightId];
         [light setString:service.serviceName forKey:DCMLightProfileParamName];
         [light setString:@"" forKey:DCMLightProfileParamConfig];
         [light setBool:proxy.OnOff forKey:DCMLightProfileParamOn];
         [lights addMessage:light];
         
         [response setArray:lights forKey:DCMLightProfileParamLights];
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
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         NSNumber *responseCode = nil;
         QStatus status;
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService.Lamp"
                                sessionID:sessionId.unsignedIntValue];;
         status = [proxy introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         DConnectArray *lights = [DConnectArray array];
         AJNMessageArgument *lampIDs;
         [proxy getAllLampIDsWithResponseCode:&responseCode lampIDs:&lampIDs];
         if (!responseCode || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
             NSString *msg = @"Failed to obtain lamp IDs.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         responseCode = nil;

         size_t size1;
         MsgArg *entries1;
         status = [lampIDs value:@"as", &size1, &entries1];
         if (ER_OK != status) {
             NSString *msg = @"Failed to parse lamp IDs.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         for (size_t i = 0; i < size1; ++i) {
             
             //////////////////////////////////////////////////
             // Obtain lamp ID.
             //
             char *lampIDCStr;
             status = entries1[i].Get("s", &lampIDCStr);
             if (ER_OK != status) {
                 NSLog(@"Failed to parse a lamp ID. Skipping this lamp...");
                 continue;
             }
             NSString *lampID = @(lampIDCStr);

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
                     NSLog(@"Failed to obtain lamp name. Skipping this lamp...");
                     continue;
                 }
                 responseCode = nil;
             }
             
             //////////////////////////////////////////////////
             // Obtain lamp on/off state.
             //
             NSNumber *onOffState;
             {
                 NSString *lampIDOut;
                 AJNMessageArgument *onOffStateArg;
                 [proxy getLampStateWithLampID:lampID
                                  responseCode:&responseCode
                                        lampID:&lampIDOut
                                     lampState:&onOffStateArg];
                 if (!responseCode
                     || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
                     NSLog(@"Failed to obtain lamp states (1)."
                           " Skipping this lamp...");
                     continue;
                 }
                 responseCode = nil;
                 size_t size2;
                 MsgArg *entries2;
                 status = [onOffStateArg value:@"a{sv}", &size2, &entries2];
                 if (ER_OK != status) {
                     NSLog(@"Failed to obtain lamp states (2)."
                           " Skipping this lamp...");
                     continue;
                 }
                 BOOL shouldContinue = NO;
                 for (size_t j = 0; j < size2; ++j) {
                     char *keyCStr;
                     MsgArg *valArg;
                     status = entries2[j].Get("{sv}", &keyCStr, &valArg);
                     if (ER_OK != status) {
                         NSLog(@"Failed to obtain a lamp state."
                               " Skipping this lamp...");
                         shouldContinue = YES;
                         break;
                     }
                     NSString *key = @(keyCStr);
                     if ([key isEqualToString:@"OnOff"]) {
                         BOOL onOffStateBool;
                         status = valArg->Get("b", &onOffStateBool);
                         if (ER_OK != status) {
                             NSLog(@"Failed to obtain on/off state (1)."
                                   " Skipping this lamp...");
                             shouldContinue = YES;
                             break;
                         }
                         onOffState = @(onOffStateBool);
                     }
                 }
                 if (shouldContinue) {
                     continue;
                 }
                 if (!onOffState) {
                     NSLog(@"Failed to obtain on/off state (2)."
                           " Skipping this lamp...");
                     continue;
                 }
             }
             
             DConnectMessage *light = [DConnectMessage message];
             [light setString:lampID forKey:DCMLightProfileParamLightId];
             [light setString:lampName forKey:DCMLightProfileParamName];
             [light setString:@"" forKey:DCMLightProfileParamConfig];
             [light setBool:onOffState.boolValue forKey:DCMLightProfileParamOn];
             [lights addMessage:light];
         }
         
         [response setArray:lights forKey:DCMLightProfileParamLights];
         [response setResult:DConnectMessageResultTypeOk];
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceivePostLightRequestForSingleLampWithResponse:(DConnectResponseMessage *)response
                                                     service:(DPAllJoynServiceEntity *)service
                                                     lightId:(NSString*)lightId
                                                  brightness:(double)brightness
                                                       color:(NSString*)color
                                                    flashing:(NSArray*)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         //////////////////////////////////////////////////
         // Validity check
         //
         if (!sessionId) {
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (![lightId isEqualToString:@"self"]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"lightId not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (brightness < 0 || brightness > 1) {
             NSString *msg = @"Parameter 'brightness' must be within range [0, 1].";
             NSLog(@"%@", msg);
             [response setErrorToInvalidRequestParameterWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (color
             && ((color.length != 6 && color.length != 8)
                 || ![[NSScanner scannerWithString:color] scanHexInt:nil]))
         {
             NSString *msg = @"Parameter 'color' must be a string representing "
             "an RGB hexadecimal (e.g. 0xFF0000, ff0000).";
             NSLog(@"%@", msg);
             [response setErrorToInvalidRequestParameterWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (flashing) {
             NSLog(@"Parameter 'flashing' is not supported. Ignored...");
             //             [response setErrorToNotSupportActionWithMessage:@"Parameter 'flashing' is not supported."];
             //             [[DConnectManager sharedManager] sendResponse:response];
             //             return;
         }
         
         //////////////////////////////////////////////////
         // Querying
         //
         QStatus status;
         LSFLampObjectProxy *proxyState = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];;
         status = [proxyState introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
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

         if (functionality[@"Dimmable"]) {
             double brightnessScaled = brightness * 0xffffffffL;
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
             tmp1.Set("{sv}", "Brightness", &tmp2);
             newStates[count] = tmp1;
             ++count;
         } else {
             NSLog(@"Light dimming is not supported in this AllJoyn service. "
                   "Parameter 'brightness' is ignored.");
         }
         
         if (functionality[@"Color"]) {
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
         } else {
             NSLog(@"Light coloring is not supported in this AllJoyn service. "
                   "Parameter 'color' is ignored.");
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         NSNumber *responseCode =
         [proxyState transitionLamsStateWithTimestamp:@0
                                             newState:newState
                                     transitionPeriod:@10];
         if (responseCode
             && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
             [response setResult:DConnectMessageResultTypeOk];
         } else {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceivePostLightRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                         service:(DPAllJoynServiceEntity *)service
                                                         lightId:(NSString*)lightId
                                                      brightness:(double)brightness
                                                           color:(NSString*)color
                                                        flashing:(NSArray*)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         //////////////////////////////////////////////////
         // Validity check
         //
         if (!sessionId) {
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (!lightId) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"lightId must be specified."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         //////////////////////////////////////////////////
         // Querying
         //
         QStatus status;
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];;
         status = [proxy introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
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
         
         if (functionality[@"Dimmable"]) {
             double brightnessScaled = brightness * 0xffffffffL;
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
             tmp1.Set("{sv}", "Brightness", &tmp2);
             newStates[count] = tmp1;
             ++count;
         } else {
             NSLog(@"Light dimming is not supported in this AllJoyn service. "
                   "Parameter 'brightness' is ignored.");
         }
         
         if (functionality[@"Color"]) {
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
         } else {
             NSLog(@"Light coloring is not supported in this AllJoyn service. "
                   "Parameter 'color' is ignored.");
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         NSNumber *responseCode;
         NSString *ignored;
         [proxy transitionLampStateWithLampID:lightId
                                    lampState:newState
                             transitionPeriod:@10
                                 responseCode:&responseCode
                                       lampID:&ignored];
         if (responseCode
             && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
             [response setResult:DConnectMessageResultTypeOk];
         } else {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceivePutLightRequestForSingleLampWithResponse:(DConnectResponseMessage *)response
                                                    service:(DPAllJoynServiceEntity *)service
                                                    lightId:(NSString*)lightId
                                                       name:(NSString*)name
                                                 brightness:(double)brightness
                                                      color:(NSString*)color
                                                   flashing:(NSArray*)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         //////////////////////////////////////////////////
         // Validity check
         //
         if (!sessionId) {
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (![lightId isEqualToString:@"self"]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"lightId not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (brightness < 0 || brightness > 1) {
             NSString *msg = @"Parameter 'brightness' must be within range [0, 1].";
             NSLog(@"%@", msg);
             [response setErrorToInvalidRequestParameterWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (color
             && ((color.length != 6 && color.length != 8)
                 || ![[NSScanner scannerWithString:color] scanHexInt:nil]))
         {
             NSString *msg = @"Parameter 'color' must be a string representing "
             "an RGB hexadecimal (e.g. 0xFF0000, ff0000).";
             NSLog(@"%@", msg);
             [response setErrorToInvalidRequestParameterWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (flashing) {
             NSLog(@"Parameter 'flashing' is not supported. Ignored...");
             //             [response setErrorToNotSupportActionWithMessage:@"Parameter 'flashing' is not supported."];
             //             [[DConnectManager sharedManager] sendResponse:response];
             //             return;
         }
     
         //////////////////////////////////////////////////
         // Querying
         //
         QStatus status;
         LSFLampObjectProxy *proxyState = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];;
         status = [proxyState introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
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
         
         if (functionality[@"Dimmable"]) {
             double brightnessScaled = brightness * 0xffffffffL;
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
             tmp1.Set("{sv}", "Brightness", &tmp2);
             newStates[count] = tmp1;
             ++count;
         } else {
             NSLog(@"Light dimming is not supported in this AllJoyn service. "
                   "Parameter 'brightness' is ignored.");
         }
         
         if (functionality[@"Color"]) {
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
         } else {
             NSLog(@"Light coloring is not supported in this AllJoyn service. "
                   "Parameter 'color' is ignored.");
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         NSNumber *responseCode =
         [proxyState transitionLamsStateWithTimestamp:@0
                                             newState:newState
                                     transitionPeriod:@10];
         if (responseCode
             && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
             [response setResult:DConnectMessageResultTypeOk];
         } else {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceivePutLightRequestForLampControllerWithResponse:(DConnectResponseMessage *)response
                                                        service:(DPAllJoynServiceEntity *)service
                                                        lightId:(NSString*)lightId
                                                           name:(NSString*)name
                                                     brightness:(double)brightness
                                                          color:(NSString*)color
                                                       flashing:(NSArray*)flashing
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         //////////////////////////////////////////////////
         // Validity check
         //
         if (!sessionId) {
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (!lightId) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"lightId must be specified."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         //////////////////////////////////////////////////
         // Querying
         //
         QStatus status;
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];;
         status = [proxy introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
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
         
         if (functionality[@"Dimmable"]) {
             double brightnessScaled = brightness * 0xffffffffL;
             tmp1 = MsgArg();
             tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
             tmp1.Set("{sv}", "Brightness", &tmp2);
             newStates[count] = tmp1;
             ++count;
         } else {
             NSLog(@"Light dimming is not supported in this AllJoyn service. "
                   "Parameter 'brightness' is ignored.");
         }
         
         if (functionality[@"Color"]) {
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
         } else {
             NSLog(@"Light coloring is not supported in this AllJoyn service. "
                   "Parameter 'color' is ignored.");
         }
         
         MsgArg newStateArg("a{sv}", count, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         NSNumber *responseCode;
         NSString *ignored;
         [proxy transitionLampStateWithLampID:lightId
                                    lampState:newState
                             transitionPeriod:@10
                                 responseCode:&responseCode
                                       lampID:&ignored];
         if (responseCode
             && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
             [response setResult:DConnectMessageResultTypeOk];
         } else {
             [response setErrorToUnknownWithMessage:@"Failed to change status."];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


- (void) didReceiveDeleteLightRequestForSingleLampWithResponse:(DConnectResponseMessage *)response
                                                       service:(DPAllJoynServiceEntity *)service
                                                       lightId:(NSString*)lightId
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         //////////////////////////////////////////////////
         // Validity check
         //
         if (!sessionId) {
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (![lightId isEqualToString:@"self"]) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"lightId not found."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         //////////////////////////////////////////////////
         // Querying
         //
         QStatus status;
         LSFLampObjectProxy *proxy = (LSFLampObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFLampObjectProxy.class
                                interface:@"org.allseen.LSF.LampState"
                                sessionID:sessionId.unsignedIntValue];;
         status = [proxy introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
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
                                                           lightId:(NSString*)lightId
{
    [_handler performOneShotSessionWithBusName:service
                                         block:
     ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
     {
         //////////////////////////////////////////////////
         // Validity check
         //
         if (!sessionId) {
             NSString *msg = @"Failed to join a session.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         if (!lightId) {
             [response setErrorToInvalidRequestParameterWithMessage:
              @"lightId must be specified."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         //////////////////////////////////////////////////
         // Querying
         //
         QStatus status;
         LSFControllerServiceObjectProxy *proxy =
         (LSFControllerServiceObjectProxy *)
         [_handler proxyObjectWithService:service
                         proxyObjectClass:LSFControllerServiceObjectProxy.class
                                interface:@"org.allseen.LSF.ControllerService"
                                sessionID:sessionId.unsignedIntValue];;
         status = [proxy introspectRemoteObject];
         if (ER_OK != status) {
             NSString *msg = @"Failed to introspect a remote bus object.";
             NSLog(@"%@", msg);
             [response setErrorToUnknownWithMessage:msg];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         MsgArg newStates[1];
         MsgArg tmp1;
         MsgArg tmp2("b", NO);
         tmp1.Set("{sv}", "OnOff", &tmp2);
         newStates[0] = tmp1;
         MsgArg newStateArg("a{sv}", 1, newStates);
         AJNMessageArgument *newState =
         [[AJNMessageArgument alloc] initWithHandle:&newStateArg];
         
         NSNumber *responseCode;
         NSString *ignored;
         [proxy transitionLampStateWithLampID:lightId
                                    lampState:newState
                             transitionPeriod:@10
                                 responseCode:&responseCode
                                       lampID:&ignored];
         
         if (responseCode
             && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
             [response setResult:DConnectMessageResultTypeOk];
         } else {
             [response setErrorToUnknownWithMessage:
              [NSString stringWithFormat:
               @"Failed to turn off the light with lightID \"%@\".", lightId]];
         }
         
         [[DConnectManager sharedManager] sendResponse:response];
     }];
}


// =============================================================================
#pragma mark - DCMLightProfileDelegate


- (BOOL)              profile:(DCMLightProfile *)profile
    didReceiveGetLightRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
        
        case DPAllJoynLightServiceTypeSingleLamp: {
            [self
             didReceiveGetLightRequestForSingleLampWithResponse:response
             service:service];
            return NO;
        }
        
        case DPAllJoynLightServiceTypeLampController: {
            [self
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
}


- (BOOL)            profile:(DCMLightProfile *)profile
 didReceivePostLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    lightId:(NSString*)lightId
                 brightness:(double)brightness
                      color:(NSString*)color
                   flashing:(NSArray*)flashing
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeSingleLamp: {
            [self
             didReceivePostLightRequestForSingleLampWithResponse:response
             service:service lightId:lightId brightness:brightness
             color:color flashing:flashing];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeLampController: {
            [self
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
}


- (BOOL)            profile:(DCMLightProfile *)profile
  didReceivePutLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    lightId:(NSString*)lightId
                       name:(NSString*)name
                 brightness:(double)brightness
                      color:(NSString*)color
                   flashing:(NSArray*)flashing
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeSingleLamp: {
            [self
             didReceivePutLightRequestForSingleLampWithResponse:response
             service:service lightId:lightId name:name brightness:brightness
             color:color flashing:flashing];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeLampController: {
            [self
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
}


- (BOOL)                 profile:(DCMLightProfile *)profile
    didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                         lightId:(NSString*)lightId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeSingleLamp: {
            [self
             didReceiveDeleteLightRequestForSingleLampWithResponse:response
             service:service lightId:lightId];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeLampController: {
            [self
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
}


#pragma mark Group


- (BOOL)                profile:(DCMLightProfile *)profile
 didReceiveGetLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeLampController: {
            [_handler performOneShotSessionWithBusName:service
                                                 block:
             ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
             {
                 if (!sessionId) {
                     NSString *msg = @"Failed to join a session.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 QStatus status;
                 LSFControllerServiceObjectProxy *proxy =
                 (LSFControllerServiceObjectProxy *)
                 [_handler proxyObjectWithService:service
                                 proxyObjectClass:LSFControllerServiceObjectProxy.class
                                        interface:@"org.allseen.LSF.ControllerService"
                                        sessionID:sessionId.unsignedIntValue];
                 status = [proxy introspectRemoteObject];
                 if (ER_OK != status) {
                     NSString *msg = @"Failed to introspect a remote bus object.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 NSNumber *responseCode;
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
                 NSArray *lampGroupIDArr =
                 [DPAllJoynMessageConverter
                  objectWithAJNMessageArgument:lampGroupIDs];
                 
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
                             NSLog(@"Failed to obtain lamp group name. Skipping this lamp group...");
                             continue;
                         }
                         responseCode = nil;
                         lampGroup.name = lampGroupName;
                     }
                     
                     AJNMessageArgument *lampIDs;
                     NSString *ignored;
                     [proxy getLampGroupWithLampGroupID:lampGroup.groupID
                                           responseCode:&responseCode
                                            lampGroupID:&ignored
                                                 lampID:&lampIDs
                                           lampGroupIDs:&lampGroupIDs];
                     
                     if (!responseCode
                         || responseCode.intValue != DPAllJoynLightResponseCodeOK) {
                         NSLog(@"Failed to obtain IDs of lamps and lamp groups contained in a lamp group. Skipping this lamp group...");
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
                 {
                     for (DPAllJoynLampGroup *searchTarget in lampGroups.allValues) {
                         for (DPAllJoynLampGroup *expandTarget in lampGroups.allValues) {
                             if ([searchTarget.groupID isEqualToString:expandTarget.groupID]) {
                                 continue;
                             }
                             if ([expandTarget.lampGroupIDs containsObject:searchTarget.groupID]) {
                                 [expandTarget.lampIDs addObjectsFromArray:searchTarget.lampIDs.allObjects];
                                 [expandTarget.lampGroupIDs removeObject:searchTarget.groupID];
                                 [expandTarget.lampGroupIDs addObjectsFromArray:searchTarget.lampGroupIDs.allObjects];
                             }
                         }
                     }
                 }
                 
                 //////////////////////////////////////////////////
                 // Obtain lamp info.
                 //
                 NSMutableDictionary *lamps = [NSMutableDictionary dictionary];
                 {
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
                                 NSLog(@"%@", @"Failed to obtain lamp name. Skipping this lamp...");
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
                                 NSLog(@"%@", @"Failed to obtain lamp state. Skipping this lamp...");
                             } else {
                                 NSDictionary *states =
                                 [DPAllJoynMessageConverter
                                  objectWithAJNMessageArgument:lampState];
                                 if (!states[@"OnOff"]) {
                                     NSLog(@"Failed to obtain on/off state."
                                           " Skipping this lamp...");
                                 } else {
                                     lamp.on = states[@"OnOff"];
                                 }
                             }
                             responseCode = nil;

                             lamps[lampID] = lamp;
                         }
                     }
                 }

                 DConnectArray *lightGroups = [DConnectArray array];
                 for (DPAllJoynLampGroup *lampGroup in lampGroups.allValues) {
                     DConnectMessage *lightGroupMsg = [DConnectMessage message];
                     [lightGroupMsg setString:lampGroup.groupID forKey:DCMLightProfileParamGroupId];
                     [lightGroupMsg setString:lampGroup.name forKey:DCMLightProfileParamName];
                     DConnectArray *lights = [DConnectArray array];
                     for (NSString *lampID in lampGroup.lampIDs) {
                         DPAllJoynLamp *lamp = lamps[lampID];

                         DConnectMessage *light = [DConnectMessage message];
                         [light setString:lamp.ID forKey:DCMLightProfileParamLightId];
                         if (lamp.name) {
                             [light setString:lamp.name forKey:DCMLightProfileParamName];
                         }
                         if (lamp.on) {
                             [light setBool:lamp.on.boolValue forKey:DCMLightProfileParamOn];
                         }
                         [lightGroupMsg setString:@"" forKey:DCMLightProfileParamConfig];
                         [lights addMessage:light];
                     }
                     [lightGroupMsg setArray:lights forKey:DCMLightProfileParamLights];
                     [lightGroupMsg setString:@"" forKey:DCMLightProfileParamConfig];
                     [lightGroups addMessage:lightGroupMsg];
                 }
                 [response setArray:lightGroups forKey:DCMLightProfileParamLightGroups];
                 
                 [response setResult:DConnectMessageResultTypeOk];
                 [[DConnectManager sharedManager] sendResponse:response];
             }];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeSingleLamp:
        case DPAllJoynLightServiceTypeUnknown:
        default: {
            [response setErrorToNotSupportAction];
            return YES;
        }
            
    }
}


- (BOOL)                profile:(DCMLightProfile *)profile
didReceivePostLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                        groupId:(NSString*)groupId
                     brightness:(double)brightness
                          color:(NSString*)color
                       flashing:(NSArray*)flashing
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeLampController: {
            //////////////////////////////////////////////////
            // Validity check
            //
            if (!groupId) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'groupId' must be specified."];
                [[DConnectManager sharedManager] sendResponse:response];
                return YES;
            }
            
            //////////////////////////////////////////////////
            // Querying
            //
            [_handler performOneShotSessionWithBusName:service
                                                 block:
             ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
             {
                 if (!sessionId) {
                     NSString *msg = @"Failed to join a session.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 QStatus status;
                 LSFControllerServiceObjectProxy *proxy =
                 (LSFControllerServiceObjectProxy *)
                 [_handler proxyObjectWithService:service
                                 proxyObjectClass:LSFControllerServiceObjectProxy.class
                                        interface:@"org.allseen.LSF.ControllerService"
                                        sessionID:sessionId.unsignedIntValue];
                 status = [proxy introspectRemoteObject];
                 if (ER_OK != status) {
                     NSString *msg = @"Failed to introspect a remote bus object.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 MsgArg newStates[3];
                 size_t count = 0;
                 MsgArg tmp1;
                 MsgArg tmp2 = MsgArg("b", YES);
                 tmp1.Set("{sv}", "OnOff", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
                 
                 double brightnessScaled = brightness * 0xffffffffL;
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
                 tmp1.Set("{sv}", "Brightness", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
                 
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
                 NSNumber *responseCode;
                 NSString *ignored;
                 [proxy transitionLampGroupStateWithLampGroupID:groupId
                                                      lampState:newState
                                               transitionPeriod:@10
                                                   responseCode:&responseCode
                                                    lampGroupID:&ignored];
                 if (responseCode
                     && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
                     [response setResult:DConnectMessageResultTypeOk];
                 } else {
                     [response setErrorToUnknownWithMessage:@"Failed to change group state."];
                 }
                 
                 [[DConnectManager sharedManager] sendResponse:response];
             }];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeSingleLamp:
        case DPAllJoynLightServiceTypeUnknown:
        default: {
            [response setErrorToNotSupportAction];
            return YES;
        }
            
    }
}


- (BOOL)                profile:(DCMLightProfile *)profile
 didReceivePutLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
                        groupId:(NSString*)groupId
                           name:(NSString*)name
                     brightness:(double)brightness
                          color:(NSString*)color
                       flashing:(NSArray*)flashing
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeLampController: {
            //////////////////////////////////////////////////
            // Validity check
            //
            if (!groupId) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'groupId' must be specified."];
                [[DConnectManager sharedManager] sendResponse:response];
                return YES;
            }
            
            //////////////////////////////////////////////////
            // Querying
            //
            [_handler performOneShotSessionWithBusName:service
                                                 block:
             ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
             {
                 if (!sessionId) {
                     NSString *msg = @"Failed to join a session.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 QStatus status;
                 LSFControllerServiceObjectProxy *proxy =
                 (LSFControllerServiceObjectProxy *)
                 [_handler proxyObjectWithService:service
                                 proxyObjectClass:LSFControllerServiceObjectProxy.class
                                        interface:@"org.allseen.LSF.ControllerService"
                                        sessionID:sessionId.unsignedIntValue];
                 status = [proxy introspectRemoteObject];
                 if (ER_OK != status) {
                     NSString *msg = @"Failed to introspect a remote bus object.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 MsgArg newStates[2];
                 size_t count = 0;
                 MsgArg tmp1;
                 MsgArg tmp2;
                 
                 double brightnessScaled = brightness * 0xffffffffL;
                 tmp1 = MsgArg();
                 tmp2 = MsgArg("u", (uint32_t)brightnessScaled);
                 tmp1.Set("{sv}", "Brightness", &tmp2);
                 newStates[count] = tmp1;
                 ++count;
                 
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
                 NSNumber *responseCode;
                 NSString *ignored;
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
                 
                 [response setResult:DConnectMessageResultTypeOk];
                 [[DConnectManager sharedManager] sendResponse:response];
             }];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeSingleLamp:
        case DPAllJoynLightServiceTypeUnknown:
        default: {
            [response setErrorToNotSupportAction];
            return YES;
        }
            
    }
}


- (BOOL)                    profile:(DCMLightProfile *)profile
  didReceiveDeleteLightGroupRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
                            groupId:(NSString*)groupId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeLampController: {
            //////////////////////////////////////////////////
            // Validity check
            //
            if (!groupId) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'groupId' must be specified."];
                [[DConnectManager sharedManager] sendResponse:response];
                return YES;
            }
            
            //////////////////////////////////////////////////
            // Querying
            //
            [_handler performOneShotSessionWithBusName:service
                                                 block:
             ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
             {
                 if (!sessionId) {
                     NSString *msg = @"Failed to join a session.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 QStatus status;
                 LSFControllerServiceObjectProxy *proxy =
                 (LSFControllerServiceObjectProxy *)
                 [_handler proxyObjectWithService:service
                                 proxyObjectClass:LSFControllerServiceObjectProxy.class
                                        interface:@"org.allseen.LSF.ControllerService"
                                        sessionID:sessionId.unsignedIntValue];
                 status = [proxy introspectRemoteObject];
                 if (ER_OK != status) {
                     NSString *msg = @"Failed to introspect a remote bus object.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
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
                 NSNumber *responseCode;
                 NSString *ignored;
                 [proxy transitionLampGroupStateWithLampGroupID:groupId
                                                      lampState:newState
                                               transitionPeriod:@10
                                                   responseCode:&responseCode
                                                    lampGroupID:&ignored];
                 if (responseCode
                     && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
                     [response setResult:DConnectMessageResultTypeOk];
                 } else {
                     [response setErrorToUnknownWithMessage:@"Failed to change group state."];
                 }
                 
                 [[DConnectManager sharedManager] sendResponse:response];
             }];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeSingleLamp:
        case DPAllJoynLightServiceTypeUnknown:
        default: {
            [response setErrorToNotSupportAction];
            return YES;
        }
            
    }
}


- (BOOL)                        profile:(DCMLightProfile *)profile
  didReceivePostLightGroupCreateRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                               lightIds:(NSArray*)lightIds
                              groupName:(NSString*)groupName
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeLampController: {
            //////////////////////////////////////////////////
            // Validity check
            //
            if (!lightIds) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'groupId' must be specified."];
                [[DConnectManager sharedManager] sendResponse:response];
                return YES;
            }
            if (!groupName) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'groupName' must be specified."];
                [[DConnectManager sharedManager] sendResponse:response];
                return YES;
            }
            
            //////////////////////////////////////////////////
            // Querying
            //
            [_handler performOneShotSessionWithBusName:service
                                                 block:
             ^(DPAllJoynServiceEntity *service, NSNumber *sessionId)
             {
                 if (!sessionId) {
                     NSString *msg = @"Failed to join a session.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 QStatus status;
                 LSFControllerServiceObjectProxy *proxy =
                 (LSFControllerServiceObjectProxy *)
                 [_handler proxyObjectWithService:service
                                 proxyObjectClass:LSFControllerServiceObjectProxy.class
                                        interface:@"org.allseen.LSF.ControllerService"
                                        sessionID:sessionId.unsignedIntValue];
                 status = [proxy introspectRemoteObject];
                 if (ER_OK != status) {
                     NSString *msg = @"Failed to introspect a remote bus object.";
                     NSLog(@"%@", msg);
                     [response setErrorToUnknownWithMessage:msg];
                     [[DConnectManager sharedManager] sendResponse:response];
                     return;
                 }
                 
                 NSNumber *responseCode;
                 NSString *lampGroupID;
                 AJNMessageArgument *lampIDsArg =
                 [DPAllJoynMessageConverter AJNMessageArgumentWithObject:lightIds
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
                 if (responseCode
                     && responseCode.unsignedIntValue == DPAllJoynLightResponseCodeOK) {
                     [response setResult:DConnectMessageResultTypeOk];
                 } else {
                     [response setErrorToUnknownWithMessage:@"Failed to create a light group."];
                 }
                                  
                 [[DConnectManager sharedManager] sendResponse:response];
             }];
            return NO;
        }
            
        case DPAllJoynLightServiceTypeSingleLamp:
        case DPAllJoynLightServiceTypeUnknown:
        default: {
            [response setErrorToNotSupportAction];
            return YES;
        }
            
    }
}


- (BOOL)                        profile:(DCMLightProfile *)profile
 didReceiveDeleteLightGroupClearRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                groupId:(NSString*)groupId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    DPAllJoynServiceEntity *service =
    _handler.discoveredAllJoynServices[serviceId];
    
    if (!service) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    switch ([self serviceTypeFromService:service]) {
            
        case DPAllJoynLightServiceTypeLampController: {
        }
            
        case DPAllJoynLightServiceTypeSingleLamp:
        case DPAllJoynLightServiceTypeUnknown:
        default: {
            [response setErrorToNotSupportAction];
            return YES;
        }
            
    }
}

@end


@implementation DPAllJoynLampGroup
@end


@implementation DPAllJoynLamp
@end
