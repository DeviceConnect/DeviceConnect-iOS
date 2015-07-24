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
#import "AJNLSFControllerService.h"
#import "AJNLSFLamp.h"
#import "DPAllJoynLightingResponseCode.h"
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
            return NO;
        }
            
        case DPAllJoynLightServiceTypeLampController: {
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
            return NO;
        }
            
        case DPAllJoynLightServiceTypeLampController: {
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
            return NO;
        }
            
        case DPAllJoynLightServiceTypeLampController: {
            return NO;
        }
            
        case DPAllJoynLightServiceTypeUnknown:
        default: {
            [response setErrorToNotSupportAction];
            return YES;
        }
            
    }
}


- (BOOL)                profile:(DCMLightProfile *)profile
 didReceiveGetLightGroupRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    [response setErrorToNotSupportAction];
    return YES;
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
    [response setErrorToNotSupportAction];
    return YES;

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
    [response setErrorToNotSupportAction];
    return YES;
}


- (BOOL)                    profile:(DCMLightProfile *)profile
  didReceiveDeleteLightGroupRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
                            groupId:(NSString*)groupId
{
    [response setErrorToNotSupportAction];
    return YES;
}


- (BOOL)                        profile:(DCMLightProfile *)profile
  didReceivePostLightGroupCreateRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                               lightIds:(NSArray*)lightIds
                              groupName:(NSString*)groupName
{
    [response setErrorToNotSupportAction];
    return YES;
}


- (BOOL)                        profile:(DCMLightProfile *)profile
 didReceiveDeleteLightGroupClearRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                groupId:(NSString*)groupId
{
    [response setErrorToNotSupportAction];
    return YES;
}

@end
