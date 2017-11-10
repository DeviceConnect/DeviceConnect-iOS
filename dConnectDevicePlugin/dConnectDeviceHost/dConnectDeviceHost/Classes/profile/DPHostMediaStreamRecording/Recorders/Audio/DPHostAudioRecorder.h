//
//  DPHostAudioRecorder.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <AVFoundation/AVFoundation.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DPHostStreamRecorder.h"

@interface DPHostAudioRecorder : DPHostStreamRecorder<AVCaptureAudioDataOutputSampleBufferDelegate,
                                                        AVCaptureVideoDataOutputSampleBufferDelegate>
@end
