//
//  AJNLSFLamp.mm
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
//  AJNLSFLamp.mm
//
////////////////////////////////////////////////////////////////////////////////

#import <alljoyn/BusAttachment.h>
#import <alljoyn/BusObject.h>
#import "AJNBusObjectImpl.h"
#import "AJNInterfaceDescription.h"
#import "AJNMessageArgument.h"
#import "AJNSignalHandlerImpl.h"

#import "LSFLamp.h"

using namespace ajn;


@interface AJNMessageArgument(Private)

/**
 * Helper to return the C++ API object that is encapsulated by this objective-c class
 */
@property (nonatomic, readonly) MsgArg *msgArg;

@end


////////////////////////////////////////////////////////////////////////////////
//
//  C++ Bus Object class declaration for LSFLampObjectImpl
//
////////////////////////////////////////////////////////////////////////////////
class LSFLampObjectImpl : public AJNBusObjectImpl
{
private:
    const InterfaceDescription::Member* LampStateChangedSignalMember;

    
public:
    LSFLampObjectImpl(BusAttachment &bus, const char *path, id<LSFLampServiceDelegate, LSFLampParametersDelegate, LSFLampDetailsDelegate, LSFLampStateDelegate> aDelegate);

    
    // properties
    //
    virtual QStatus Get(const char* ifcName, const char* propName, MsgArg& val);
    virtual QStatus Set(const char* ifcName, const char* propName, MsgArg& val);        
    
    
    // methods
    //
    void ClearLampFault(const InterfaceDescription::Member* member, Message& msg);
	void TransitionLampState(const InterfaceDescription::Member* member, Message& msg);
	void ApplyPulseEffect(const InterfaceDescription::Member* member, Message& msg);

    
    // signals
    //
    QStatus SendLampStateChanged(const char * LampID, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);

};
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  C++ Bus Object implementation for LSFLampObjectImpl
//
////////////////////////////////////////////////////////////////////////////////

LSFLampObjectImpl::LSFLampObjectImpl(BusAttachment &bus, const char *path, id<LSFLampServiceDelegate, LSFLampParametersDelegate, LSFLampDetailsDelegate, LSFLampStateDelegate> aDelegate) : 
    AJNBusObjectImpl(bus,path,aDelegate)
{
    const InterfaceDescription* interfaceDescription = NULL;
    QStatus status;
    status = ER_OK;
    
    
    // Add the org.allseen.LSF.LampService interface to this object
    //
    interfaceDescription = bus.GetInterface("org.allseen.LSF.LampService");
    assert(interfaceDescription);
    AddInterface(*interfaceDescription);

    
    // Register the method handlers for interface LSFLampServiceDelegate with the object
    //
    const MethodEntry methodEntriesForLSFLampServiceDelegate[] = {

        {
			interfaceDescription->GetMember("ClearLampFault"), static_cast<MessageReceiver::MethodHandler>(&LSFLampObjectImpl::ClearLampFault)
		}
    
    };
    
    status = AddMethodHandlers(methodEntriesForLSFLampServiceDelegate, sizeof(methodEntriesForLSFLampServiceDelegate) / sizeof(methodEntriesForLSFLampServiceDelegate[0]));
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred while adding method handlers for interface org.allseen.LSF.LampService to the interface description. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    // Add the org.allseen.LSF.LampParameters interface to this object
    //
    interfaceDescription = bus.GetInterface("org.allseen.LSF.LampParameters");
    assert(interfaceDescription);
    AddInterface(*interfaceDescription);

    
    // Add the org.allseen.LSF.LampDetails interface to this object
    //
    interfaceDescription = bus.GetInterface("org.allseen.LSF.LampDetails");
    assert(interfaceDescription);
    AddInterface(*interfaceDescription);

    
    // Add the org.allseen.LSF.LampState interface to this object
    //
    interfaceDescription = bus.GetInterface("org.allseen.LSF.LampState");
    assert(interfaceDescription);
    AddInterface(*interfaceDescription);

    
    // Register the method handlers for interface LSFLampStateDelegate with the object
    //
    const MethodEntry methodEntriesForLSFLampStateDelegate[] = {

        {
			interfaceDescription->GetMember("TransitionLampState"), static_cast<MessageReceiver::MethodHandler>(&LSFLampObjectImpl::TransitionLampState)
		},

		{
			interfaceDescription->GetMember("ApplyPulseEffect"), static_cast<MessageReceiver::MethodHandler>(&LSFLampObjectImpl::ApplyPulseEffect)
		}
    
    };
    
    status = AddMethodHandlers(methodEntriesForLSFLampStateDelegate, sizeof(methodEntriesForLSFLampStateDelegate) / sizeof(methodEntriesForLSFLampStateDelegate[0]));
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred while adding method handlers for interface org.allseen.LSF.LampState to the interface description. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    // save off signal members for later
    //
    LampStateChangedSignalMember = interfaceDescription->GetMember("LampStateChanged");
    assert(LampStateChangedSignalMember);    


}


QStatus LSFLampObjectImpl::Get(const char* ifcName, const char* propName, MsgArg& val)
{
    QStatus status = ER_BUS_NO_SUCH_PROPERTY;
    
    @autoreleasepool {
    
    if (strcmp(ifcName, "org.allseen.LSF.LampService") == 0) 
    {
    
        if (strcmp(propName, "Version") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampServiceDelegate>)delegate).LampServiceInterfaceVersion unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "LampServiceVersion") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampServiceDelegate>)delegate).LampServiceVersion unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "LampFaults") == 0)
        {
        
            MsgArg *pPropertyValue = (MsgArg*)[((id<LSFLampServiceDelegate>)delegate).LampFaults msgArg];
            val = *pPropertyValue;
            status = ER_OK;
            
        }
    
    }
    else if (strcmp(ifcName, "org.allseen.LSF.LampParameters") == 0) 
    {
    
        if (strcmp(propName, "Version") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampParametersDelegate>)delegate).LampParametersVersion unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Energy_Usage_Milliwatts") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampParametersDelegate>)delegate).Energy_Usage_Milliwatts unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Brightness_Lumens") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampParametersDelegate>)delegate).Brightness_Lumens unsignedIntValue] );
            
        }
    
    }
    else if (strcmp(ifcName, "org.allseen.LSF.LampDetails") == 0) 
    {
    
        if (strcmp(propName, "Version") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).LampDetailsVersion unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Make") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).Make unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Model") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).Model unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Type") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).Type unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "LampType") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).LampType unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "LampBaseType") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).LampBaseType unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "LampBeamAngle") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).LampBeamAngle unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Dimmable") == 0)
        {
                
            status = val.Set( "b", ((id<LSFLampDetailsDelegate>)delegate).Dimmable  );
            
        }
    
        if (strcmp(propName, "Color") == 0)
        {
                
            status = val.Set( "b", ((id<LSFLampDetailsDelegate>)delegate).Color  );
            
        }
    
        if (strcmp(propName, "VariableColorTemp") == 0)
        {
                
            status = val.Set( "b", ((id<LSFLampDetailsDelegate>)delegate).VariableColorTemp  );
            
        }
    
        if (strcmp(propName, "HasEffects") == 0)
        {
                
            status = val.Set( "b", ((id<LSFLampDetailsDelegate>)delegate).HasEffects  );
            
        }
    
        if (strcmp(propName, "MinVoltage") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).MinVoltage unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "MaxVoltage") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).MaxVoltage unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Wattage") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).Wattage unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "IncandescentEquivalent") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).IncandescentEquivalent unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "MaxLumens") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).MaxLumens unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "MinTemperature") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).MinTemperature unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "MaxTemperature") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).MaxTemperature unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "ColorRenderingIndex") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampDetailsDelegate>)delegate).ColorRenderingIndex unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "LampID") == 0)
        {
                
            status = val.Set( "s", [((id<LSFLampDetailsDelegate>)delegate).LampID UTF8String] );
            
        }
    
    }
    else if (strcmp(ifcName, "org.allseen.LSF.LampState") == 0) 
    {
    
        if (strcmp(propName, "Version") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampStateDelegate>)delegate).LampStateVersion unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "OnOff") == 0)
        {
                
            status = val.Set( "b", ((id<LSFLampStateDelegate>)delegate).OnOff  );
            
        }
    
        if (strcmp(propName, "Hue") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampStateDelegate>)delegate).Hue unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Saturation") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampStateDelegate>)delegate).Saturation unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "ColorTemp") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampStateDelegate>)delegate).ColorTemp unsignedIntValue] );
            
        }
    
        if (strcmp(propName, "Brightness") == 0)
        {
                
            status = val.Set( "u", [((id<LSFLampStateDelegate>)delegate).Brightness unsignedIntValue] );
            
        }
    
    }
    
    
    }
    
    return status;
}
    
QStatus LSFLampObjectImpl::Set(const char* ifcName, const char* propName, MsgArg& val)
{
    QStatus status = ER_BUS_NO_SUCH_PROPERTY;
    
    @autoreleasepool {
    
    if (strcmp(ifcName, "org.allseen.LSF.LampState") == 0)
    {
    
        if (strcmp(propName, "OnOff") == 0)
        {
        bool propValue;
            status = val.Get("b", &propValue);
            ((id<LSFLampStateDelegate>)delegate).OnOff = propValue;
            
        }    
    
        if (strcmp(propName, "Hue") == 0)
        {
        uint32_t propValue;
            status = val.Get("u", &propValue);
            ((id<LSFLampStateDelegate>)delegate).Hue = [NSNumber numberWithUnsignedInt:propValue];
            
        }    
    
        if (strcmp(propName, "Saturation") == 0)
        {
        uint32_t propValue;
            status = val.Get("u", &propValue);
            ((id<LSFLampStateDelegate>)delegate).Saturation = [NSNumber numberWithUnsignedInt:propValue];
            
        }    
    
        if (strcmp(propName, "ColorTemp") == 0)
        {
        uint32_t propValue;
            status = val.Get("u", &propValue);
            ((id<LSFLampStateDelegate>)delegate).ColorTemp = [NSNumber numberWithUnsignedInt:propValue];
            
        }    
    
        if (strcmp(propName, "Brightness") == 0)
        {
        uint32_t propValue;
            status = val.Get("u", &propValue);
            ((id<LSFLampStateDelegate>)delegate).Brightness = [NSNumber numberWithUnsignedInt:propValue];
            
        }    
    
    }
    
    
    }

    return status;
}

void LSFLampObjectImpl::ClearLampFault(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    uint32_t inArg0 = msg->GetArg(0)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSNumber* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFLampServiceDelegate>)delegate clearLampFaultWithFaultCode:[NSNumber numberWithUnsignedInt:inArg0]  responseCode:&outArg0 faultCode:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("u", [outArg1 unsignedIntValue]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for ClearLampFault. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFLampObjectImpl::TransitionLampState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    uint64_t inArg0 = msg->GetArg(0)->v_uint64;
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;

    
    // call the Objective-C delegate method
    //
    
	outArg0 = [(id<LSFLampStateDelegate>)delegate transitionLamsStateWithTimestamp:[NSNumber numberWithUnsignedLongLong:inArg0] newState:inArg1 transitionPeriod:[NSNumber numberWithUnsignedInt:inArg2] message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[1];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    QStatus status = MethodReply(msg, outArgs, 1);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for TransitionLampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFLampObjectImpl::ApplyPulseEffect(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    AJNMessageArgument* inArg0 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(0))) shouldDeleteHandleOnDealloc:YES];        
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    uint32_t inArg3 = msg->GetArg(3)->v_uint32;
        
    uint32_t inArg4 = msg->GetArg(4)->v_uint32;
        
    uint64_t inArg5 = msg->GetArg(5)->v_uint64;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;

    
    // call the Objective-C delegate method
    //
    
	outArg0 = [(id<LSFLampStateDelegate>)delegate applyPulseEffectWithFromState:inArg0 toState:inArg1 period:[NSNumber numberWithUnsignedInt:inArg2] duration:[NSNumber numberWithUnsignedInt:inArg3] numPulses:[NSNumber numberWithUnsignedInt:inArg4] timestamp:[NSNumber numberWithUnsignedLongLong:inArg5] message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[1];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    QStatus status = MethodReply(msg, outArgs, 1);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for ApplyPulseEffect. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

QStatus LSFLampObjectImpl::SendLampStateChanged(const char * LampID, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[1];

    
            args[0].Set( "s", LampID );
        

    return Signal(destination, sessionId, *LampStateChangedSignalMember, args, 1, timeToLive, flags);
}


////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  Objective-C Bus Object implementation for AJNLSFLampObject
//
////////////////////////////////////////////////////////////////////////////////

@implementation AJNLSFLampObject

@dynamic handle;

@synthesize LampServiceInterfaceVersion = _LampServiceInterfaceVersion;
@synthesize LampServiceVersion = _LampServiceVersion;
@synthesize LampFaults = _LampFaults;
@synthesize LampParametersVersion = _LampParametersVersion;
@synthesize Energy_Usage_Milliwatts = _Energy_Usage_Milliwatts;
@synthesize Brightness_Lumens = _Brightness_Lumens;
@synthesize LampDetailsVersion = _LampDetailsVersion;
@synthesize Make = _Make;
@synthesize Model = _Model;
@synthesize Type = _Type;
@synthesize LampType = _LampType;
@synthesize LampBaseType = _LampBaseType;
@synthesize LampBeamAngle = _LampBeamAngle;
@synthesize Dimmable = _Dimmable;
@synthesize Color = _Color;
@synthesize VariableColorTemp = _VariableColorTemp;
@synthesize HasEffects = _HasEffects;
@synthesize MinVoltage = _MinVoltage;
@synthesize MaxVoltage = _MaxVoltage;
@synthesize Wattage = _Wattage;
@synthesize IncandescentEquivalent = _IncandescentEquivalent;
@synthesize MaxLumens = _MaxLumens;
@synthesize MinTemperature = _MinTemperature;
@synthesize MaxTemperature = _MaxTemperature;
@synthesize ColorRenderingIndex = _ColorRenderingIndex;
@synthesize LampID = _LampID;
@synthesize LampStateVersion = _LampStateVersion;
@synthesize OnOff = _OnOff;
@synthesize Hue = _Hue;
@synthesize Saturation = _Saturation;
@synthesize ColorTemp = _ColorTemp;
@synthesize Brightness = _Brightness;


- (LSFLampObjectImpl*)busObject
{
    return static_cast<LSFLampObjectImpl*>(self.handle);
}

- (id)initWithBusAttachment:(AJNBusAttachment *)busAttachment onPath:(NSString *)path
{
    self = [super initWithBusAttachment:busAttachment onPath:path];
    if (self) {
        QStatus status;

        status = ER_OK;
        
        AJNInterfaceDescription *interfaceDescription;
        
    
        //
        // LSFLampServiceDelegate interface (org.allseen.LSF.LampService)
        //
        // create an interface description, or if that fails, get the interface as it was already created
        //
        interfaceDescription = [busAttachment createInterfaceWithName:@"org.allseen.LSF.LampService"];

    
        // add the properties to the interface description
        //
    
        status = [interfaceDescription addPropertyWithName:@"Version" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Version (LampServiceInterfaceVersion)" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"LampServiceVersion" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  LampServiceVersion" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"LampFaults" signature:@"au"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  LampFaults" userInfo:nil];
        }
    
        // add the methods to the interface description
        //
    
        status = [interfaceDescription addMethodWithName:@"ClearLampFault" inputSignature:@"u" outputSignature:@"uu" argumentNames:[NSArray arrayWithObjects:@"LampFaultCode",@"LampResponseCode",@"LampFaultCode", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: ClearLampFault" userInfo:nil];
        }
    
    

    
        [interfaceDescription activate];

        //
        // LSFLampParametersDelegate interface (org.allseen.LSF.LampParameters)
        //
        // create an interface description, or if that fails, get the interface as it was already created
        //
        interfaceDescription = [busAttachment createInterfaceWithName:@"org.allseen.LSF.LampParameters"];

    
        // add the properties to the interface description
        //
    
        status = [interfaceDescription addPropertyWithName:@"Version" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Version (LampParametersVersion)" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Energy_Usage_Milliwatts" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Energy_Usage_Milliwatts" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Brightness_Lumens" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Brightness_Lumens" userInfo:nil];
        }
    
    

    
        [interfaceDescription activate];

        //
        // LSFLampDetailsDelegate interface (org.allseen.LSF.LampDetails)
        //
        // create an interface description, or if that fails, get the interface as it was already created
        //
        interfaceDescription = [busAttachment createInterfaceWithName:@"org.allseen.LSF.LampDetails"];

    
        // add the properties to the interface description
        //
    
        status = [interfaceDescription addPropertyWithName:@"Version" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Version (LampDetailsVersion)" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Make" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Make" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Model" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Model" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Type" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Type" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"LampType" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  LampType" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"LampBaseType" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  LampBaseType" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"LampBeamAngle" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  LampBeamAngle" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Dimmable" signature:@"b"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Dimmable" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Color" signature:@"b"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Color" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"VariableColorTemp" signature:@"b"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  VariableColorTemp" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"HasEffects" signature:@"b"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  HasEffects" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"MinVoltage" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  MinVoltage" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"MaxVoltage" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  MaxVoltage" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Wattage" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Wattage" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"IncandescentEquivalent" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  IncandescentEquivalent" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"MaxLumens" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  MaxLumens" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"MinTemperature" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  MinTemperature" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"MaxTemperature" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  MaxTemperature" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"ColorRenderingIndex" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  ColorRenderingIndex" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"LampID" signature:@"s"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  LampID" userInfo:nil];
        }
    
    

    
        [interfaceDescription activate];

        //
        // LSFLampStateDelegate interface (org.allseen.LSF.LampState)
        //
        // create an interface description, or if that fails, get the interface as it was already created
        //
        interfaceDescription = [busAttachment createInterfaceWithName:@"org.allseen.LSF.LampState"];

    
        // add the properties to the interface description
        //
    
        status = [interfaceDescription addPropertyWithName:@"Version" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Version (LampStateVersion)" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"OnOff" signature:@"b"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  OnOff" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Hue" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Hue" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Saturation" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Saturation" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"ColorTemp" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  ColorTemp" userInfo:nil];
        }
    
        status = [interfaceDescription addPropertyWithName:@"Brightness" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Brightness" userInfo:nil];
        }
    
        // add the methods to the interface description
        //
    
        status = [interfaceDescription addMethodWithName:@"TransitionLampState" inputSignature:@"ta{sv}u" outputSignature:@"u" argumentNames:[NSArray arrayWithObjects:@"Timestamp",@"NewState",@"TransitionPeriod",@"LampResponseCode", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: TransitionLampState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"ApplyPulseEffect" inputSignature:@"a{sv}a{sv}uuut" outputSignature:@"u" argumentNames:[NSArray arrayWithObjects:@"FromState",@"ToState",@"period",@"duration",@"numPulses",@"timestamp",@"LampResponseCode", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: ApplyPulseEffect" userInfo:nil];
        }
    
        // add the signals to the interface description
        //
    
        status = [interfaceDescription addSignalWithName:@"LampStateChanged" inputSignature:@"s" argumentNames:[NSArray arrayWithObjects:@"LampID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampStateChanged" userInfo:nil];
        }
    
    

    
        [interfaceDescription activate];


        // create the internal C++ bus object
        //
        LSFLampObjectImpl *busObject = new LSFLampObjectImpl(*((ajn::BusAttachment*)busAttachment.handle), [path UTF8String], (id<LSFLampServiceDelegate, LSFLampParametersDelegate, LSFLampDetailsDelegate, LSFLampStateDelegate>)self);
        
        self.handle = busObject;
        
      
    }
    return self;
}

- (void)dealloc
{
    LSFLampObjectImpl *busObject = [self busObject];
    delete busObject;
    self.handle = nil;
}

    
- (void)clearLampFaultWithFaultCode:(NSNumber*)LampFaultCode responseCode:(NSNumber**)LampResponseCode faultCode:(NSNumber**)LampFaultCodeOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (NSNumber*)transitionLamsStateWithTimestamp:(NSNumber*)Timestamp newState:(AJNMessageArgument*)NewState transitionPeriod:(NSNumber*)TransitionPeriod message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (NSNumber*)applyPulseEffectWithFromState:(AJNMessageArgument*)FromState toState:(AJNMessageArgument*)ToState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses timestamp:(NSNumber*)timestamp message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}
- (void)sendlampStateDidChangedForLampID:(NSString*)LampID inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampStateChanged([LampID UTF8String], [destinationPath UTF8String], sessionId);
        
}

    
@end

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  Objective-C Proxy Bus Object implementation for LSFLampObject
//
////////////////////////////////////////////////////////////////////////////////

@interface LSFLampObjectProxy(Private)

@property (nonatomic, strong) AJNBusAttachment *bus;

- (ProxyBusObject*)proxyBusObject;

@end

@implementation LSFLampObjectProxy
    
- (NSNumber*)LampServiceInterfaceVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampService"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampService", "Version", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Version (LampServiceInterfaceVersion) on interface org.allseen.LSF.LampService. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)LampServiceVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampService"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampService", "LampServiceVersion", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property LampServiceVersion on interface org.allseen.LSF.LampService. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (AJNMessageArgument*)LampFaults
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampService"];
    
    
    MsgArg *propValue = new MsgArg();
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampService", "LampFaults", *propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property LampFaults on interface org.allseen.LSF.LampService. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    return [[AJNMessageArgument alloc] initWithHandle:propValue shouldDeleteHandleOnDealloc:YES];
        
}
    
- (NSNumber*)LampParametersVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampParameters"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampParameters", "Version", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Version (LampParametersVersion) on interface org.allseen.LSF.LampParameters. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)Energy_Usage_Milliwatts
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampParameters"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampParameters", "Energy_Usage_Milliwatts", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Energy_Usage_Milliwatts on interface org.allseen.LSF.LampParameters. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)Brightness_Lumens
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampParameters"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampParameters", "Brightness_Lumens", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Brightness_Lumens on interface org.allseen.LSF.LampParameters. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)LampDetailsVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "Version", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Version (LampDetailsVersion) on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)Make
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "Make", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Make on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)Model
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "Model", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Model on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)Type
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "Type", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Type on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)LampType
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "LampType", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property LampType on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)LampBaseType
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "LampBaseType", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property LampBaseType on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)LampBeamAngle
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "LampBeamAngle", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property LampBeamAngle on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (BOOL)Dimmable
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "Dimmable", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Dimmable on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return propValue.v_variant.val->v_bool;
        
}
    
- (BOOL)Color
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "Color", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Color on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return propValue.v_variant.val->v_bool;
        
}
    
- (BOOL)VariableColorTemp
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "VariableColorTemp", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property VariableColorTemp on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return propValue.v_variant.val->v_bool;
        
}
    
- (BOOL)HasEffects
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "HasEffects", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property HasEffects on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return propValue.v_variant.val->v_bool;
        
}
    
- (NSNumber*)MinVoltage
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "MinVoltage", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property MinVoltage on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)MaxVoltage
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "MaxVoltage", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property MaxVoltage on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)Wattage
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "Wattage", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Wattage on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)IncandescentEquivalent
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "IncandescentEquivalent", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property IncandescentEquivalent on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)MaxLumens
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "MaxLumens", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property MaxLumens on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)MinTemperature
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "MinTemperature", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property MinTemperature on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)MaxTemperature
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "MaxTemperature", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property MaxTemperature on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)ColorRenderingIndex
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "ColorRenderingIndex", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property ColorRenderingIndex on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSString*)LampID
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampDetails"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampDetails", "LampID", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property LampID on interface org.allseen.LSF.LampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSString stringWithCString:propValue.v_variant.val->v_string.str encoding:NSUTF8StringEncoding];
        
}
    
- (NSNumber*)LampStateVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampState", "Version", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Version (LampStateVersion) on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (BOOL)OnOff
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampState", "OnOff", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property OnOff on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return propValue.v_variant.val->v_bool;
        
}
    
- (void)setOnOff:(BOOL)propertyValue
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg arg;

    QStatus status = arg.Set("b", propertyValue);
    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to set property OnOff on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    self.proxyBusObject->SetProperty("org.allseen.LSF.LampState", "OnOff", arg); 
        
    
}
    
- (NSNumber*)Hue
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampState", "Hue", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Hue on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (void)setHue:(NSNumber*)propertyValue
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg arg;

    QStatus status = arg.Set("u", [propertyValue unsignedIntValue]);    
    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to set property Hue on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    self.proxyBusObject->SetProperty("org.allseen.LSF.LampState", "Hue", arg); 
        
    
}
    
- (NSNumber*)Saturation
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampState", "Saturation", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Saturation on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (void)setSaturation:(NSNumber*)propertyValue
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg arg;

    QStatus status = arg.Set("u", [propertyValue unsignedIntValue]);    
    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to set property Saturation on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    self.proxyBusObject->SetProperty("org.allseen.LSF.LampState", "Saturation", arg); 
        
    
}
    
- (NSNumber*)ColorTemp
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampState", "ColorTemp", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property ColorTemp on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (void)setColorTemp:(NSNumber*)propertyValue
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg arg;

    QStatus status = arg.Set("u", [propertyValue unsignedIntValue]);    
    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to set property ColorTemp on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    self.proxyBusObject->SetProperty("org.allseen.LSF.LampState", "ColorTemp", arg); 
        
    
}
    
- (NSNumber*)Brightness
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.LampState", "Brightness", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Brightness on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (void)setBrightness:(NSNumber*)propertyValue
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    
    MsgArg arg;

    QStatus status = arg.Set("u", [propertyValue unsignedIntValue]);    
    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to set property Brightness on interface org.allseen.LSF.LampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    self.proxyBusObject->SetProperty("org.allseen.LSF.LampState", "Brightness", arg); 
        
    
}
    
- (void)clearLampFaultWithFaultCode:(NSNumber*)LampFaultCode responseCode:(NSNumber**)LampResponseCode faultCode:(NSNumber**)LampFaultCodeOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampService"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("u", [LampFaultCode unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.LampService", "ClearLampFault", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.LampService failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *LampResponseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *LampFaultCodeOut = [NSNumber numberWithUnsignedInt:reply->GetArg(1)->v_uint32];
        

}

- (NSNumber*)transitionLamsStateWithTimestamp:(NSNumber*)Timestamp newState:(AJNMessageArgument*)NewState transitionPeriod:(NSNumber*)TransitionPeriod
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("t", [Timestamp unsignedLongLongValue]);
        
    inArgs[1] = *[NewState msgArg];
        
    inArgs[2].Set("u", [TransitionPeriod unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.LampState", "TransitionLampState", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.LampState failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return nil;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    return [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        

}

- (NSNumber*)applyPulseEffectWithFromState:(AJNMessageArgument*)FromState toState:(AJNMessageArgument*)ToState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses timestamp:(NSNumber*)timestamp
{
    [self addInterfaceNamed:@"org.allseen.LSF.LampState"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[6];
    
    inArgs[0] = *[FromState msgArg];
        
    inArgs[1] = *[ToState msgArg];
        
    inArgs[2].Set("u", [period unsignedIntValue]);
        
    inArgs[3].Set("u", [duration unsignedIntValue]);
        
    inArgs[4].Set("u", [numPulses unsignedIntValue]);
        
    inArgs[5].Set("t", [timestamp unsignedLongLongValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.LampState", "ApplyPulseEffect", inArgs, 6, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.LampState failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return nil;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    return [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        

}

@end

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  C++ Signal Handler implementation for LSFLampStateDelegate
//
////////////////////////////////////////////////////////////////////////////////

class LSFLampStateDelegateSignalHandlerImpl : public AJNSignalHandlerImpl
{
private:

    const ajn::InterfaceDescription::Member* LampStateChangedSignalMember;
    void LampStateChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    
public:
    /**
     * Constructor for the AJN signal handler implementation.
     *
     * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
     */    
    LSFLampStateDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate);
    
    virtual void RegisterSignalHandler(ajn::BusAttachment &bus);
    
    virtual void UnregisterSignalHandler(ajn::BusAttachment &bus);
    
    /**
     * Virtual destructor for derivable class.
     */
    virtual ~LSFLampStateDelegateSignalHandlerImpl();
};


/**
 * Constructor for the AJN signal handler implementation.
 *
 * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
 */    
LSFLampStateDelegateSignalHandlerImpl::LSFLampStateDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate) : AJNSignalHandlerImpl(aDelegate)
{
	LampStateChangedSignalMember = NULL;

}

LSFLampStateDelegateSignalHandlerImpl::~LSFLampStateDelegateSignalHandlerImpl()
{
    m_delegate = NULL;
}

void LSFLampStateDelegateSignalHandlerImpl::RegisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampStateChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.LampState");

    if (interface) {
        // Store the LampStateChanged signal member away so it can be quickly looked up
        LampStateChangedSignalMember = interface->GetMember("LampStateChanged");
        assert(LampStateChangedSignalMember);

        
        // Register signal handler for LampStateChanged
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFLampStateDelegateSignalHandlerImpl::LampStateChangedSignalHandler),
            LampStateChangedSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFLampStateDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.LampState not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

}

void LSFLampStateDelegateSignalHandlerImpl::UnregisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampStateChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.LampState");
    
    // Store the LampStateChanged signal member away so it can be quickly looked up
    LampStateChangedSignalMember = interface->GetMember("LampStateChanged");
    assert(LampStateChangedSignalMember);
    
    // Unregister signal handler for LampStateChanged
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFLampStateDelegateSignalHandlerImpl::LampStateChangedSignalHandler),
        LampStateChangedSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFLampStateDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

}


void LSFLampStateDelegateSignalHandlerImpl::LampStateChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampStateChanged signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFLampStateDelegateSignalHandler>)m_delegate didReceivelampStateDidChangedForLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] inSession:sessionId message:signalMessage];
                
        });
        
    }
}


@implementation AJNBusAttachment(LSFLampStateDelegate)

- (void)registerLSFLampStateDelegateSignalHandler:(id<LSFLampStateDelegateSignalHandler>)signalHandler
{
    LSFLampStateDelegateSignalHandlerImpl *signalHandlerImpl = new LSFLampStateDelegateSignalHandlerImpl(signalHandler);
    signalHandler.handle = signalHandlerImpl;
    [self registerSignalHandler:signalHandler];
}

@end

////////////////////////////////////////////////////////////////////////////////
    