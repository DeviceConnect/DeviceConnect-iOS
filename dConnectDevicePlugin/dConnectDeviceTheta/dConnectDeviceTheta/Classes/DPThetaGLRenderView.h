/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
#import "DPThetaROI.h"

@interface DPThetaGLRenderView : GLKView
@property (nonatomic) DPThetaCamera *camera;
@property (nonatomic) int screenWidth;
@property (nonatomic) int screenHeight;

-(id) initWithFrame:(CGRect)frame;

-(void) draw;

-(void) setTexture:(NSData*)data yaw:(float)yaw pitch:(float)pitch roll:(float)roll;
-(void) setInertia:(int)kind;

- (void)setSphereRadius:(float)radius;
- (void)rotateCameraWithQuaterion:(DPThetaQuaternion *)quaternion;
@end

