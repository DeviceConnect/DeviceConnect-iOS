//
//  AJNLSFControllerService.mm
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
//  AJNLSFControllerService.mm
//
////////////////////////////////////////////////////////////////////////////////

#import <alljoyn/BusAttachment.h>
#import <alljoyn/BusObject.h>
#import "AJNBusObjectImpl.h"
#import "AJNInterfaceDescription.h"
#import "AJNMessageArgument.h"
#import "AJNSignalHandlerImpl.h"

#import "LSFControllerService.h"

using namespace ajn;


@interface AJNMessageArgument(Private)

/**
 * Helper to return the C++ API object that is encapsulated by this objective-c class
 */
@property (nonatomic, readonly) MsgArg *msgArg;

@end


////////////////////////////////////////////////////////////////////////////////
//
//  C++ Bus Object class declaration for LSFControllerServiceObjectImpl
//
////////////////////////////////////////////////////////////////////////////////
class LSFControllerServiceObjectImpl : public AJNBusObjectImpl
{
private:
    const InterfaceDescription::Member* ControllerServiceLightingResetSignalMember;
	const InterfaceDescription::Member* LampNameChangedSignalMember;
	const InterfaceDescription::Member* LampStateChangedSignalMember;
	const InterfaceDescription::Member* LampsFoundSignalMember;
	const InterfaceDescription::Member* LampsLostSignalMember;
	const InterfaceDescription::Member* LampGroupsNameChangedSignalMember;
	const InterfaceDescription::Member* LampGroupsCreatedSignalMember;
	const InterfaceDescription::Member* LampGroupsUpdatedSignalMember;
	const InterfaceDescription::Member* LampGroupsDeletedSignalMember;

    
public:
    LSFControllerServiceObjectImpl(BusAttachment &bus, const char *path, id<LSFControllerServiceDelegate, LSFControllerServiceLampDelegate, LSFControllerServiceLampGroupDelegate> aDelegate);

    
    // properties
    //
    virtual QStatus Get(const char* ifcName, const char* propName, MsgArg& val);
    virtual QStatus Set(const char* ifcName, const char* propName, MsgArg& val);        
    
    
    // methods
    //
    void LightingResetControllerService(const InterfaceDescription::Member* member, Message& msg);
	void GetControllerServiceVersion(const InterfaceDescription::Member* member, Message& msg);
	void GetAllLampIDs(const InterfaceDescription::Member* member, Message& msg);
	void GetLampSupportedLanguages(const InterfaceDescription::Member* member, Message& msg);
	void GetLampManufacturer(const InterfaceDescription::Member* member, Message& msg);
	void GetLampName(const InterfaceDescription::Member* member, Message& msg);
	void SetLampName(const InterfaceDescription::Member* member, Message& msg);
	void GetLampDetails(const InterfaceDescription::Member* member, Message& msg);
	void GetLampParameters(const InterfaceDescription::Member* member, Message& msg);
	void GetLampParametersField(const InterfaceDescription::Member* member, Message& msg);
	void GetLampState(const InterfaceDescription::Member* member, Message& msg);
	void GetLampStateField(const InterfaceDescription::Member* member, Message& msg);
	void TransitionLampState(const InterfaceDescription::Member* member, Message& msg);
	void PulseLampWithState(const InterfaceDescription::Member* member, Message& msg);
	void PulseLampWithPreset(const InterfaceDescription::Member* member, Message& msg);
	void TransitionLampStateToPreset(const InterfaceDescription::Member* member, Message& msg);
	void TransitionLampStateField(const InterfaceDescription::Member* member, Message& msg);
	void ResetLampState(const InterfaceDescription::Member* member, Message& msg);
	void ResetLampStateField(const InterfaceDescription::Member* member, Message& msg);
	void GetLampFaults(const InterfaceDescription::Member* member, Message& msg);
	void ClearLampFaults(const InterfaceDescription::Member* member, Message& msg);
	void GetLampServiceVersion(const InterfaceDescription::Member* member, Message& msg);
	void GetAllLampGroupIDs(const InterfaceDescription::Member* member, Message& msg);
	void GetLampGroupName(const InterfaceDescription::Member* member, Message& msg);
	void SetLampGroupName(const InterfaceDescription::Member* member, Message& msg);
	void CreateLampGroup(const InterfaceDescription::Member* member, Message& msg);
	void UpdateLampGroup(const InterfaceDescription::Member* member, Message& msg);
	void DeleteLampGroup(const InterfaceDescription::Member* member, Message& msg);
	void GetLampGroup(const InterfaceDescription::Member* member, Message& msg);
	void TransitionLampGroupState(const InterfaceDescription::Member* member, Message& msg);
	void PulseLampGroupWithState(const InterfaceDescription::Member* member, Message& msg);
	void PulseLampGroupWithPreset(const InterfaceDescription::Member* member, Message& msg);
	void TransitionLampGroupStateToPreset(const InterfaceDescription::Member* member, Message& msg);
	void TransitionLampGroupStateField(const InterfaceDescription::Member* member, Message& msg);
	void ResetLampGroupState(const InterfaceDescription::Member* member, Message& msg);
	void ResetLampGroupStateField(const InterfaceDescription::Member* member, Message& msg);

    
    // signals
    //
    QStatus SendControllerServiceLightingReset( const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampNameChanged(const char * LampID,const char * lampName, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampStateChanged(const char * LampID,const char * lampName, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampsFound(const char * LampID, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampsLost(MsgArg* lampIDs, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampGroupsNameChanged(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampGroupsCreated(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampGroupsUpdated(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);
	QStatus SendLampGroupsDeleted(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive = 0, uint8_t flags = 0);

};
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  C++ Bus Object implementation for LSFControllerServiceObjectImpl
//
////////////////////////////////////////////////////////////////////////////////

LSFControllerServiceObjectImpl::LSFControllerServiceObjectImpl(BusAttachment &bus, const char *path, id<LSFControllerServiceDelegate, LSFControllerServiceLampDelegate, LSFControllerServiceLampGroupDelegate> aDelegate) : 
    AJNBusObjectImpl(bus,path,aDelegate)
{
    const InterfaceDescription* interfaceDescription = NULL;
    QStatus status;
    status = ER_OK;
    
    
    // Add the org.allseen.LSF.ControllerService interface to this object
    //
    interfaceDescription = bus.GetInterface("org.allseen.LSF.ControllerService");
    assert(interfaceDescription);
    AddInterface(*interfaceDescription);

    
    // Register the method handlers for interface LSFControllerServiceDelegate with the object
    //
    const MethodEntry methodEntriesForLSFControllerServiceDelegate[] = {

        {
			interfaceDescription->GetMember("LightingResetControllerService"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::LightingResetControllerService)
		},

		{
			interfaceDescription->GetMember("GetControllerServiceVersion"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetControllerServiceVersion)
		}
    
    };
    
    status = AddMethodHandlers(methodEntriesForLSFControllerServiceDelegate, sizeof(methodEntriesForLSFControllerServiceDelegate) / sizeof(methodEntriesForLSFControllerServiceDelegate[0]));
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred while adding method handlers for interface org.allseen.LSF.ControllerService to the interface description. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    // save off signal members for later
    //
    ControllerServiceLightingResetSignalMember = interfaceDescription->GetMember("ControllerServiceLightingReset");
    assert(ControllerServiceLightingResetSignalMember);    

    // Add the org.allseen.LSF.ControllerService.Lamp interface to this object
    //
    interfaceDescription = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");
    assert(interfaceDescription);
    AddInterface(*interfaceDescription);

    
    // Register the method handlers for interface LSFControllerServiceLampDelegate with the object
    //
    const MethodEntry methodEntriesForLSFControllerServiceLampDelegate[] = {

        {
			interfaceDescription->GetMember("GetAllLampIDs"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetAllLampIDs)
		},

		{
			interfaceDescription->GetMember("GetLampSupportedLanguages"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampSupportedLanguages)
		},

		{
			interfaceDescription->GetMember("GetLampManufacturer"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampManufacturer)
		},

		{
			interfaceDescription->GetMember("GetLampName"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampName)
		},

		{
			interfaceDescription->GetMember("SetLampName"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::SetLampName)
		},

		{
			interfaceDescription->GetMember("GetLampDetails"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampDetails)
		},

		{
			interfaceDescription->GetMember("GetLampParameters"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampParameters)
		},

		{
			interfaceDescription->GetMember("GetLampParametersField"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampParametersField)
		},

		{
			interfaceDescription->GetMember("GetLampState"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampState)
		},

		{
			interfaceDescription->GetMember("GetLampStateField"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampStateField)
		},

		{
			interfaceDescription->GetMember("TransitionLampState"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::TransitionLampState)
		},

		{
			interfaceDescription->GetMember("PulseLampWithState"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::PulseLampWithState)
		},

		{
			interfaceDescription->GetMember("PulseLampWithPreset"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::PulseLampWithPreset)
		},

		{
			interfaceDescription->GetMember("TransitionLampStateToPreset"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::TransitionLampStateToPreset)
		},

		{
			interfaceDescription->GetMember("TransitionLampStateField"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::TransitionLampStateField)
		},

		{
			interfaceDescription->GetMember("ResetLampState"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::ResetLampState)
		},

		{
			interfaceDescription->GetMember("ResetLampStateField"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::ResetLampStateField)
		},

		{
			interfaceDescription->GetMember("GetLampFaults"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampFaults)
		},

		{
			interfaceDescription->GetMember("ClearLampFaults"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::ClearLampFaults)
		},

		{
			interfaceDescription->GetMember("GetLampServiceVersion"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampServiceVersion)
		}
    
    };
    
    status = AddMethodHandlers(methodEntriesForLSFControllerServiceLampDelegate, sizeof(methodEntriesForLSFControllerServiceLampDelegate) / sizeof(methodEntriesForLSFControllerServiceLampDelegate[0]));
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred while adding method handlers for interface org.allseen.LSF.ControllerService.Lamp to the interface description. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    // save off signal members for later
    //
    LampNameChangedSignalMember = interfaceDescription->GetMember("LampNameChanged");
    assert(LampNameChangedSignalMember);    
LampStateChangedSignalMember = interfaceDescription->GetMember("LampStateChanged");
    assert(LampStateChangedSignalMember);    
LampsFoundSignalMember = interfaceDescription->GetMember("LampsFound");
    assert(LampsFoundSignalMember);    
LampsLostSignalMember = interfaceDescription->GetMember("LampsLost");
    assert(LampsLostSignalMember);    

    // Add the org.allseen.LSF.ControllerService.LampGroup interface to this object
    //
    interfaceDescription = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");
    assert(interfaceDescription);
    AddInterface(*interfaceDescription);

    
    // Register the method handlers for interface LSFControllerServiceLampGroupDelegate with the object
    //
    const MethodEntry methodEntriesForLSFControllerServiceLampGroupDelegate[] = {

        {
			interfaceDescription->GetMember("GetAllLampGroupIDs"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetAllLampGroupIDs)
		},

		{
			interfaceDescription->GetMember("GetLampGroupName"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampGroupName)
		},

		{
			interfaceDescription->GetMember("SetLampGroupName"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::SetLampGroupName)
		},

		{
			interfaceDescription->GetMember("CreateLampGroup"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::CreateLampGroup)
		},

		{
			interfaceDescription->GetMember("UpdateLampGroup"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::UpdateLampGroup)
		},

		{
			interfaceDescription->GetMember("DeleteLampGroup"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::DeleteLampGroup)
		},

		{
			interfaceDescription->GetMember("GetLampGroup"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::GetLampGroup)
		},

		{
			interfaceDescription->GetMember("TransitionLampGroupState"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::TransitionLampGroupState)
		},

		{
			interfaceDescription->GetMember("PulseLampGroupWithState"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::PulseLampGroupWithState)
		},

		{
			interfaceDescription->GetMember("PulseLampGroupWithPreset"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::PulseLampGroupWithPreset)
		},

		{
			interfaceDescription->GetMember("TransitionLampGroupStateToPreset"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::TransitionLampGroupStateToPreset)
		},

		{
			interfaceDescription->GetMember("TransitionLampGroupStateField"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::TransitionLampGroupStateField)
		},

		{
			interfaceDescription->GetMember("ResetLampGroupState"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::ResetLampGroupState)
		},

		{
			interfaceDescription->GetMember("ResetLampGroupStateField"), static_cast<MessageReceiver::MethodHandler>(&LSFControllerServiceObjectImpl::ResetLampGroupStateField)
		}
    
    };
    
    status = AddMethodHandlers(methodEntriesForLSFControllerServiceLampGroupDelegate, sizeof(methodEntriesForLSFControllerServiceLampGroupDelegate) / sizeof(methodEntriesForLSFControllerServiceLampGroupDelegate[0]));
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred while adding method handlers for interface org.allseen.LSF.ControllerService.LampGroup to the interface description. %@", [AJNStatus descriptionForStatusCode:status]);
    }
    
    // save off signal members for later
    //
    LampGroupsNameChangedSignalMember = interfaceDescription->GetMember("LampGroupsNameChanged");
    assert(LampGroupsNameChangedSignalMember);    
LampGroupsCreatedSignalMember = interfaceDescription->GetMember("LampGroupsCreated");
    assert(LampGroupsCreatedSignalMember);    
LampGroupsUpdatedSignalMember = interfaceDescription->GetMember("LampGroupsUpdated");
    assert(LampGroupsUpdatedSignalMember);    
LampGroupsDeletedSignalMember = interfaceDescription->GetMember("LampGroupsDeleted");
    assert(LampGroupsDeletedSignalMember);    


}


QStatus LSFControllerServiceObjectImpl::Get(const char* ifcName, const char* propName, MsgArg& val)
{
    QStatus status = ER_BUS_NO_SUCH_PROPERTY;
    
    @autoreleasepool {
    
    if (strcmp(ifcName, "org.allseen.LSF.ControllerService") == 0) 
    {
    
        if (strcmp(propName, "Version") == 0)
        {
                
            status = val.Set( "u", [((id<LSFControllerServiceDelegate>)delegate).ControllerServiceVersion unsignedIntValue] );
            
        }
    
    }
    else if (strcmp(ifcName, "org.allseen.LSF.ControllerService.Lamp") == 0) 
    {
    
        if (strcmp(propName, "Version") == 0)
        {
                
            status = val.Set( "u", [((id<LSFControllerServiceLampDelegate>)delegate).LampVersion unsignedIntValue] );
            
        }
    
    }
    else if (strcmp(ifcName, "org.allseen.LSF.ControllerService.LampGroup") == 0) 
    {
    
        if (strcmp(propName, "Version") == 0)
        {
                
            status = val.Set( "u", [((id<LSFControllerServiceLampGroupDelegate>)delegate).LampGroupVersion unsignedIntValue] );
            
        }
    
    }
    
    
    }
    
    return status;
}
    
QStatus LSFControllerServiceObjectImpl::Set(const char* ifcName, const char* propName, MsgArg& val)
{
    QStatus status = ER_BUS_NO_SUCH_PROPERTY;
    
    @autoreleasepool {
    
    
    
    }

    return status;
}

void LSFControllerServiceObjectImpl::LightingResetControllerService(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    // declare the output arguments
    //
    
	NSNumber* outArg0;

    
    // call the Objective-C delegate method
    //
    
	outArg0 = [(id<LSFControllerServiceDelegate>)delegate lightingResetControllerService:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[1];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    QStatus status = MethodReply(msg, outArgs, 1);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for LightingResetControllerService. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetControllerServiceVersion(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    // declare the output arguments
    //
    
	NSNumber* outArg0;

    
    // call the Objective-C delegate method
    //
    
	outArg0 = [(id<LSFControllerServiceDelegate>)delegate getControllerServiceVersion:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[1];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    QStatus status = MethodReply(msg, outArgs, 1);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetControllerServiceVersion. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

QStatus LSFControllerServiceObjectImpl::SendControllerServiceLightingReset( const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[0];

    

    return Signal(destination, sessionId, *ControllerServiceLightingResetSignalMember, args, 0, timeToLive, flags);
}


void LSFControllerServiceObjectImpl::GetAllLampIDs(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	AJNMessageArgument* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getAllLampIDsWithResponseCode:&outArg0 lampIDs:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("as", [outArg1 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetAllLampIDs. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampSupportedLanguages(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	AJNMessageArgument* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampSupportedLangueagesWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 supportedLanguages:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("as", [outArg2 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampSupportedLanguages. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampManufacturer(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;
	NSString* outArg3;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampManufacturerWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] language:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 language:&outArg2 manufacturer:&outArg3  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[4];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    outArgs[3].Set("s", [outArg3 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 4);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampManufacturer. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampName(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;
	NSString* outArg3;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampNameWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] language:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 language:&outArg2 lampName:&outArg3  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[4];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    outArgs[3].Set("s", [outArg3 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 4);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampName. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::SetLampName(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    qcc::String inArg2 = msg->GetArg(2)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate setLampNameWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] language:[NSString stringWithCString:inArg2.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 language:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for SetLampName. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampDetails(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	AJNMessageArgument* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampDetailsWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 lampDetails:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("a{sv}", [outArg2 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampDetails. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampParameters(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	AJNMessageArgument* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampParametersWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 lampParameters:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("a{sv}", [outArg2 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampParameters. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampParametersField(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;
	NSString* outArg3;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampParametersFieldWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] parameterFieldName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 parameterFieldName:&outArg2 parameterFieldValue:&outArg3  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[4];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    outArgs[3].Set("s", [outArg3 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 4);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampParametersField. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	AJNMessageArgument* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampStateWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 lampState:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("a{sv}", [outArg2 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampStateField(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;
	NSString* outArg3;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampStateFieldWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] stateFieldName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 stateFieldName:&outArg2 stateFieldValue:&outArg3  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[4];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    outArgs[3].Set("s", [outArg3 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 4);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampStateField. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::TransitionLampState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate transitionLampStateWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampState:inArg1 transitionPeriod:[NSNumber numberWithUnsignedInt:inArg2] responseCode:&outArg0 lampID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for TransitionLampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::PulseLampWithState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    AJNMessageArgument* inArg2 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(2))) shouldDeleteHandleOnDealloc:YES];        
        
    uint32_t inArg3 = msg->GetArg(3)->v_uint32;
        
    uint32_t inArg4 = msg->GetArg(4)->v_uint32;
        
    uint32_t inArg5 = msg->GetArg(5)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate pulseLampWithStateWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] fromState:inArg1 toState:inArg2 period:[NSNumber numberWithUnsignedInt:inArg3] duration:[NSNumber numberWithUnsignedInt:inArg4] numPulses:[NSNumber numberWithUnsignedInt:inArg5] responseCode:&outArg0 lampID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for PulseLampWithState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::PulseLampWithPreset(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    uint32_t inArg1 = msg->GetArg(1)->v_uint32;
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    uint32_t inArg3 = msg->GetArg(3)->v_uint32;
        
    uint32_t inArg4 = msg->GetArg(4)->v_uint32;
        
    uint32_t inArg5 = msg->GetArg(5)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate pulseLampWithPresetWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] fromPresetID:[NSNumber numberWithUnsignedInt:inArg1] toPresetID:[NSNumber numberWithUnsignedInt:inArg2] period:[NSNumber numberWithUnsignedInt:inArg3] duration:[NSNumber numberWithUnsignedInt:inArg4] numPulses:[NSNumber numberWithUnsignedInt:inArg5] responseCode:&outArg0 lampID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for PulseLampWithPreset. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::TransitionLampStateToPreset(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    uint32_t inArg1 = msg->GetArg(1)->v_uint32;
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate transitionLampStateToPresetWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] presetID:[NSNumber numberWithUnsignedInt:inArg1] transitionPeriod:[NSNumber numberWithUnsignedInt:inArg2] responseCode:&outArg0 lampID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for TransitionLampStateToPreset. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::TransitionLampStateField(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    qcc::String inArg2 = msg->GetArg(2)->v_string.str;
        
    uint32_t inArg3 = msg->GetArg(3)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate transitionLampStateFieldWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] stateFieldName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] stateFieldValue:[NSString stringWithCString:inArg2.c_str() encoding:NSUTF8StringEncoding] transitionPeriod:[NSNumber numberWithUnsignedInt:inArg3] responseCode:&outArg0 lampID:&outArg1 lampStateFieldName:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for TransitionLampStateField. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::ResetLampState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate resetLampStateWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for ResetLampState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::ResetLampStateField(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate resetLampStateFieldWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] stateFieldName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 stateFieldName:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for ResetLampStateField. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampFaults(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	AJNMessageArgument* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampFaultsWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 lampFaults:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("au", [outArg2 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampFaults. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::ClearLampFaults(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    uint32_t inArg1 = msg->GetArg(1)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSNumber* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate clearLampFaultsWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampFault:[NSNumber numberWithUnsignedInt:inArg1] responseCode:&outArg0 lampID:&outArg1 lampFault:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("u", [outArg2 unsignedIntValue]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for ClearLampFaults. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampServiceVersion(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSNumber* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampDelegate>)delegate getLampServiceVersionWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 version:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("u", [outArg2 unsignedIntValue]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampServiceVersion. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

QStatus LSFControllerServiceObjectImpl::SendLampNameChanged(const char * LampID,const char * lampName, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[2];

    
            args[0].Set( "s", LampID );
        
            args[1].Set( "s", lampName );
        

    return Signal(destination, sessionId, *LampNameChangedSignalMember, args, 2, timeToLive, flags);
}


QStatus LSFControllerServiceObjectImpl::SendLampStateChanged(const char * LampID,const char * lampName, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[2];

    
            args[0].Set( "s", LampID );
        
            args[1].Set( "s", lampName );
        

    return Signal(destination, sessionId, *LampStateChangedSignalMember, args, 2, timeToLive, flags);
}


QStatus LSFControllerServiceObjectImpl::SendLampsFound(const char * LampID, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[1];

    
            args[0].Set( "s", LampID );
        

    return Signal(destination, sessionId, *LampsFoundSignalMember, args, 1, timeToLive, flags);
}


QStatus LSFControllerServiceObjectImpl::SendLampsLost(MsgArg* lampIDs, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[1];

    args[0] = *lampIDs;

    return Signal(destination, sessionId, *LampsLostSignalMember, args, 1, timeToLive, flags);
}


void LSFControllerServiceObjectImpl::GetAllLampGroupIDs(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	AJNMessageArgument* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate getAllLampGroupIDsWithResponseCode:&outArg0 lampGroupIDs:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("as", [outArg1 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetAllLampGroupIDs. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampGroupName(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;
	NSString* outArg3;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate getLampGroupNameWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] language:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampIDGroupID:&outArg1 language:&outArg2 lampGroupName:&outArg3  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[4];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    outArgs[3].Set("s", [outArg3 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 4);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampGroupName. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::SetLampGroupName(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    qcc::String inArg2 = msg->GetArg(2)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate setLampGroupNameWithLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] language:[NSString stringWithCString:inArg2.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 language:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for SetLampGroupName. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::CreateLampGroup(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    AJNMessageArgument* inArg0 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(0))) shouldDeleteHandleOnDealloc:YES];        
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    qcc::String inArg2 = msg->GetArg(2)->v_string.str;
        
    qcc::String inArg3 = msg->GetArg(3)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate createLampGroupWithLampIDs:inArg0 lampGroupIDs:inArg1 lampGroupName:[NSString stringWithCString:inArg2.c_str() encoding:NSUTF8StringEncoding] language:[NSString stringWithCString:inArg3.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for CreateLampGroup. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::UpdateLampGroup(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    AJNMessageArgument* inArg2 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(2))) shouldDeleteHandleOnDealloc:YES];        
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate updateLampGroupWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampIDs:inArg1 lampGroupIDs:inArg2 responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for UpdateLampGroup. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::DeleteLampGroup(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate deleteLampGroupWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for DeleteLampGroup. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::GetLampGroup(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	AJNMessageArgument* outArg2;
	AJNMessageArgument* outArg3;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate getLampGroupWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampGroupID:&outArg1 lampID:&outArg2 lampGroupIDs:&outArg3  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[4];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("as", [outArg2 msgArg]);

    outArgs[3].Set("as", [outArg3 msgArg]);

    QStatus status = MethodReply(msg, outArgs, 4);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for GetLampGroup. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::TransitionLampGroupState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate transitionLampGroupStateWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampState:inArg1 transitionPeriod:[NSNumber numberWithUnsignedInt:inArg2] responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for TransitionLampGroupState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::PulseLampGroupWithState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    AJNMessageArgument* inArg1 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(1))) shouldDeleteHandleOnDealloc:YES];        
        
    AJNMessageArgument* inArg2 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(2))) shouldDeleteHandleOnDealloc:YES];        
        
    uint32_t inArg3 = msg->GetArg(3)->v_uint32;
        
    uint32_t inArg4 = msg->GetArg(4)->v_uint32;
        
    uint32_t inArg5 = msg->GetArg(5)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate pulseLampGroupWithStateWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] fromState:inArg1 toState:inArg2 period:[NSNumber numberWithUnsignedInt:inArg3] duration:[NSNumber numberWithUnsignedInt:inArg4] numPulses:[NSNumber numberWithUnsignedInt:inArg5] responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for PulseLampGroupWithState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::PulseLampGroupWithPreset(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    uint32_t inArg1 = msg->GetArg(1)->v_uint32;
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    uint32_t inArg3 = msg->GetArg(3)->v_uint32;
        
    uint32_t inArg4 = msg->GetArg(4)->v_uint32;
        
    uint32_t inArg5 = msg->GetArg(5)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate pulseLampGroupWithPresetWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] fromPresetID:[NSNumber numberWithUnsignedInt:inArg1] toPresetID:[NSNumber numberWithUnsignedInt:inArg2] period:[NSNumber numberWithUnsignedInt:inArg3] duration:[NSNumber numberWithUnsignedInt:inArg4] numPulses:[NSNumber numberWithUnsignedInt:inArg5] responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for PulseLampGroupWithPreset. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::TransitionLampGroupStateToPreset(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    uint32_t inArg1 = msg->GetArg(1)->v_uint32;
        
    uint32_t inArg2 = msg->GetArg(2)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate transitionLampGroupStateToPresetWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] presetID:[NSNumber numberWithUnsignedInt:inArg1] transitionPeriod:[NSNumber numberWithUnsignedInt:inArg2] responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for TransitionLampGroupStateToPreset. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::TransitionLampGroupStateField(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    qcc::String inArg2 = msg->GetArg(2)->v_string.str;
        
    uint32_t inArg3 = msg->GetArg(3)->v_uint32;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate transitionLampGroupStateFieldWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] groupStateFieldName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] groupStateFieldValue:[NSString stringWithCString:inArg2.c_str() encoding:NSUTF8StringEncoding] transitionPeriod:[NSNumber numberWithUnsignedInt:inArg3] responseCode:&outArg0 lampGroupID:&outArg1 groupStateFieldName:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for TransitionLampGroupStateField. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::ResetLampGroupState(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate resetLampGroupStateWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampGroupID:&outArg1  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[2];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 2);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for ResetLampGroupState. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

void LSFControllerServiceObjectImpl::ResetLampGroupStateField(const InterfaceDescription::Member *member, Message& msg)
{
    @autoreleasepool {
    
    
    
    
    // get all input arguments
    //
    
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
    // declare the output arguments
    //
    
	NSNumber* outArg0;
	NSString* outArg1;
	NSString* outArg2;

    
    // call the Objective-C delegate method
    //
    
	[(id<LSFControllerServiceLampGroupDelegate>)delegate resetLampGroupStateFieldWithLampGroupID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] groupStateFieldName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] responseCode:&outArg0 lampID:&outArg1 groupStateFieldName:&outArg2  message:[[AJNMessage alloc] initWithHandle:&msg]];
            
        
    // formulate the reply
    //
    MsgArg outArgs[3];
    
    outArgs[0].Set("u", [outArg0 unsignedIntValue]);

    outArgs[1].Set("s", [outArg1 UTF8String]);

    outArgs[2].Set("s", [outArg2 UTF8String]);

    QStatus status = MethodReply(msg, outArgs, 3);
    if (ER_OK != status) {
        NSLog(@"ERROR: An error occurred when attempting to send a method reply for ResetLampGroupStateField. %@", [AJNStatus descriptionForStatusCode:status]);
    }        
    
    
    }
}

QStatus LSFControllerServiceObjectImpl::SendLampGroupsNameChanged(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[1];

    
    args[0] = *lampGroupsIDs;
        

    return Signal(destination, sessionId, *LampGroupsNameChangedSignalMember, args, 1, timeToLive, flags);
}


QStatus LSFControllerServiceObjectImpl::SendLampGroupsCreated(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[1];

    
    args[0] = *lampGroupsIDs;
        

    return Signal(destination, sessionId, *LampGroupsCreatedSignalMember, args, 1, timeToLive, flags);
}


QStatus LSFControllerServiceObjectImpl::SendLampGroupsUpdated(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[1];

    
    args[0] = *lampGroupsIDs;
        

    return Signal(destination, sessionId, *LampGroupsUpdatedSignalMember, args, 1, timeToLive, flags);
}


QStatus LSFControllerServiceObjectImpl::SendLampGroupsDeleted(MsgArg* lampGroupsIDs, const char* destination, SessionId sessionId, uint16_t timeToLive, uint8_t flags)
{

    MsgArg args[1];

    args[0] = *lampGroupsIDs;

    return Signal(destination, sessionId, *LampGroupsDeletedSignalMember, args, 1, timeToLive, flags);
}


////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  Objective-C Bus Object implementation for AJNLSFControllerServiceObject
//
////////////////////////////////////////////////////////////////////////////////

@implementation AJNLSFControllerServiceObject

@dynamic handle;

@synthesize ControllerServiceVersion = _ControllerServiceVersion;
@synthesize LampVersion = _LampVersion;
@synthesize LampGroupVersion = _LampGroupVersion;


- (LSFControllerServiceObjectImpl*)busObject
{
    return static_cast<LSFControllerServiceObjectImpl*>(self.handle);
}

- (id)initWithBusAttachment:(AJNBusAttachment *)busAttachment onPath:(NSString *)path
{
    self = [super initWithBusAttachment:busAttachment onPath:path];
    if (self) {
        QStatus status;

        status = ER_OK;
        
        AJNInterfaceDescription *interfaceDescription;
        
    
        //
        // LSFControllerServiceDelegate interface (org.allseen.LSF.ControllerService)
        //
        // create an interface description, or if that fails, get the interface as it was already created
        //
        interfaceDescription = [busAttachment createInterfaceWithName:@"org.allseen.LSF.ControllerService"];

    
        // add the properties to the interface description
        //
    
        status = [interfaceDescription addPropertyWithName:@"Version" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Version (ControllerServiceVersion)" userInfo:nil];
        }
    
        // add the methods to the interface description
        //
    
        status = [interfaceDescription addMethodWithName:@"LightingResetControllerService" inputSignature:@"" outputSignature:@"u" argumentNames:[NSArray arrayWithObjects:@"responseCode", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: LightingResetControllerService" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetControllerServiceVersion" inputSignature:@"" outputSignature:@"u" argumentNames:[NSArray arrayWithObjects:@"version", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetControllerServiceVersion" userInfo:nil];
        }
    
        // add the signals to the interface description
        //
    
        status = [interfaceDescription addSignalWithName:@"ControllerServiceLightingReset" inputSignature:@"" argumentNames:[NSArray arrayWithObjects: nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  ControllerServiceLightingReset" userInfo:nil];
        }
    
    

    
        [interfaceDescription activate];

        //
        // LSFControllerServiceLampDelegate interface (org.allseen.LSF.ControllerService.Lamp)
        //
        // create an interface description, or if that fails, get the interface as it was already created
        //
        interfaceDescription = [busAttachment createInterfaceWithName:@"org.allseen.LSF.ControllerService.Lamp"];

    
        // add the properties to the interface description
        //
    
        status = [interfaceDescription addPropertyWithName:@"Version" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  Version (LampVersion)" userInfo:nil];
        }
    
        // add the methods to the interface description
        //
    
        status = [interfaceDescription addMethodWithName:@"GetAllLampIDs" inputSignature:@"" outputSignature:@"uas" argumentNames:[NSArray arrayWithObjects:@"responseCode",@"lampIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetAllLampIDs" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampSupportedLanguages" inputSignature:@"s" outputSignature:@"usas" argumentNames:[NSArray arrayWithObjects:@"lampID",@"responseCode",@"lampID",@"supportedLanguages", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampSupportedLanguages" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampManufacturer" inputSignature:@"ss" outputSignature:@"usss" argumentNames:[NSArray arrayWithObjects:@"lampID",@"language",@"responseCode",@"lampID",@"language",@"manufacturer", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampManufacturer" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampName" inputSignature:@"ss" outputSignature:@"usss" argumentNames:[NSArray arrayWithObjects:@"lampID",@"language",@"responseCode",@"lampID",@"language",@"lampName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampName" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"SetLampName" inputSignature:@"sss" outputSignature:@"uss" argumentNames:[NSArray arrayWithObjects:@"lampID",@"lampName",@"language",@"responseCode",@"lampID",@"language", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: SetLampName" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampDetails" inputSignature:@"s" outputSignature:@"usa{sv}" argumentNames:[NSArray arrayWithObjects:@"lampID",@"responseCode",@"lampID",@"lampDetails", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampDetails" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampParameters" inputSignature:@"s" outputSignature:@"usa{sv}" argumentNames:[NSArray arrayWithObjects:@"lampID",@"responseCode",@"lampID",@"lampParameters", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampParameters" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampParametersField" inputSignature:@"ss" outputSignature:@"usss" argumentNames:[NSArray arrayWithObjects:@"lampID",@"lampParameterFieldName",@"responseCode",@"lampID",@"lampParameterFieldName",@"lampParameterFieldValue", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampParametersField" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampState" inputSignature:@"s" outputSignature:@"usa{sv}" argumentNames:[NSArray arrayWithObjects:@"lampID",@"responseCode",@"lampID",@"lampState", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampStateField" inputSignature:@"ss" outputSignature:@"usss" argumentNames:[NSArray arrayWithObjects:@"lampID",@"lampStateFieldName",@"responseCode",@"lampID",@"lampStateFieldName",@"lampStateFieldValue", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampStateField" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"TransitionLampState" inputSignature:@"sa{sv}u" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampID",@"lampState",@"transitionPeriod",@"responseCode",@"lampID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: TransitionLampState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"PulseLampWithState" inputSignature:@"sa{sv}a{sv}uuu" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampID",@"fromLampState",@"toLampState",@"period",@"duration",@"numPulses",@"responseCode",@"lampID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: PulseLampWithState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"PulseLampWithPreset" inputSignature:@"suuuuu" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampID",@"fromPresetID",@"toPresetID",@"period",@"duration",@"numPulses",@"responseCode",@"lampID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: PulseLampWithPreset" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"TransitionLampStateToPreset" inputSignature:@"suu" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampID",@"presetID",@"transitionPeriod",@"responseCode",@"lampID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: TransitionLampStateToPreset" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"TransitionLampStateField" inputSignature:@"sssu" outputSignature:@"uss" argumentNames:[NSArray arrayWithObjects:@"lampID",@"lampStateFieldName",@"lampStateFieldValue",@"transitionPeriod",@"responseCode",@"lampID",@"lampStateFieldName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: TransitionLampStateField" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"ResetLampState" inputSignature:@"s" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampID",@"responseCode",@"lampID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: ResetLampState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"ResetLampStateField" inputSignature:@"ss" outputSignature:@"uss" argumentNames:[NSArray arrayWithObjects:@"lampID",@"lampStateFieldName",@"responseCode",@"lampID",@"lampStateFieldName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: ResetLampStateField" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampFaults" inputSignature:@"s" outputSignature:@"usau" argumentNames:[NSArray arrayWithObjects:@"lampID",@"responseCode",@"lampID",@"lampFaults", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampFaults" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"ClearLampFaults" inputSignature:@"su" outputSignature:@"usu" argumentNames:[NSArray arrayWithObjects:@"lampID",@"lampFault",@"responseCode",@"lampID",@"lampFault", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: ClearLampFaults" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampServiceVersion" inputSignature:@"s" outputSignature:@"usu" argumentNames:[NSArray arrayWithObjects:@"lampID",@"responseCode",@"lampID",@"lampServiceVersion", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampServiceVersion" userInfo:nil];
        }
    
        // add the signals to the interface description
        //
    
        status = [interfaceDescription addSignalWithName:@"LampNameChanged" inputSignature:@"ss" argumentNames:[NSArray arrayWithObjects:@"LampID",@"lampName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampNameChanged" userInfo:nil];
        }
    
        status = [interfaceDescription addSignalWithName:@"LampStateChanged" inputSignature:@"ss" argumentNames:[NSArray arrayWithObjects:@"LampID",@"lampName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampStateChanged" userInfo:nil];
        }
    
        status = [interfaceDescription addSignalWithName:@"LampsFound" inputSignature:@"s" argumentNames:[NSArray arrayWithObjects:@"LampID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampsFound" userInfo:nil];
        }
    
        status = [interfaceDescription addSignalWithName:@"LampsLost" inputSignature:@"as" argumentNames:[NSArray arrayWithObjects:@"lampIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampsLost" userInfo:nil];
        }
    
    

    
        [interfaceDescription activate];

        //
        // LSFControllerServiceLampGroupDelegate interface (org.allseen.LSF.ControllerService.LampGroup)
        //
        // create an interface description, or if that fails, get the interface as it was already created
        //
        interfaceDescription = [busAttachment createInterfaceWithName:@"org.allseen.LSF.ControllerService.LampGroup"];

    
        // add the properties to the interface description
        //
    
        status = [interfaceDescription addPropertyWithName:@"LampGroupVersion" signature:@"u"];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add property to interface:  LampGroupVersion" userInfo:nil];
        }
    
        // add the methods to the interface description
        //
    
        status = [interfaceDescription addMethodWithName:@"GetAllLampGroupIDs" inputSignature:@"" outputSignature:@"uas" argumentNames:[NSArray arrayWithObjects:@"responseCode",@"lampGroupIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetAllLampGroupIDs" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampGroupName" inputSignature:@"ss" outputSignature:@"usss" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"language",@"responseCode",@"lampGroupID",@"language",@"lampGroupName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampGroupName" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"SetLampGroupName" inputSignature:@"sss" outputSignature:@"uss" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"lampName",@"language",@"responseCode",@"lampID",@"language", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: SetLampGroupName" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"CreateLampGroup" inputSignature:@"asasss" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampIDs",@"lampGroupIDs",@"lampGroupName",@"language",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: CreateLampGroup" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"UpdateLampGroup" inputSignature:@"sasas" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"lampIDs",@"lampGroupIDs",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: UpdateLampGroup" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"DeleteLampGroup" inputSignature:@"s" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: DeleteLampGroup" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"GetLampGroup" inputSignature:@"s" outputSignature:@"usasas" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"responseCode",@"lampGroupID",@"lampID",@"lampGroupIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: GetLampGroup" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"TransitionLampGroupState" inputSignature:@"sa{sv}u" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"lampState",@"transitionPeriod",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: TransitionLampGroupState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"PulseLampGroupWithState" inputSignature:@"sa{sv}a{sv}uuu" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"fromLampState",@"toLampState",@"period",@"duration",@"numPulses",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: PulseLampGroupWithState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"PulseLampGroupWithPreset" inputSignature:@"suuuuu" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"fromPresetID",@"toPresetID",@"period",@"duration",@"numPulses",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: PulseLampGroupWithPreset" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"TransitionLampGroupStateToPreset" inputSignature:@"suu" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"presetID",@"transitionPeriod",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: TransitionLampGroupStateToPreset" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"TransitionLampGroupStateField" inputSignature:@"sssu" outputSignature:@"uss" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"lampGroupStateFieldName",@"lampGroupStateFieldValue",@"transitionPeriod",@"responseCode",@"lampGroupID",@"lampGroupStateFieldName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: TransitionLampGroupStateField" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"ResetLampGroupState" inputSignature:@"s" outputSignature:@"us" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"responseCode",@"lampGroupID", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: ResetLampGroupState" userInfo:nil];
        }
    
        status = [interfaceDescription addMethodWithName:@"ResetLampGroupStateField" inputSignature:@"ss" outputSignature:@"uss" argumentNames:[NSArray arrayWithObjects:@"lampGroupID",@"lampGroupStateFieldName",@"responseCode",@"lampGroupID",@"lampGroupStateFieldName", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add method to interface: ResetLampGroupStateField" userInfo:nil];
        }
    
        // add the signals to the interface description
        //
    
        status = [interfaceDescription addSignalWithName:@"LampGroupsNameChanged" inputSignature:@"s" argumentNames:[NSArray arrayWithObjects:@"lampGroupsIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampGroupsNameChanged" userInfo:nil];
        }
    
        status = [interfaceDescription addSignalWithName:@"LampGroupsCreated" inputSignature:@"s" argumentNames:[NSArray arrayWithObjects:@"lampGroupsIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampGroupsCreated" userInfo:nil];
        }
    
        status = [interfaceDescription addSignalWithName:@"LampGroupsUpdated" inputSignature:@"s" argumentNames:[NSArray arrayWithObjects:@"lampGroupsIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampGroupsUpdated" userInfo:nil];
        }
    
        status = [interfaceDescription addSignalWithName:@"LampGroupsDeleted" inputSignature:@"as" argumentNames:[NSArray arrayWithObjects:@"lampGroupsIDs", nil]];
        
        if (status != ER_OK && status != ER_BUS_MEMBER_ALREADY_EXISTS) {
            @throw [NSException exceptionWithName:@"BusObjectInitFailed" reason:@"Unable to add signal to interface:  LampGroupsDeleted" userInfo:nil];
        }
    
    

    
        [interfaceDescription activate];


        // create the internal C++ bus object
        //
        LSFControllerServiceObjectImpl *busObject = new LSFControllerServiceObjectImpl(*((ajn::BusAttachment*)busAttachment.handle), [path UTF8String], (id<LSFControllerServiceDelegate, LSFControllerServiceLampDelegate, LSFControllerServiceLampGroupDelegate>)self);
        
        self.handle = busObject;
        
      
    }
    return self;
}

- (void)dealloc
{
    LSFControllerServiceObjectImpl *busObject = [self busObject];
    delete busObject;
    self.handle = nil;
}

    
- (NSNumber*)lightingResetControllerService:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (NSNumber*)getControllerServiceVersion:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getAllLampIDsWithResponseCode:(NSNumber**)responseCode lampIDs:(AJNMessageArgument**)lampIDs message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampSupportedLangueagesWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut supportedLanguages:(AJNMessageArgument**)supportedLanguages message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampManufacturerWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut manufacturer:(NSString**)manufacturer message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampNameWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut lampName:(NSString**)lampName message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)setLampNameWithLampID:(NSString*)lampID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampDetailsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampDetails:(AJNMessageArgument**)lampDetails message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampParametersWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampParameters:(AJNMessageArgument**)lampParameters message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampParametersFieldWithLampID:(NSString*)lampID parameterFieldName:(NSString*)lampParameterFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut parameterFieldName:(NSString**)lampParameterFieldNameOut parameterFieldValue:(NSString**)lampParameterFieldValue message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampState:(AJNMessageArgument**)lampState message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut stateFieldValue:(NSString**)lampStateFieldValue message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)transitionLampStateWithLampID:(NSString*)lampID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)pulseLampWithStateWithLampID:(NSString*)lampID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)pulseLampWithPresetWithLampID:(NSString*)lampID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)transitionLampStateToPresetWithLampID:(NSString*)lampID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)transitionLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName stateFieldValue:(NSString*)lampStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampStateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)resetLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)resetLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampFaultsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFaults:(AJNMessageArgument**)lampFaults message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)clearLampFaultsWithLampID:(NSString*)lampID lampFault:(NSNumber*)lampFault responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFault:(NSNumber**)lampFaultOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampServiceVersionWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut version:(NSNumber**)lampServiceVersion message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getAllLampGroupIDsWithResponseCode:(NSNumber**)responseCode lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampGroupNameWithLampGroupID:(NSString*)lampGroupID language:(NSString*)language responseCode:(NSNumber**)responseCode lampIDGroupID:(NSString**)lampGroupIDOut language:(NSString**)languageOut lampGroupName:(NSString**)lampGroupName message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)setLampGroupNameWithLampID:(NSString*)lampGroupID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampID language:(NSString**)languageOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)createLampGroupWithLampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs lampGroupName:(NSString*)lampGroupName language:(NSString*)language responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupID message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)updateLampGroupWithLampGroupID:(NSString*)lampGroupID lampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)deleteLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)getLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut lampID:(AJNMessageArgument**)lampID lampGroupIDs:(AJNMessageArgument**)lampGroupIDs message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)transitionLampGroupStateWithLampGroupID:(NSString*)lampGroupID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)pulseLampGroupWithStateWithLampGroupID:(NSString*)lampGroupID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)pulseLampGroupWithPresetWithLampGroupID:(NSString*)lampGroupID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)transitionLampGroupStateToPresetWithLampGroupID:(NSString*)lampGroupID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)transitionLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName groupStateFieldValue:(NSString*)lampGroupStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)resetLampGroupStateWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)resetLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut message:(AJNMessage *)methodCallMessage
{
    //
    // GENERATED CODE - DO NOT EDIT
    //
    // Create a category or subclass in separate .h/.m files
    @throw([NSException exceptionWithName:@"NotImplementedException" reason:@"You must override this method in a subclass" userInfo:nil]);
}

- (void)sendControllerServiceLightingResetInSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendControllerServiceLightingReset([destinationPath UTF8String], sessionId);
        
}
- (void)sendlampNameDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampNameChanged([LampID UTF8String], [lampName UTF8String], [destinationPath UTF8String], sessionId);
        
}
- (void)sendlampStateDidChangeForLampID:(NSString*)LampID lampName:(NSString*)lampName inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampStateChanged([LampID UTF8String], [lampName UTF8String], [destinationPath UTF8String], sessionId);
        
}
- (void)senddidFindLamp:(NSString*)LampID inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampsFound([LampID UTF8String], [destinationPath UTF8String], sessionId);
        
}
- (void)senddidLoseLamps:(AJNMessageArgument*)lampIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampsLost([lampIDs msgArg], [destinationPath UTF8String], sessionId);
        
}
- (void)sendlampGroupNamesDidChangeForLampGroupIDs:(AJNMessageArgument*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampGroupsNameChanged([lampGroupsIDs msgArg], [destinationPath UTF8String], sessionId);
        
}
- (void)senddidCreateLampGroups:(AJNMessageArgument*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampGroupsCreated([lampGroupsIDs msgArg], [destinationPath UTF8String], sessionId);
        
}
- (void)senddidUpdateLampGroups:(AJNMessageArgument*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampGroupsUpdated([lampGroupsIDs msgArg], [destinationPath UTF8String], sessionId);
        
}
- (void)senddidDeleteLampGroups:(AJNMessageArgument*)lampGroupsIDs inSession:(AJNSessionId)sessionId toDestination:(NSString*)destinationPath

{
    
    self.busObject->SendLampGroupsDeleted([lampGroupsIDs msgArg], [destinationPath UTF8String], sessionId);
        
}

    
@end

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  Objective-C Proxy Bus Object implementation for LSFControllerServiceObject
//
////////////////////////////////////////////////////////////////////////////////

@interface LSFControllerServiceObjectProxy(Private)

@property (nonatomic, strong) AJNBusAttachment *bus;

- (ProxyBusObject*)proxyBusObject;

@end

@implementation LSFControllerServiceObjectProxy
    
- (NSNumber*)ControllerServiceVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.ControllerService", "Version", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Version (ControllerServiceVersion) on interface org.allseen.LSF.ControllerService. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)LampVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.ControllerService.Lamp", "Version", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property Version (LampVersion) on interface org.allseen.LSF.ControllerService.Lamp. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)LampGroupVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    
    MsgArg propValue;
    
    QStatus status = self.proxyBusObject->GetProperty("org.allseen.LSF.ControllerService.LampGroup", "LampGroupVersion", propValue);

    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to get property LampGroupVersion on interface org.allseen.LSF.ControllerService.LampGroup. %@", [AJNStatus descriptionForStatusCode:status]);
    }

    
    return [NSNumber numberWithUnsignedInt:propValue.v_variant.val->v_uint32];
        
}
    
- (NSNumber*)lightingResetControllerService
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[0];
    

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService", "LightingResetControllerService", inArgs, 0, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return nil;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    return [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        

}

- (NSNumber*)getControllerServiceVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[0];
    

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService", "GetControllerServiceVersion", inArgs, 0, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return nil;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    return [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        

}

- (void)getAllLampIDsWithResponseCode:(NSNumber**)responseCode lampIDs:(AJNMessageArgument**)lampIDs
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[0];
    

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetAllLampIDs", inArgs, 0, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
    
    *lampIDs = [[AJNMessageArgument alloc]
                initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(1)))
                shouldDeleteHandleOnDealloc:YES];
        

}

- (void)getLampSupportedLangueagesWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut supportedLanguages:(AJNMessageArgument**)supportedLanguages
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampSupportedLanguages", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
    
    *supportedLanguages =
    [[AJNMessageArgument alloc]
     initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(2)))
     shouldDeleteHandleOnDealloc:YES];
    

}

- (void)getLampManufacturerWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut manufacturer:(NSString**)manufacturer
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("s", [language UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampManufacturer", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *languageOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        
    *manufacturer = [NSString stringWithCString:reply->GetArg(3)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)getLampNameWithLampID:(NSString*)lampID language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut lampName:(NSString**)lampName
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("s", [language UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampName", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *languageOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampName = [NSString stringWithCString:reply->GetArg(3)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)setLampNameWithLampID:(NSString*)lampID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut language:(NSString**)languageOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("s", [lampName UTF8String]);
        
    inArgs[2].Set("s", [language UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "SetLampName", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *languageOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)getLampDetailsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampDetails:(AJNMessageArgument**)lampDetails
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampDetails", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
    
    *lampDetails = [[AJNMessageArgument alloc]
                    initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(2)))
                    shouldDeleteHandleOnDealloc:YES];
        

}

- (void)getLampParametersWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampParameters:(AJNMessageArgument**)lampParameters
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampParameters", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
    
    *lampParameters = [[AJNMessageArgument alloc]
                       initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(2)))
                       shouldDeleteHandleOnDealloc:YES];
        

}

- (void)getLampParametersFieldWithLampID:(NSString*)lampID parameterFieldName:(NSString*)lampParameterFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut parameterFieldName:(NSString**)lampParameterFieldNameOut parameterFieldValue:(NSString**)lampParameterFieldValue
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("s", [lampParameterFieldName UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampParametersField", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampParameterFieldNameOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampParameterFieldValue = [NSString stringWithCString:reply->GetArg(3)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)getLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampState:(AJNMessageArgument**)lampState
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampState", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
    
    *lampState = [[AJNMessageArgument alloc]
                  initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(2)))
                  shouldDeleteHandleOnDealloc:YES];
    

}

- (void)getLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut stateFieldValue:(NSString**)lampStateFieldValue
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("s", [lampStateFieldName UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampStateField", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampStateFieldNameOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampStateFieldValue = [NSString stringWithCString:reply->GetArg(3)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)transitionLampStateWithLampID:(NSString*)lampID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1] = *[lampState msgArg];
        
    inArgs[2].Set("u", [transitionPeriod unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "TransitionLampState", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)pulseLampWithStateWithLampID:(NSString*)lampID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[6];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1] = *[fromLampState msgArg];
        
    inArgs[2] = *[toLampState msgArg];
        
    inArgs[3].Set("u", [period unsignedIntValue]);
        
    inArgs[4].Set("u", [duration unsignedIntValue]);
        
    inArgs[5].Set("u", [numPulses unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "PulseLampWithState", inArgs, 6, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)pulseLampWithPresetWithLampID:(NSString*)lampID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[6];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("u", [fromPresetID unsignedIntValue]);
        
    inArgs[2].Set("u", [toPresetID unsignedIntValue]);
        
    inArgs[3].Set("u", [period unsignedIntValue]);
        
    inArgs[4].Set("u", [duration unsignedIntValue]);
        
    inArgs[5].Set("u", [numPulses unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "PulseLampWithPreset", inArgs, 6, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)transitionLampStateToPresetWithLampID:(NSString*)lampID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("u", [presetID unsignedIntValue]);
        
    inArgs[2].Set("u", [transitionPeriod unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "TransitionLampStateToPreset", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)transitionLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName stateFieldValue:(NSString*)lampStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampStateFieldName:(NSString**)lampStateFieldNameOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[4];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("s", [lampStateFieldName UTF8String]);
        
    inArgs[2].Set("s", [lampStateFieldValue UTF8String]);
        
    inArgs[3].Set("u", [transitionPeriod unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "TransitionLampStateField", inArgs, 4, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampStateFieldNameOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)resetLampStateWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "ResetLampState", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)resetLampStateFieldWithLampID:(NSString*)lampID stateFieldName:(NSString*)lampStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut stateFieldName:(NSString**)lampStateFieldNameOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("s", [lampStateFieldName UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "ResetLampStateField", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampStateFieldNameOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)getLampFaultsWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFaults:(AJNMessageArgument**)lampFaults
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampFaults", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
    
    *lampFaults = [[AJNMessageArgument alloc]
                   initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(2)))
                   shouldDeleteHandleOnDealloc:YES];
        

}

- (void)clearLampFaultsWithLampID:(NSString*)lampID lampFault:(NSNumber*)lampFault responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut lampFault:(NSNumber**)lampFaultOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        
    inArgs[1].Set("u", [lampFault unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "ClearLampFaults", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampFaultOut = [NSNumber numberWithUnsignedInt:reply->GetArg(2)->v_uint32];
        

}

- (void)getLampServiceVersionWithLampID:(NSString*)lampID responseCode:(NSNumber**)responseCode lampID:(NSString**)lampIDOut version:(NSNumber**)lampServiceVersion
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.Lamp"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.Lamp", "GetLampServiceVersion", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.Lamp failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampServiceVersion = [NSNumber numberWithUnsignedInt:reply->GetArg(2)->v_uint32];
        

}

- (void)getAllLampGroupIDsWithResponseCode:(NSNumber**)responseCode lampGroupIDs:(AJNMessageArgument**)lampGroupIDs
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[0];
    

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "GetAllLampGroupIDs", inArgs, 0, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
    
    *lampGroupIDs = [[AJNMessageArgument alloc]
                     initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(1)))
                     shouldDeleteHandleOnDealloc:YES];

}

- (void)getLampGroupNameWithLampGroupID:(NSString*)lampGroupID language:(NSString*)language responseCode:(NSNumber**)responseCode lampIDGroupID:(NSString**)lampGroupIDOut language:(NSString**)languageOut lampGroupName:(NSString**)lampGroupName
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1].Set("s", [language UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "GetLampGroupName", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *languageOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampGroupName = [NSString stringWithCString:reply->GetArg(3)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)setLampGroupNameWithLampID:(NSString*)lampGroupID lampName:(NSString*)lampName language:(NSString*)language responseCode:(NSNumber**)responseCode lampID:(NSString**)lampID language:(NSString**)languageOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1].Set("s", [lampName UTF8String]);
        
    inArgs[2].Set("s", [language UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "SetLampGroupName", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampID = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *languageOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)createLampGroupWithLampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs lampGroupName:(NSString*)lampGroupName language:(NSString*)language responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupID
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[4];
    
    inArgs[0] = *[lampIDs msgArg];
        
    inArgs[1] = *[lampGroupIDs msgArg];
        
    inArgs[2].Set("s", [lampGroupName UTF8String]);
        
    inArgs[3].Set("s", [language UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "CreateLampGroup", inArgs, 4, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupID = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)updateLampGroupWithLampGroupID:(NSString*)lampGroupID lampIDs:(AJNMessageArgument*)lampIDs lampGroupIDs:(AJNMessageArgument*)lampGroupIDs responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1] = *[lampIDs msgArg];
        
    inArgs[2] = *[lampGroupIDs msgArg];
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "UpdateLampGroup", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)deleteLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "DeleteLampGroup", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)getLampGroupWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut lampID:(AJNMessageArgument**)lampID lampGroupIDs:(AJNMessageArgument**)lampGroupIDs
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "GetLampGroup", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
    
    *lampID = [[AJNMessageArgument alloc]
               initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(2)))
               shouldDeleteHandleOnDealloc:YES];
    
    *lampGroupIDs = [[AJNMessageArgument alloc]
                     initWithHandle:(AJNHandle)new MsgArg(*(reply->GetArg(3)))
                     shouldDeleteHandleOnDealloc:YES];

}

- (void)transitionLampGroupStateWithLampGroupID:(NSString*)lampGroupID lampState:(AJNMessageArgument*)lampState transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1] = *[lampState msgArg];
        
    inArgs[2].Set("u", [transitionPeriod unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "TransitionLampGroupState", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)pulseLampGroupWithStateWithLampGroupID:(NSString*)lampGroupID fromState:(AJNMessageArgument*)fromLampState toState:(AJNMessageArgument*)toLampState period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[6];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1] = *[fromLampState msgArg];
        
    inArgs[2] = *[toLampState msgArg];
        
    inArgs[3].Set("u", [period unsignedIntValue]);
        
    inArgs[4].Set("u", [duration unsignedIntValue]);
        
    inArgs[5].Set("u", [numPulses unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "PulseLampGroupWithState", inArgs, 6, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)pulseLampGroupWithPresetWithLampGroupID:(NSString*)lampGroupID fromPresetID:(NSNumber*)fromPresetID toPresetID:(NSNumber*)toPresetID period:(NSNumber*)period duration:(NSNumber*)duration numPulses:(NSNumber*)numPulses responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[6];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1].Set("u", [fromPresetID unsignedIntValue]);
        
    inArgs[2].Set("u", [toPresetID unsignedIntValue]);
        
    inArgs[3].Set("u", [period unsignedIntValue]);
        
    inArgs[4].Set("u", [duration unsignedIntValue]);
        
    inArgs[5].Set("u", [numPulses unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "PulseLampGroupWithPreset", inArgs, 6, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)transitionLampGroupStateToPresetWithLampGroupID:(NSString*)lampGroupID presetID:(NSNumber*)presetID transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[3];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1].Set("u", [presetID unsignedIntValue]);
        
    inArgs[2].Set("u", [transitionPeriod unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "TransitionLampGroupStateToPreset", inArgs, 3, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)transitionLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName groupStateFieldValue:(NSString*)lampGroupStateFieldValue transitionPeriod:(NSNumber*)transitionPeriod responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[4];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1].Set("s", [lampGroupStateFieldName UTF8String]);
        
    inArgs[2].Set("s", [lampGroupStateFieldValue UTF8String]);
        
    inArgs[3].Set("u", [transitionPeriod unsignedIntValue]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "TransitionLampGroupStateField", inArgs, 4, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampGroupStateFieldNameOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)resetLampGroupStateWithLampGroupID:(NSString*)lampGroupID responseCode:(NSNumber**)responseCode lampGroupID:(NSString**)lampGroupIDOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[1];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "ResetLampGroupState", inArgs, 1, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        

}

- (void)resetLampGroupStateFieldWithLampGroupID:(NSString*)lampGroupID groupStateFieldName:(NSString*)lampGroupStateFieldName responseCode:(NSNumber**)responseCode lampID:(NSString**)lampGroupIDOut groupStateFieldName:(NSString**)lampGroupStateFieldNameOut
{
    [self addInterfaceNamed:@"org.allseen.LSF.ControllerService.LampGroup"];
    
    // prepare the input arguments
    //
    
    Message reply(*((BusAttachment*)self.bus.handle));    
    MsgArg inArgs[2];
    
    inArgs[0].Set("s", [lampGroupID UTF8String]);
        
    inArgs[1].Set("s", [lampGroupStateFieldName UTF8String]);
        

    // make the function call using the C++ proxy object
    //
    
    QStatus status = self.proxyBusObject->MethodCall("org.allseen.LSF.ControllerService.LampGroup", "ResetLampGroupStateField", inArgs, 2, reply, 5000);
    if (ER_OK != status) {
        NSLog(@"ERROR: ProxyBusObject::MethodCall on org.allseen.LSF.ControllerService.LampGroup failed. %@", [AJNStatus descriptionForStatusCode:status]);
        
        return;
            
    }

    
    // pass the output arguments back to the caller
    //
    
        
    *responseCode = [NSNumber numberWithUnsignedInt:reply->GetArg()->v_uint32];
        
    *lampGroupIDOut = [NSString stringWithCString:reply->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        
    *lampGroupStateFieldNameOut = [NSString stringWithCString:reply->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        

}

@end

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//  C++ Signal Handler implementation for LSFControllerServiceDelegate
//
////////////////////////////////////////////////////////////////////////////////

class LSFControllerServiceDelegateSignalHandlerImpl : public AJNSignalHandlerImpl
{
private:

    const ajn::InterfaceDescription::Member* ControllerServiceLightingResetSignalMember;
    void ControllerServiceLightingResetSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    
public:
    /**
     * Constructor for the AJN signal handler implementation.
     *
     * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
     */    
    LSFControllerServiceDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate);
    
    virtual void RegisterSignalHandler(ajn::BusAttachment &bus);
    
    virtual void UnregisterSignalHandler(ajn::BusAttachment &bus);
    
    /**
     * Virtual destructor for derivable class.
     */
    virtual ~LSFControllerServiceDelegateSignalHandlerImpl();
};


/**
 * Constructor for the AJN signal handler implementation.
 *
 * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
 */    
LSFControllerServiceDelegateSignalHandlerImpl::LSFControllerServiceDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate) : AJNSignalHandlerImpl(aDelegate)
{
	ControllerServiceLightingResetSignalMember = NULL;

}

LSFControllerServiceDelegateSignalHandlerImpl::~LSFControllerServiceDelegateSignalHandlerImpl()
{
    m_delegate = NULL;
}

void LSFControllerServiceDelegateSignalHandlerImpl::RegisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal ControllerServiceLightingReset
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService");

    if (interface) {
        // Store the ControllerServiceLightingReset signal member away so it can be quickly looked up
        ControllerServiceLightingResetSignalMember = interface->GetMember("ControllerServiceLightingReset");
        assert(ControllerServiceLightingResetSignalMember);

        
        // Register signal handler for ControllerServiceLightingReset
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceDelegateSignalHandlerImpl::ControllerServiceLightingResetSignalHandler),
            ControllerServiceLightingResetSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

}

void LSFControllerServiceDelegateSignalHandlerImpl::UnregisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal ControllerServiceLightingReset
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService");
    
    // Store the ControllerServiceLightingReset signal member away so it can be quickly looked up
    ControllerServiceLightingResetSignalMember = interface->GetMember("ControllerServiceLightingReset");
    assert(ControllerServiceLightingResetSignalMember);
    
    // Unregister signal handler for ControllerServiceLightingReset
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceDelegateSignalHandlerImpl::ControllerServiceLightingResetSignalHandler),
        ControllerServiceLightingResetSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

}


void LSFControllerServiceDelegateSignalHandlerImpl::ControllerServiceLightingResetSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received ControllerServiceLightingReset signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceDelegateSignalHandler>)m_delegate didReceiveControllerServiceLightingResetInSession:sessionId message:signalMessage];
                
        });
        
    }
}


@implementation AJNBusAttachment(LSFControllerServiceDelegate)

- (void)registerLSFControllerServiceDelegateSignalHandler:(id<LSFControllerServiceDelegateSignalHandler>)signalHandler
{
    LSFControllerServiceDelegateSignalHandlerImpl *signalHandlerImpl = new LSFControllerServiceDelegateSignalHandlerImpl(signalHandler);
    signalHandler.handle = signalHandlerImpl;
    [self registerSignalHandler:signalHandler];
}

@end

////////////////////////////////////////////////////////////////////////////////
    
////////////////////////////////////////////////////////////////////////////////
//
//  C++ Signal Handler implementation for LSFControllerServiceLampDelegate
//
////////////////////////////////////////////////////////////////////////////////

class LSFControllerServiceLampDelegateSignalHandlerImpl : public AJNSignalHandlerImpl
{
private:

    const ajn::InterfaceDescription::Member* LampNameChangedSignalMember;
    void LampNameChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    const ajn::InterfaceDescription::Member* LampStateChangedSignalMember;
    void LampStateChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    const ajn::InterfaceDescription::Member* LampsFoundSignalMember;
    void LampsFoundSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    const ajn::InterfaceDescription::Member* LampsLostSignalMember;
    void LampsLostSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    
public:
    /**
     * Constructor for the AJN signal handler implementation.
     *
     * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
     */    
    LSFControllerServiceLampDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate);
    
    virtual void RegisterSignalHandler(ajn::BusAttachment &bus);
    
    virtual void UnregisterSignalHandler(ajn::BusAttachment &bus);
    
    /**
     * Virtual destructor for derivable class.
     */
    virtual ~LSFControllerServiceLampDelegateSignalHandlerImpl();
};


/**
 * Constructor for the AJN signal handler implementation.
 *
 * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
 */    
LSFControllerServiceLampDelegateSignalHandlerImpl::LSFControllerServiceLampDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate) : AJNSignalHandlerImpl(aDelegate)
{
	LampNameChangedSignalMember = NULL;
	LampStateChangedSignalMember = NULL;
	LampsFoundSignalMember = NULL;
	LampsLostSignalMember = NULL;

}

LSFControllerServiceLampDelegateSignalHandlerImpl::~LSFControllerServiceLampDelegateSignalHandlerImpl()
{
    m_delegate = NULL;
}

void LSFControllerServiceLampDelegateSignalHandlerImpl::RegisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampNameChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");

    if (interface) {
        // Store the LampNameChanged signal member away so it can be quickly looked up
        LampNameChangedSignalMember = interface->GetMember("LampNameChanged");
        assert(LampNameChangedSignalMember);

        
        // Register signal handler for LampNameChanged
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampNameChangedSignalHandler),
            LampNameChangedSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.Lamp not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampStateChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");

    if (interface) {
        // Store the LampStateChanged signal member away so it can be quickly looked up
        LampStateChangedSignalMember = interface->GetMember("LampStateChanged");
        assert(LampStateChangedSignalMember);

        
        // Register signal handler for LampStateChanged
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampStateChangedSignalHandler),
            LampStateChangedSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.Lamp not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampsFound
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");

    if (interface) {
        // Store the LampsFound signal member away so it can be quickly looked up
        LampsFoundSignalMember = interface->GetMember("LampsFound");
        assert(LampsFoundSignalMember);

        
        // Register signal handler for LampsFound
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampsFoundSignalHandler),
            LampsFoundSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.Lamp not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampsLost
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");

    if (interface) {
        // Store the LampsLost signal member away so it can be quickly looked up
        LampsLostSignalMember = interface->GetMember("LampsLost");
        assert(LampsLostSignalMember);

        
        // Register signal handler for LampsLost
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampsLostSignalHandler),
            LampsLostSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.Lamp not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

}

void LSFControllerServiceLampDelegateSignalHandlerImpl::UnregisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampNameChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");
    
    // Store the LampNameChanged signal member away so it can be quickly looked up
    LampNameChangedSignalMember = interface->GetMember("LampNameChanged");
    assert(LampNameChangedSignalMember);
    
    // Unregister signal handler for LampNameChanged
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampNameChangedSignalHandler),
        LampNameChangedSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampStateChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");
    
    // Store the LampStateChanged signal member away so it can be quickly looked up
    LampStateChangedSignalMember = interface->GetMember("LampStateChanged");
    assert(LampStateChangedSignalMember);
    
    // Unregister signal handler for LampStateChanged
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampStateChangedSignalHandler),
        LampStateChangedSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampsFound
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");
    
    // Store the LampsFound signal member away so it can be quickly looked up
    LampsFoundSignalMember = interface->GetMember("LampsFound");
    assert(LampsFoundSignalMember);
    
    // Unregister signal handler for LampsFound
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampsFoundSignalHandler),
        LampsFoundSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampsLost
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.Lamp");
    
    // Store the LampsLost signal member away so it can be quickly looked up
    LampsLostSignalMember = interface->GetMember("LampsLost");
    assert(LampsLostSignalMember);
    
    // Unregister signal handler for LampsLost
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampDelegateSignalHandlerImpl::LampsLostSignalHandler),
        LampsLostSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

}


void LSFControllerServiceLampDelegateSignalHandlerImpl::LampNameChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampNameChanged signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampDelegateSignalHandler>)m_delegate didReceivelampNameDidChangeForLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] inSession:sessionId message:signalMessage];
                
        });
        
    }
}

void LSFControllerServiceLampDelegateSignalHandlerImpl::LampStateChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
    qcc::String inArg1 = msg->GetArg(1)->v_string.str;
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampStateChanged signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampDelegateSignalHandler>)m_delegate didReceivelampStateDidChangeForLampID:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] lampName:[NSString stringWithCString:inArg1.c_str() encoding:NSUTF8StringEncoding] inSession:sessionId message:signalMessage];
                
        });
        
    }
}

void LSFControllerServiceLampDelegateSignalHandlerImpl::LampsFoundSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampsFound signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampDelegateSignalHandler>)m_delegate didReceivedidFindLamp:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] inSession:sessionId message:signalMessage];
                
        });
        
    }
}

void LSFControllerServiceLampDelegateSignalHandlerImpl::LampsLostSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    AJNMessageArgument* inArg0 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(0))) shouldDeleteHandleOnDealloc:YES];        
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampsLost signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampDelegateSignalHandler>)m_delegate didReceivedidLoseLamps:inArg0 inSession:sessionId message:signalMessage];
                
        });
        
    }
}


@implementation AJNBusAttachment(LSFControllerServiceLampDelegate)

- (void)registerLSFControllerServiceLampDelegateSignalHandler:(id<LSFControllerServiceLampDelegateSignalHandler>)signalHandler
{
    LSFControllerServiceLampDelegateSignalHandlerImpl *signalHandlerImpl = new LSFControllerServiceLampDelegateSignalHandlerImpl(signalHandler);
    signalHandler.handle = signalHandlerImpl;
    [self registerSignalHandler:signalHandler];
}

@end

////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////
//
//  C++ Signal Handler implementation for LSFControllerServiceLampGroupDelegate
//
////////////////////////////////////////////////////////////////////////////////

class LSFControllerServiceLampGroupDelegateSignalHandlerImpl : public AJNSignalHandlerImpl
{
private:

    const ajn::InterfaceDescription::Member* LampGroupsNameChangedSignalMember;
    void LampGroupsNameChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    const ajn::InterfaceDescription::Member* LampGroupsCreatedSignalMember;
    void LampGroupsCreatedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    const ajn::InterfaceDescription::Member* LampGroupsUpdatedSignalMember;
    void LampGroupsUpdatedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    const ajn::InterfaceDescription::Member* LampGroupsDeletedSignalMember;
    void LampGroupsDeletedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);

    
public:
    /**
     * Constructor for the AJN signal handler implementation.
     *
     * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
     */    
    LSFControllerServiceLampGroupDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate);
    
    virtual void RegisterSignalHandler(ajn::BusAttachment &bus);
    
    virtual void UnregisterSignalHandler(ajn::BusAttachment &bus);
    
    /**
     * Virtual destructor for derivable class.
     */
    virtual ~LSFControllerServiceLampGroupDelegateSignalHandlerImpl();
};


/**
 * Constructor for the AJN signal handler implementation.
 *
 * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.     
 */    
LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LSFControllerServiceLampGroupDelegateSignalHandlerImpl(id<AJNSignalHandler> aDelegate) : AJNSignalHandlerImpl(aDelegate)
{
	LampGroupsNameChangedSignalMember = NULL;
	LampGroupsCreatedSignalMember = NULL;
	LampGroupsUpdatedSignalMember = NULL;
	LampGroupsDeletedSignalMember = NULL;

}

LSFControllerServiceLampGroupDelegateSignalHandlerImpl::~LSFControllerServiceLampGroupDelegateSignalHandlerImpl()
{
    m_delegate = NULL;
}

void LSFControllerServiceLampGroupDelegateSignalHandlerImpl::RegisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampGroupsNameChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");

    if (interface) {
        // Store the LampGroupsNameChanged signal member away so it can be quickly looked up
        LampGroupsNameChangedSignalMember = interface->GetMember("LampGroupsNameChanged");
        assert(LampGroupsNameChangedSignalMember);

        
        // Register signal handler for LampGroupsNameChanged
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsNameChangedSignalHandler),
            LampGroupsNameChangedSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampGroupDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.LampGroup not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampGroupsCreated
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");

    if (interface) {
        // Store the LampGroupsCreated signal member away so it can be quickly looked up
        LampGroupsCreatedSignalMember = interface->GetMember("LampGroupsCreated");
        assert(LampGroupsCreatedSignalMember);

        
        // Register signal handler for LampGroupsCreated
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsCreatedSignalHandler),
            LampGroupsCreatedSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampGroupDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.LampGroup not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampGroupsUpdated
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");

    if (interface) {
        // Store the LampGroupsUpdated signal member away so it can be quickly looked up
        LampGroupsUpdatedSignalMember = interface->GetMember("LampGroupsUpdated");
        assert(LampGroupsUpdatedSignalMember);

        
        // Register signal handler for LampGroupsUpdated
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsUpdatedSignalHandler),
            LampGroupsUpdatedSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampGroupDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.LampGroup not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Register signal handler for signal LampGroupsDeleted
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");

    if (interface) {
        // Store the LampGroupsDeleted signal member away so it can be quickly looked up
        LampGroupsDeletedSignalMember = interface->GetMember("LampGroupsDeleted");
        assert(LampGroupsDeletedSignalMember);

        
        // Register signal handler for LampGroupsDeleted
        status =  bus.RegisterSignalHandler(this,
            static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsDeletedSignalHandler),
            LampGroupsDeletedSignalMember,
            NULL);
            
        if (status != ER_OK) {
            NSLog(@"ERROR: Interface LSFControllerServiceLampGroupDelegateSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
        }
    }
    else {
        NSLog(@"ERROR: org.allseen.LSF.ControllerService.LampGroup not found.");
    }
    ////////////////////////////////////////////////////////////////////////////    

}

void LSFControllerServiceLampGroupDelegateSignalHandlerImpl::UnregisterSignalHandler(ajn::BusAttachment &bus)
{
    QStatus status;
    status = ER_OK;
    const ajn::InterfaceDescription* interface = NULL;
    
    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampGroupsNameChanged
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");
    
    // Store the LampGroupsNameChanged signal member away so it can be quickly looked up
    LampGroupsNameChangedSignalMember = interface->GetMember("LampGroupsNameChanged");
    assert(LampGroupsNameChangedSignalMember);
    
    // Unregister signal handler for LampGroupsNameChanged
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsNameChangedSignalHandler),
        LampGroupsNameChangedSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampGroupDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampGroupsCreated
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");
    
    // Store the LampGroupsCreated signal member away so it can be quickly looked up
    LampGroupsCreatedSignalMember = interface->GetMember("LampGroupsCreated");
    assert(LampGroupsCreatedSignalMember);
    
    // Unregister signal handler for LampGroupsCreated
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsCreatedSignalHandler),
        LampGroupsCreatedSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampGroupDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampGroupsUpdated
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");
    
    // Store the LampGroupsUpdated signal member away so it can be quickly looked up
    LampGroupsUpdatedSignalMember = interface->GetMember("LampGroupsUpdated");
    assert(LampGroupsUpdatedSignalMember);
    
    // Unregister signal handler for LampGroupsUpdated
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsUpdatedSignalHandler),
        LampGroupsUpdatedSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampGroupDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

    ////////////////////////////////////////////////////////////////////////////
    // Unregister signal handler for signal LampGroupsDeleted
    //
    interface = bus.GetInterface("org.allseen.LSF.ControllerService.LampGroup");
    
    // Store the LampGroupsDeleted signal member away so it can be quickly looked up
    LampGroupsDeletedSignalMember = interface->GetMember("LampGroupsDeleted");
    assert(LampGroupsDeletedSignalMember);
    
    // Unregister signal handler for LampGroupsDeleted
    status =  bus.UnregisterSignalHandler(this,
        static_cast<MessageReceiver::SignalHandler>(&LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsDeletedSignalHandler),
        LampGroupsDeletedSignalMember,
        NULL);
        
    if (status != ER_OK) {
        NSLog(@"ERROR:LSFControllerServiceLampGroupDelegateSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
    ////////////////////////////////////////////////////////////////////////////    

}


void LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsNameChangedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampGroupsNameChanged signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampGroupDelegateSignalHandler>)m_delegate didReceivelampGroupNamesDidChangeForLampGroupIDs:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] inSession:sessionId message:signalMessage];
                
        });
        
    }
}

void LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsCreatedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampGroupsCreated signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampGroupDelegateSignalHandler>)m_delegate didReceivedidCreateLampGroups:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] inSession:sessionId message:signalMessage];
                
        });
        
    }
}

void LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsUpdatedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    qcc::String inArg0 = msg->GetArg(0)->v_string.str;
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampGroupsUpdated signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampGroupDelegateSignalHandler>)m_delegate didReceivedidUpdateLampGroups:[NSString stringWithCString:inArg0.c_str() encoding:NSUTF8StringEncoding] inSession:sessionId message:signalMessage];
                
        });
        
    }
}

void LSFControllerServiceLampGroupDelegateSignalHandlerImpl::LampGroupsDeletedSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        
    AJNMessageArgument* inArg0 = [[AJNMessageArgument alloc] initWithHandle:(AJNHandle)new MsgArg(*(msg->GetArg(0))) shouldDeleteHandleOnDealloc:YES];        
        
        AJNMessage *signalMessage = [[AJNMessage alloc] initWithHandle:&msg];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
        AJNSessionId sessionId = msg->GetSessionId();        
        NSLog(@"Received LampGroupsDeleted signal from %@ on path %@ for session id %u [%s > %s]", [signalMessage senderName], objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [(id<LSFControllerServiceLampGroupDelegateSignalHandler>)m_delegate didReceivedidDeleteLampGroups:inArg0 inSession:sessionId message:signalMessage];
                
        });
        
    }
}


@implementation AJNBusAttachment(LSFControllerServiceLampGroupDelegate)

- (void)registerLSFControllerServiceLampGroupDelegateSignalHandler:(id<LSFControllerServiceLampGroupDelegateSignalHandler>)signalHandler
{
    LSFControllerServiceLampGroupDelegateSignalHandlerImpl *signalHandlerImpl = new LSFControllerServiceLampGroupDelegateSignalHandlerImpl(signalHandler);
    signalHandler.handle = signalHandlerImpl;
    [self registerSignalHandler:signalHandler];
}

@end

////////////////////////////////////////////////////////////////////////////////
    