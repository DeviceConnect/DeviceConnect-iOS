//
//  AJNLSFControllerService.h
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
//
//  DO NOT EDIT
//
//  Add a category or subclass in separate .h/.m files to extend these classes
//
////////////////////////////////////////////////////////////////////////////////
//
//  AJNLSFControllerService.h
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "AJNBusAttachment.h"
#import "AJNBusInterface.h"
#import "AJNProxyBusObject.h"


////////////////////////////////////////////////////////////////////////////////
//
// LSFControllerServiceDelegate Bus Interface
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFControllerServiceDelegate <AJNBusInterface>


// properties
//
@property (nonatomic, readonly) NSNumber* ControllerServiceVersion;

// methods
//
- (NSNumber*)lightingResetControllerService:(AJNMessage *)methodCallMessage;
- (NSNumber*)getControllerServiceVersion:(AJNMessage *)methodCallMessage;

// signals
//
- (void)sendControllerServiceLightingResetInSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;


@end

////////////////////////////////////////////////////////////////////////////////

    
////////////////////////////////////////////////////////////////////////////////
//
// LSFControllerServiceDelegate Signal Handler Protocol
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFControllerServiceDelegateSignalHandler <AJNSignalHandler>

// signals
//
- (void)didReceiveControllerServiceLightingResetInSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;


@end

@interface AJNBusAttachment(LSFControllerServiceDelegate)

- (void)registerLSFControllerServiceDelegateSignalHandler:(id<LSFControllerServiceDelegateSignalHandler>)signalHandler;

@end

////////////////////////////////////////////////////////////////////////////////
    

////////////////////////////////////////////////////////////////////////////////
//
// LSFControllerServiceLampDelegate Bus Interface
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFControllerServiceLampDelegate <AJNBusInterface>


// properties
//
@property (nonatomic, readonly) NSNumber* LampVersion;

// methods
//
- (void)getAllLampIDsWithResponseCode:(NSNumber**)responseCode lampIDs:(AJNMessageArgument**)lampIDs message:(AJNMessage *)methodCallMessage;
- (void)getLampSupportedLangueagesWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut supportedLanguages:(AJNMessageArgument**)supportedLanguages message:(AJNMessage *)methodCallMessage;
- (void)getLampManufacturerWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut manufacturer:(NSString**)manufacturer message:(AJNMessage *)methodCallMessage;
- (void)getLampNameWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut lampName:(NSString**)lampName message:(AJNMessage *)methodCallMessage;
- (void)setLampNameWithLampID:(NSString*)lampID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage;
- (void)getLampDetailsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampDetails:(AJNMessageArgument**)lampDetails message:(AJNMessage *)methodCallMessage;
- (void)getLampParametersWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampParameters:(AJNMessageArgument**)lampParameters message:(AJNMessage *)methodCallMessage;
- (void)getLampParametersFieldWithLampID:(NSString*)lampID parameterFieldName:(NSString*)lampParameterFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut parameterFieldName:(NSString**)lampParameterFieldName parameterFieldValue:(NSString**)lampParameterFieldValue message:(AJNMessage *)methodCallMessage;
- (void)getLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampState:(AJNMessageArgument**)lampState message:(AJNMessage *)methodCallMessage;
- (void)getLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut stateFieldValue:(NSString**)lampStateFieldValue message:(AJNMessage *)methodCallMessage;
- (void)transitionLampStateWithLampID:(NSString*)lampID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampWithStateWithLampID:(NSString*)lampID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampWithPresetWithLampID:(NSString*)lampID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampStateToPresetWithLampID:(NSString*)lampID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName stateFieldValue:(NSString*)lampStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampStateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage;
- (void)getLampFaultsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFaults:(AJNMessageArgument**)lampFaults message:(AJNMessage *)methodCallMessage;
- (void)clearLampFaultsWithLampID:(NSString*)lampID lampFault:(NSNumber*)lampFault responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFault:(NSNumber**)lampFaultOut message:(AJNMessage *)methodCallMessage;
- (void)getLampServiceVersionWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut version:(NSNumber**)lampServiceVersion message:(AJNMessage *)methodCallMessage;

// signals
//
- (void)sendlampNameDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)sendlampStateDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidFindLamp:(NSString*)LampID inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidLoseLamps:(AJNMessageArgument*)lampIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;


@end

////////////////////////////////////////////////////////////////////////////////

    
////////////////////////////////////////////////////////////////////////////////
//
// LSFControllerServiceLampDelegate Signal Handler Protocol
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFControllerServiceLampDelegateSignalHandler <AJNSignalHandler>

// signals
//
- (void)didReceivelampNameDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;
- (void)didReceivelampStateDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;
- (void)didReceivedidFindLamp:(NSString*)LampID inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;
- (void)didReceivedidLoseLamps:(AJNMessageArgument*)lampIDs inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;


@end

@interface AJNBusAttachment(LSFControllerServiceLampDelegate)

- (void)registerLSFControllerServiceLampDelegateSignalHandler:(id<LSFControllerServiceLampDelegateSignalHandler>)signalHandler;

@end

////////////////////////////////////////////////////////////////////////////////
    

////////////////////////////////////////////////////////////////////////////////
//
// LSFControllerServiceLampGroupDelegate Bus Interface
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFControllerServiceLampGroupDelegate <AJNBusInterface>


// properties
//
@property (nonatomic, readonly) NSNumber* LampGroupVersion;

// methods
//
- (void)getAllLampGroupIDsWithResponseCode:(NSNumber**)responseCode lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage;
- (void)getLampGroupNameWithLampGroupID:(NSString*)lampGroupID language:(NSString*)language responseCode:(NSNumber**)responseCode lampIDGroupID:(NSString**)lampGroupIDOut language:(NSString**)languageOut lampGroupName:(NSString**)lampGroupName message:(AJNMessage *)methodCallMessage;
- (void)setLampGroupNameWithLampID:(NSString*)lampGroupID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampID language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage;
- (void)createLampGroupWithLampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs lampGroupName:(NSString*)lampGroupName language:(NSString*)language responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupID message:(AJNMessage *)methodCallMessage;
- (void)updateLampGroupWithLampGroupID:(NSString*)lampGroupID lampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)deleteLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)getLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut lampID:(AJNMessageArgument**)lampID lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage;
- (void)transitionLampGroupStateWithLampGroupID:(NSString*)lampGroupID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampGroupWithStateWithLampGroupID:(NSString*)lampGroupID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampGroupWithPresetWithLampGroupID:(NSString*)lampGroupID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampGroupStateToPresetWithLampGroupID:(NSString*)lampGroupID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName groupStateFieldValue:(NSString*)lampGroupStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampGroupStateWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage;

// signals
//
- (void)sendlampGroupNamesDidChangeForLampGroupIDs:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidCreateLampGroups:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidUpdateLampGroups:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidDeleteLampGroups:(AJNMessageArgument*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;


@end

////////////////////////////////////////////////////////////////////////////////

    
////////////////////////////////////////////////////////////////////////////////
//
// LSFControllerServiceLampGroupDelegate Signal Handler Protocol
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFControllerServiceLampGroupDelegateSignalHandler <AJNSignalHandler>

// signals
//
- (void)didReceivelampGroupNamesDidChangeForLampGroupIDs:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;
- (void)didReceivedidCreateLampGroups:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;
- (void)didReceivedidUpdateLampGroups:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;
- (void)didReceivedidDeleteLampGroups:(AJNMessageArgument*)lampGroupsIDs inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;


@end

@interface AJNBusAttachment(LSFControllerServiceLampGroupDelegate)

- (void)registerLSFControllerServiceLampGroupDelegateSignalHandler:(id<LSFControllerServiceLampGroupDelegateSignalHandler>)signalHandler;

@end

////////////////////////////////////////////////////////////////////////////////
    

////////////////////////////////////////////////////////////////////////////////
//
//  AJNLSFControllerServiceObject Bus Object superclass
//
////////////////////////////////////////////////////////////////////////////////

@interface AJNLSFControllerServiceObject : AJNBusObject<LSFControllerServiceDelegate, LSFControllerServiceLampDelegate, LSFControllerServiceLampGroupDelegate>

// properties
//
@property (nonatomic, readonly) NSNumber* ControllerServiceVersion;
@property (nonatomic, readonly) NSNumber* LampVersion;
@property (nonatomic, readonly) NSNumber* LampGroupVersion;


// methods
//
- (NSNumber*)lightingResetControllerService:(AJNMessage *)methodCallMessage;
- (NSNumber*)getControllerServiceVersion:(AJNMessage *)methodCallMessage;
- (void)getAllLampIDsWithResponseCode:(NSNumber**)responseCode lampIDs:(AJNMessageArgument**)lampIDs message:(AJNMessage *)methodCallMessage;
- (void)getLampSupportedLangueagesWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut supportedLanguages:(AJNMessageArgument**)supportedLanguages message:(AJNMessage *)methodCallMessage;
- (void)getLampManufacturerWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut manufacturer:(NSString**)manufacturer message:(AJNMessage *)methodCallMessage;
- (void)getLampNameWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut lampName:(NSString**)lampName message:(AJNMessage *)methodCallMessage;
- (void)setLampNameWithLampID:(NSString*)lampID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage;
- (void)getLampDetailsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampDetails:(AJNMessageArgument**)lampDetails message:(AJNMessage *)methodCallMessage;
- (void)getLampParametersWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampParameters:(AJNMessageArgument**)lampParameters message:(AJNMessage *)methodCallMessage;
- (void)getLampParametersFieldWithLampID:(NSString*)lampID parameterFieldName:(NSString*)lampParameterFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut parameterFieldName:(NSString**)lampParameterFieldName parameterFieldValue:(NSString**)lampParameterFieldValue message:(AJNMessage *)methodCallMessage;
- (void)getLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampState:(AJNMessageArgument**)lampState message:(AJNMessage *)methodCallMessage;
- (void)getLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut stateFieldValue:(NSString**)lampStateFieldValue message:(AJNMessage *)methodCallMessage;
- (void)transitionLampStateWithLampID:(NSString*)lampID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampWithStateWithLampID:(NSString*)lampID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampWithPresetWithLampID:(NSString*)lampID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampStateToPresetWithLampID:(NSString*)lampID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName stateFieldValue:(NSString*)lampStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampStateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage;
- (void)getLampFaultsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFaults:(AJNMessageArgument**)lampFaults message:(AJNMessage *)methodCallMessage;
- (void)clearLampFaultsWithLampID:(NSString*)lampID lampFault:(NSNumber*)lampFault responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFault:(NSNumber**)lampFaultOut message:(AJNMessage *)methodCallMessage;
- (void)getLampServiceVersionWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut version:(NSNumber**)lampServiceVersion message:(AJNMessage *)methodCallMessage;
- (void)getAllLampGroupIDsWithResponseCode:(NSNumber**)responseCode lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage;
- (void)getLampGroupNameWithLampGroupID:(NSString*)lampGroupID language:(NSString*)language responseCode:(NSNumber**)responseCode lampIDGroupID:(NSString**)lampGroupIDOut language:(NSString**)language lampGroupName:(NSString**)lampGroupName message:(AJNMessage *)methodCallMessage;
- (void)setLampGroupNameWithLampID:(NSString*)lampGroupID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampID language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage;
- (void)createLampGroupWithLampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs lampGroupName:(NSString*)lampGroupName language:(NSString*)language responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupID message:(AJNMessage *)methodCallMessage;
- (void)updateLampGroupWithLampGroupID:(NSString*)lampGroupID lampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)deleteLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)getLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut lampID:(AJNMessageArgument**)lampID lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage;
- (void)transitionLampGroupStateWithLampGroupID:(NSString*)lampGroupID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampGroupWithStateWithLampGroupID:(NSString*)lampGroupID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)pulseLampGroupWithPresetWithLampGroupID:(NSString*)lampGroupID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampGroupStateToPresetWithLampGroupID:(NSString*)lampGroupID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)transitionLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName groupStateFieldValue:(NSString*)lampGroupStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampGroupStateWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage;
- (void)resetLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage;


// signals
//
- (void)sendControllerServiceLightingResetInSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)sendlampNameDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)sendlampStateDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidFindLamp:(NSString*)LampID inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidLoseLamps:(AJNMessageArgument*)lampIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)sendlampGroupNamesDidChangeForLampGroupIDs:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidCreateLampGroups:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidUpdateLampGroups:(NSString*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;
- (void)senddidDeleteLampGroups:(AJNMessageArgument*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;


@end

////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
//  LSFControllerServiceObject Proxy
//
////////////////////////////////////////////////////////////////////////////////

@interface LSFControllerServiceObjectProxy : AJNProxyBusObject

// properties
//
@property (nonatomic, readonly) NSNumber* ControllerServiceVersion;
@property (nonatomic, readonly) NSNumber* LampVersion;
@property (nonatomic, readonly) NSNumber* LampGroupVersion;


// methods
//
- (NSNumber*)lightingResetControllerService;
- (NSNumber*)getControllerServiceVersion;
- (void)getAllLampIDsWithResponseCode:(NSNumber**)responseCode lampIDs:(AJNMessageArgument**)lampIDs;
- (void)getLampSupportedLangueagesWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut supportedLanguages:(AJNMessageArgument**)supportedLanguages;
- (void)getLampManufacturerWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut manufacturer:(NSString**)manufacturer;
- (void)getLampNameWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut lampName:(NSString**)lampName;
- (void)setLampNameWithLampID:(NSString*)lampID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut;
- (void)getLampDetailsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampDetails:(AJNMessageArgument**)lampDetails;
- (void)getLampParametersWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampParameters:(AJNMessageArgument**)lampParameters;
- (void)getLampParametersFieldWithLampID:(NSString*)lampID parameterFieldName:(NSString*)lampParameterFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut parameterFieldName:(NSString**)lampParameterFieldName parameterFieldValue:(NSString**)lampParameterFieldValue;
- (void)getLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampState:(AJNMessageArgument**)lampState;
- (void)getLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut stateFieldValue:(NSString**)lampStateFieldValue;
- (void)transitionLampStateWithLampID:(NSString*)lampID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut;
- (void)pulseLampWithStateWithLampID:(NSString*)lampID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut;
- (void)pulseLampWithPresetWithLampID:(NSString*)lampID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut;
- (void)transitionLampStateToPresetWithLampID:(NSString*)lampID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut;
- (void)transitionLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName stateFieldValue:(NSString*)lampStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampStateFieldName:(NSString**)lampStateFieldNameOut;
- (void)resetLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut;
- (void)resetLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut;
- (void)getLampFaultsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFaults:(AJNMessageArgument**)lampFaults;
- (void)clearLampFaultsWithLampID:(NSString*)lampID lampFault:(NSNumber*)lampFault responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFault:(NSNumber**)lampFaultOut;
- (void)getLampServiceVersionWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut version:(NSNumber**)lampServiceVersion;
- (void)getAllLampGroupIDsWithResponseCode:(NSNumber**)responseCode lampGroupIDs:(AJNMessageArgument**)lampGroupIDs;
- (void)getLampGroupNameWithLampGroupID:(NSString*)lampGroupID language:(NSString*)language responseCode:(NSNumber**)responseCode lampIDGroupID:(NSString**)lampGroupIDOut language:(NSString**)languageOut lampGroupName:(NSString**)lampGroupName;
- (void)setLampGroupNameWithLampID:(NSString*)lampGroupID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampID language:(NSString**)languageOut;
- (void)createLampGroupWithLampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs lampGroupName:(NSString*)lampGroupName language:(NSString*)language responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupID;
- (void)updateLampGroupWithLampGroupID:(NSString*)lampGroupID lampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut;
- (void)deleteLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut;
- (void)getLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut lampID:(AJNMessageArgument**)lampID lampGroupIDs:(AJNMessageArgument**)lampGroupIDs;
- (void)transitionLampGroupStateWithLampGroupID:(NSString*)lampGroupID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut;
- (void)pulseLampGroupWithStateWithLampGroupID:(NSString*)lampGroupID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut;
- (void)pulseLampGroupWithPresetWithLampGroupID:(NSString*)lampGroupID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut;
- (void)transitionLampGroupStateToPresetWithLampGroupID:(NSString*)lampGroupID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut;
- (void)transitionLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName groupStateFieldValue:(NSString*)lampGroupStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut;
- (void)resetLampGroupStateWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut;
- (void)resetLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut;


@end

////////////////////////////////////////////////////////////////////////////////
