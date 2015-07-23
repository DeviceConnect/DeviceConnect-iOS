//
//  DPAllJoynConst.mm
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynConst.h"


// Interestingly, NSArray can be initialized at compile time in Objective-C++.
// NOTE: Maybe these nonprimitive constants should be initialized inside a class.

NSArray *const DPAllJoynSingleLampInterfaceSet =
  @[
    // AllJoyn Lighting service framework, Lamp service
    @"org.allseen.LSF.LampDetails"
    , @"org.allseen.LSF.LampParameters"
    , @"org.allseen.LSF.LampService"
    , @"org.allseen.LSF.LampState"
    ];
NSArray *const DPAllJoynLampControllerInterfaceSet =
  @[
    //                    // AllJoyn Lighting service framework, Controller Service
    @"org.allseen.LSF.ControllerService"
    , @"org.allseen.LSF.ControllerService.Lamp"
    //                    , @"org.allseen.LSF.ControllerService.LampGroup"
    //                    , @"org.allseen.LSF.ControllerService.Preset"
    //                    , @"org.allseen.LSF.ControllerService.Scene"
    //                    , @"org.allseen.LSF.ControllerService.MasterScene"
    //                    , @"org.allseen.LeaderElectionAndStateSync"
    ];
NSArray *const DPAllJoynSupportedInterfaceSets =
  @[
    DPAllJoynSingleLampInterfaceSet
    , DPAllJoynLampControllerInterfaceSet
    ];
