//
//  DPThetaUVSphere.h
//  dConnectDeviceTheta
//
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>

#ifndef ricoh_theta_sample_for_ios_UVSphere_h
#define ricoh_theta_sample_for_ios_UVSphere_h

@interface DPThetaUVSphere : NSObject
@property (nonatomic) float radius;

-(id) init:(GLfloat)radius divide:(int) divide;

-(void) draw:(GLint) posLocation uv:(GLint) uvLocation;

@end

#endif
