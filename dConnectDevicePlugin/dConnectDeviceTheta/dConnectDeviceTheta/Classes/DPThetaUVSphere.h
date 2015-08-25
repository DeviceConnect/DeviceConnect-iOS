/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

#ifndef ricoh_theta_sample_for_ios_UVSphere_h
#define ricoh_theta_sample_for_ios_UVSphere_h

@interface DPThetaUVSphere : NSObject
@property (nonatomic) float radius;

-(id) init:(GLfloat)radius divide:(int) divide;

-(void) draw:(GLint) posLocation uv:(GLint) uvLocation;

@end

#endif
