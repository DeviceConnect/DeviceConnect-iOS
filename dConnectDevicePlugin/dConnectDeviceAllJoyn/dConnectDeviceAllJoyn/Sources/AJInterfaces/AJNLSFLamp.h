//
//  AJNLSFLamp.h
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
//  AJNLSFLamp.h
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "AJNBusAttachment.h"
#import "AJNBusInterface.h"
#import "AJNProxyBusObject.h"


////////////////////////////////////////////////////////////////////////////////
//
// LSFLampServiceDelegate Bus Interface
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFLampServiceDelegate <AJNBusInterface>


// properties
//
@property (nonatomic, readonly) NSNumber* LampServiceInterfaceVersion;
@property (nonatomic, readonly) NSNumber* LampServiceVersion;
@property (nonatomic, readonly) AJNMessageArgument* LampFaults;

// methods
//
- (void)clearLampFaultWithFaultCode:(NSNumber*)LampFaultCode responseCode:(NSNumber**)LampResponseCode faultCode:(NSNumber**)LampFaultCodeOut message:(AJNMessage *)methodCallMessage;


@end

////////////////////////////////////////////////////////////////////////////////

    

////////////////////////////////////////////////////////////////////////////////
//
// LSFLampParametersDelegate Bus Interface
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFLampParametersDelegate <AJNBusInterface>


// properties
//
@property (nonatomic, readonly) NSNumber* LampParametersVersion;
@property (nonatomic, readonly) NSNumber* Energy_Usage_Milliwatts;
@property (nonatomic, readonly) NSNumber* Brightness_Lumens;


@end

////////////////////////////////////////////////////////////////////////////////

    

////////////////////////////////////////////////////////////////////////////////
//
// LSFLampDetailsDelegate Bus Interface
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFLampDetailsDelegate <AJNBusInterface>


// properties
//
@property (nonatomic, readonly) NSNumber* LampDetailsVersion;
@property (nonatomic, readonly) NSNumber* Make;
@property (nonatomic, readonly) NSNumber* Model;
@property (nonatomic, readonly) NSNumber* Type;
@property (nonatomic, readonly) NSNumber* LampType;
@property (nonatomic, readonly) NSNumber* LampBaseType;
@property (nonatomic, readonly) NSNumber* LampBeamAngle;
@property (nonatomic, readonly) BOOL Dimmable;
@property (nonatomic, readonly) BOOL Color;
@property (nonatomic, readonly) BOOL VariableColorTemp;
@property (nonatomic, readonly) BOOL HasEffects;
@property (nonatomic, readonly) NSNumber* MinVoltage;
@property (nonatomic, readonly) NSNumber* MaxVoltage;
@property (nonatomic, readonly) NSNumber* Wattage;
@property (nonatomic, readonly) NSNumber* IncandescentEquivalent;
@property (nonatomic, readonly) NSNumber* MaxLumens;
@property (nonatomic, readonly) NSNumber* MinTemperature;
@property (nonatomic, readonly) NSNumber* MaxTemperature;
@property (nonatomic, readonly) NSNumber* ColorRenderingIndex;
@property (nonatomic, readonly) NSString* LampID;


@end

////////////////////////////////////////////////////////////////////////////////

    

////////////////////////////////////////////////////////////////////////////////
//
// LSFLampStateDelegate Bus Interface
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFLampStateDelegate <AJNBusInterface>


// properties
//
@property (nonatomic, readonly) NSNumber* LampStateVersion;
@property (nonatomic,) BOOL OnOff;
@property (nonatomic, strong) NSNumber* Hue;
@property (nonatomic, strong) NSNumber* Saturation;
@property (nonatomic, strong) NSNumber* ColorTemp;
@property (nonatomic, strong) NSNumber* Brightness;

// methods
//
- (NSNumber*)transitionLamsStateWithTimestamp:(NSNumber*)Timestamp newState:(AJNMessageArgument*)NewState transitionPeriod:(NSNumber*)TransitionPeriod message:(AJNMessage *)methodCallMessage;
- (NSNumber*)applyPulseEffectWithFromState:(AJNMessageArgument*)FromState toState:(AJNMessageArgument*)ToState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses timestamp:(NSNumber*)timestamp message:(AJNMessage *)methodCallMessage;

// signals
//
- (void)sendlampStateDidChangedForLampID:(NSString*)LampID inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;


@end

////////////////////////////////////////////////////////////////////////////////

    
////////////////////////////////////////////////////////////////////////////////
//
// LSFLampStateDelegate Signal Handler Protocol
//
////////////////////////////////////////////////////////////////////////////////

@protocol LSFLampStateDelegateSignalHandler <AJNSignalHandler>

// signals
//
- (void)didReceivelampStateDidChangedForLampID:(NSString*)LampID inSession:(AJNSessionId)sessionId message:(AJNMessage *)signalMessage;


@end

@interface AJNBusAttachment(LSFLampStateDelegate)

- (void)registerLSFLampStateDelegateSignalHandler:(id<LSFLampStateDelegateSignalHandler>)signalHandler;

@end

////////////////////////////////////////////////////////////////////////////////
    

////////////////////////////////////////////////////////////////////////////////
//
//  AJNLSFLampObject Bus Object superclass
//
////////////////////////////////////////////////////////////////////////////////

@interface AJNLSFLampObject : AJNBusObject<LSFLampServiceDelegate, LSFLampParametersDelegate, LSFLampDetailsDelegate, LSFLampStateDelegate>

// properties
//
@property (nonatomic, readonly) NSNumber* LampServiceInterfaceVersion;
@property (nonatomic, readonly) NSNumber* LampServiceVersion;
@property (nonatomic, readonly) AJNMessageArgument* LampFaults;
@property (nonatomic, readonly) NSNumber* LampParametersVersion;
@property (nonatomic, readonly) NSNumber* Energy_Usage_Milliwatts;
@property (nonatomic, readonly) NSNumber* Brightness_Lumens;
@property (nonatomic, readonly) NSNumber* LampDetailsVersion;
@property (nonatomic, readonly) NSNumber* Make;
@property (nonatomic, readonly) NSNumber* Model;
@property (nonatomic, readonly) NSNumber* Type;
@property (nonatomic, readonly) NSNumber* LampType;
@property (nonatomic, readonly) NSNumber* LampBaseType;
@property (nonatomic, readonly) NSNumber* LampBeamAngle;
@property (nonatomic, readonly) BOOL Dimmable;
@property (nonatomic, readonly) BOOL Color;
@property (nonatomic, readonly) BOOL VariableColorTemp;
@property (nonatomic, readonly) BOOL HasEffects;
@property (nonatomic, readonly) NSNumber* MinVoltage;
@property (nonatomic, readonly) NSNumber* MaxVoltage;
@property (nonatomic, readonly) NSNumber* Wattage;
@property (nonatomic, readonly) NSNumber* IncandescentEquivalent;
@property (nonatomic, readonly) NSNumber* MaxLumens;
@property (nonatomic, readonly) NSNumber* MinTemperature;
@property (nonatomic, readonly) NSNumber* MaxTemperature;
@property (nonatomic, readonly) NSNumber* ColorRenderingIndex;
@property (nonatomic, readonly) NSString* LampID;
@property (nonatomic, readonly) NSNumber* LampStateVersion;
@property (nonatomic,) BOOL OnOff;
@property (nonatomic, strong) NSNumber* Hue;
@property (nonatomic, strong) NSNumber* Saturation;
@property (nonatomic, strong) NSNumber* ColorTemp;
@property (nonatomic, strong) NSNumber* Brightness;


// methods
//
- (void)clearLampFaultWithFaultCode:(NSNumber*)LampFaultCode responseCode:(NSNumber**)LampResponseCode faultCode:(NSNumber**)LampFaultCodeOut message:(AJNMessage *)methodCallMessage;
- (NSNumber*)transitionLamsStateWithTimestamp:(NSNumber*)Timestamp newState:(AJNMessageArgument*)NewState transitionPeriod:(NSNumber*)TransitionPeriod message:(AJNMessage *)methodCallMessage;
- (NSNumber*)applyPulseEffectWithFromState:(AJNMessageArgument*)FromState toState:(AJNMessageArgument*)ToState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses timestamp:(NSNumber*)timestamp message:(AJNMessage *)methodCallMessage;


// signals
//
- (void)sendlampStateDidChangedForLampID:(NSString*)LampID inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath;


@end

////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
//  LSFLampObject Proxy
//
////////////////////////////////////////////////////////////////////////////////

@interface LSFLampObjectProxy : AJNProxyBusObject

// properties
//
@property (nonatomic, readonly) NSNumber* LampServiceInterfaceVersion;
@property (nonatomic, readonly) NSNumber* LampServiceVersion;
@property (nonatomic, readonly) AJNMessageArgument* LampFaults;
@property (nonatomic, readonly) NSNumber* LampParametersVersion;
@property (nonatomic, readonly) NSNumber* Energy_Usage_Milliwatts;
@property (nonatomic, readonly) NSNumber* Brightness_Lumens;
@property (nonatomic, readonly) NSNumber* LampDetailsVersion;
@property (nonatomic, readonly) NSNumber* Make;
@property (nonatomic, readonly) NSNumber* Model;
@property (nonatomic, readonly) NSNumber* Type;
@property (nonatomic, readonly) NSNumber* LampType;
@property (nonatomic, readonly) NSNumber* LampBaseType;
@property (nonatomic, readonly) NSNumber* LampBeamAngle;
@property (nonatomic, readonly) BOOL Dimmable;
@property (nonatomic, readonly) BOOL Color;
@property (nonatomic, readonly) BOOL VariableColorTemp;
@property (nonatomic, readonly) BOOL HasEffects;
@property (nonatomic, readonly) NSNumber* MinVoltage;
@property (nonatomic, readonly) NSNumber* MaxVoltage;
@property (nonatomic, readonly) NSNumber* Wattage;
@property (nonatomic, readonly) NSNumber* IncandescentEquivalent;
@property (nonatomic, readonly) NSNumber* MaxLumens;
@property (nonatomic, readonly) NSNumber* MinTemperature;
@property (nonatomic, readonly) NSNumber* MaxTemperature;
@property (nonatomic, readonly) NSNumber* ColorRenderingIndex;
@property (nonatomic, readonly) NSString* LampID;
@property (nonatomic, readonly) NSNumber* LampStateVersion;
@property (nonatomic,) BOOL OnOff;
@property (nonatomic, strong) NSNumber* Hue;
@property (nonatomic, strong) NSNumber* Saturation;
@property (nonatomic, strong) NSNumber* ColorTemp;
@property (nonatomic, strong) NSNumber* Brightness;


// methods
//
- (void)clearLampFaultWithFaultCode:(NSNumber*)LampFaultCode responseCode:(NSNumber**)LampResponseCode faultCode:(NSNumber**)LampFaultCodeOut;
- (NSNumber*)transitionLamsStateWithTimestamp:(NSNumber*)Timestamp newState:(AJNMessageArgument*)NewState transitionPeriod:(NSNumber*)TransitionPeriod;
- (NSNumber*)applyPulseEffectWithFromState:(AJNMessageArgument*)FromState toState:(AJNMessageArgument*)ToState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses timestamp:(NSNumber*)timestamp;


@end

////////////////////////////////////////////////////////////////////////////////
