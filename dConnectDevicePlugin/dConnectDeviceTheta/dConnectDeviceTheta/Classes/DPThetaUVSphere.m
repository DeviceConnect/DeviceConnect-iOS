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
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKTextureLoader.h>
#import "DPThetaUVSphere.h"

@interface DPThetaUVSphere (){
    
    GLfloat **vertexArray;
    GLfloat **texCoordsArray;
    int mDivide;
}

@end

@implementation DPThetaUVSphere

-(id) init:(GLfloat)radius divide:(int)divide {

    int i;
    int j;
    double altitude;
    double altitudeDelta;
    double azimuth;
    _radius = radius;
    if((self = [super init])){
        
        mDivide = divide;

        vertexArray = malloc(sizeof(GLfloat *)*mDivide);
        texCoordsArray = malloc(sizeof(GLfloat *)*mDivide);
        
        for(i = 0; i < (mDivide/2); i++){

            altitude      = M_PI/2.0 - ( i ) * (M_PI*2/mDivide);
            altitudeDelta = M_PI/2.0 - (i+1) * (M_PI*2/mDivide);

            GLfloat *vertices = malloc(sizeof(GLfloat)*(mDivide*6+6));
            GLfloat *texCoords = malloc(sizeof(GLfloat)*(mDivide*4+4));
            
            for(j = 0; j <= mDivide; j++){
                
                azimuth = M_PI - ((float)j) * (2*M_PI/(float)(mDivide));

                // 1st point
                vertices[j*6+3] = radius * cos(altitudeDelta) * cos(azimuth);
                vertices[j*6+4] = radius * sin(altitudeDelta);
                vertices[j*6+5] = radius * cos(altitudeDelta) * sin(azimuth);
                
                texCoords[j*4+2] =  1.0 - (j / (float)(mDivide));
                texCoords[j*4+3] =  2*(i + 1) / (float)(mDivide);
                
                // 2nd point
                vertices[j*6+0] = radius * cos(altitude) * cos(azimuth);
                vertices[j*6+1] = radius * sin(altitude);
                vertices[j*6+2] = radius * cos(altitude) * sin(azimuth);
                
                texCoords[j*4+0] =  1.0 - (j / (float)(mDivide));
                texCoords[j*4+1] =  2*(i + 0) / (float)(mDivide);

            }
            
            vertexArray[i] = vertices;
            texCoordsArray[i] = texCoords;
        }
    }
    return self;
}


-(void) draw:(GLint) posLocation uv:(GLint) uvLocation {
    
    GLfloat *vertices;
    GLfloat *texCoords;
    
    for (int i = 0; i < (mDivide/2); i++) {
        vertices = vertexArray[i];
        texCoords = texCoordsArray[i];
        
        glVertexAttribPointer(posLocation, 3, GL_FLOAT, false, 0, vertices);
        glVertexAttribPointer(uvLocation, 2, GL_FLOAT, false, 0, texCoords);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, mDivide*2+2);
    }
    
    return;
}


@end