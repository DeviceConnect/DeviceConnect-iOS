//
//  LSFControllerService.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
//
//  Generated code had many problems (property and message parameter name
//  conflicts), so this version fixed those problems.
//

////////////////////////////////////////////////////////////////////////////////
//
//  ALLJOYN MODELING TOOL - GENERATED CODE
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  LSFControllerService.m
//
////////////////////////////////////////////////////////////////////////////////

#import "LSFControllerService.h"

////////////////////////////////////////////////////////////////////////////////
//
//  Objective-C Bus Object implementation for LSFControllerServiceObject
//
////////////////////////////////////////////////////////////////////////////////

@implementation LSFControllerServiceObject

- (NSNumber*)lightingResetControllerService:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (NSNumber*)getControllerServiceVersion:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getAllLampIDsWithResponseCode:(NSNumber**)responseCode lampIDs:(AJNMessageArgument**)lampIDs message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampSupportedLangueagesWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut supportedLanguages:(AJNMessageArgument**)supportedLanguages message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampManufacturerWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut manufacturer:(NSString**)manufacturer message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampNameWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut lampName:(NSString**)lampName message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)setLampNameWithLampID:(NSString*)lampID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampDetailsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampDetails:(AJNMessageArgument**)lampDetails message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampParametersWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampParameters:(AJNMessageArgument**)lampParameters message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampParametersFieldWithLampID:(NSString*)lampID parameterFieldName:(NSString*)lampParameterFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut parameterFieldName:(NSString**)lampParameterFieldNameOut parameterFieldValue:(NSString**)lampParameterFieldValue message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampState:(AJNMessageArgument**)lampState message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut stateFieldValue:(NSString**)lampStateFieldValue message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)transitionLampStateWithLampID:(NSString*)lampID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)pulseLampWithStateWithLampID:(NSString*)lampID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)pulseLampWithPresetWithLampID:(NSString*)lampID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)transitionLampStateToPresetWithLampID:(NSString*)lampID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)transitionLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName stateFieldValue:(NSString*)lampStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampStateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)resetLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)resetLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampFaultsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFaults:(AJNMessageArgument**)lampFaults message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)clearLampFaultsWithLampID:(NSString*)lampID lampFault:(NSNumber*)lampFault responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFault:(NSNumber**)lampFaultOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampServiceVersionWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut version:(NSNumber**)lampServiceVersion message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getAllLampGroupIDsWithResponseCode:(NSNumber**)responseCode lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampGroupNameWithLampGroupID:(NSString*)lampGroupID language:(NSString*)language responseCode:(NSNumber**)responseCode lampIDGroupID:(NSString**)lampGroupIDOut language:(NSString**)languageOut lampGroupName:(NSString**)lampGroupName message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)setLampGroupNameWithLampID:(NSString*)lampGroupID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampID language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)createLampGroupWithLampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs lampGroupName:(NSString*)lampGroupName language:(NSString*)language responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupID message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)updateLampGroupWithLampGroupID:(NSString*)lampGroupID lampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)deleteLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)getLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut lampID:(AJNMessageArgument**)lampID lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)transitionLampGroupStateWithLampGroupID:(NSString*)lampGroupID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)pulseLampGroupWithStateWithLampGroupID:(NSString*)lampGroupID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)pulseLampGroupWithPresetWithLampGroupID:(NSString*)lampGroupID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)transitionLampGroupStateToPresetWithLampGroupID:(NSString*)lampGroupID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)transitionLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName groupStateFieldValue:(NSString*)lampGroupStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)resetLampGroupStateWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}

- (void)resetLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    // TODO: complete the implementation of this method
    //
     @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must implement this method" userInfo:nil]);   
}


@end

////////////////////////////////////////////////////////////////////////////////
