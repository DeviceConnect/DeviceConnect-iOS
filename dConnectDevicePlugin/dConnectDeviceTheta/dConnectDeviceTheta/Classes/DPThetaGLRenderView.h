//
//  DPThetaGLRenderView.h
//  dConnectDeviceTheta
//
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

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

-(void) setTexture:(NSData*)data;

- (void)setSphereRadius:(float)radius;
- (void)rotateCameraWithQuaterion:(DPThetaQuaternion *)quaternion;
@end

