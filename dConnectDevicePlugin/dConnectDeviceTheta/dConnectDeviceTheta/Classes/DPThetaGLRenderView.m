//
//  DPThetaGLRenderView.m
//  dConnectDeviceTheta
//
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
#import "DPThetaGLRenderView.h"
#import "DPThetaUVSphere.h"


static NSString *vertexShader = @""
    "attribute vec4 aPosition;\n"
    "attribute vec2 aUV;\n"
    "uniform mat4 uProjection;\n"
    "uniform mat4 uView;\n"
    "uniform mat4 uModel;\n"
    "varying vec2 vUV;\n"
    "void main() {\n"
    "  gl_Position = uProjection * uView * uModel * aPosition;\n"
    "  vUV = aUV;\n"
    "}\n";
static NSString *fragmentShader = @""
    "precision mediump float;\n"
    "varying vec2 vUV;\n"
    "uniform sampler2D uTex;\n"
    "void main() {\n"
    "  gl_FragColor = texture2D(uTex, vUV);\n"
    "}\n";


static float const DPThetaDefaultTextureShellRadius = 1.0f;
static int const DPThetaShellDivides = 40;
static float const DPThetaZNear = 0.1f;
static float const DPThetaZFar = 1000.f;


@interface DPThetaGLRenderView (){
    DPThetaUVSphere *shell;

    float viewAspectRatio;
    
    GLKMatrix4 projectionMatrix;
    GLKMatrix4 lookAtMatrix;
    GLKMatrix4 modelMatrix;
    
    GLuint shaderProgram;
    GLint aPosition;
    GLint aUV;
    GLuint name;
    GLint uProjection;
    GLint uView;
    GLint uModel;
    GLint uTex;
    
    GLKTextureInfo *mTextureInfo;
    
    
    DPThetaVector3D *defaultCameraDirection;
    
    BOOL textureUpdate;
}

// opengl shader and program
-(GLuint) loadShader:(GLenum)shaderType shaderSrc:(NSString *)shaderSrc;
-(GLuint) loadProgram:(NSString*)vShaderSrc fShaderSrc:(NSString*)fShaderSrc;
-(void) useAndAttachLocation:(GLuint)program;

-(void) glCheckError:(NSString *)msg;

@end

@implementation DPThetaGLRenderView


-(id) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    

    projectionMatrix = GLKMatrix4Identity;
    lookAtMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Identity;
    
    textureUpdate = NO;
    
    _camera = [[DPThetaCamera alloc] init];
    defaultCameraDirection = [[DPThetaVector3D alloc] initWithX:1.0f y:0.0f z:0.0f];
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    
    if (self) {
        [self initOpenGLSettings:context];
        shell = [[DPThetaUVSphere alloc] init:DPThetaDefaultTextureShellRadius
                                       divide:DPThetaShellDivides];
    }
    return self;
}



-(void) setTexture:(NSData*)data {
    
    NSError *error;
    
    
    mTextureInfo = [GLKTextureLoader textureWithContentsOfData:data options:nil error:&error];
    name = mTextureInfo.name;

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, name);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    
    return;
}


-(void) initOpenGLSettings:(EAGLContext*)context{

    float viewWidth = self.frame.size.width;
    float viewHeight = self.frame.size.height;
    
    shaderProgram = [self loadProgram:vertexShader fShaderSrc:fragmentShader];
    [self useAndAttachLocation: shaderProgram];

    //NSLog(@"frame width: %d hegith: %d", (int)self.frame.size.width, (int)self.frame.size.height);
    
    glClearColor(0.0f, 0.0f, 1.0f, 0.0f);
    
    viewAspectRatio = viewWidth/viewHeight;
    glViewport(0, 0, viewWidth, viewHeight);
    
    return;
}

-(void) draw{
    projectionMatrix = GLKMatrix4Identity;
    lookAtMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Identity;
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    float x = [_camera.position x];
    float y = [_camera.position y];
    float z = [_camera.position z];
    float frontX = [_camera.frontDirection x];
    float frontY = [_camera.frontDirection y];
    float frontZ = [_camera.frontDirection z];
    float upX = [_camera.upperDirection x];
    float upY = [_camera.upperDirection y];
    float upZ = [_camera.upperDirection z];
   lookAtMatrix = GLKMatrix4MakeLookAt(x, y, z,
                                        frontX, frontY, frontZ,
                                        upX, upY, upZ);
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_camera.fovDegree), [self getScreenAspect],
                                                 DPThetaZNear, DPThetaZFar);

    glEnableVertexAttribArray(aPosition);
    glEnableVertexAttribArray(aUV);
    
    glUniformMatrix4fv(uModel, 1, GL_FALSE, modelMatrix.m);
    [self glCheckError:@"glUniform4fv model"];
    glUniformMatrix4fv(uView, 1, GL_FALSE, lookAtMatrix.m);
    [self glCheckError:@"glUniform4fv viewmatrix"];
    glUniformMatrix4fv(uProjection, 1, GL_FALSE, projectionMatrix.m);
    [self glCheckError:@"glUniform4fv projectionmatrix"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, name);
    
    glUniform1i(uTex, 0);
    
    [shell draw:aPosition uv:aUV];
    
    glDisableVertexAttribArray(aPosition);
    glDisableVertexAttribArray(aUV);
}

- (float) getScreenAspect
{
    return (float) _screenWidth / (float) (_screenHeight == 0 ? 1 : _screenHeight);
}


-(GLuint) loadShader:(GLenum)shaderType shaderSrc:(NSString *)shaderSrc {

    GLuint shader;
    GLint compiled;
    const char* shaderRealSrc = [shaderSrc cStringUsingEncoding:NSUTF8StringEncoding];
    
    shader = glCreateShader(shaderType);
    if (0 == shader) {
        return 0;
    }
    
    glShaderSource(shader, 1, &shaderRealSrc, NULL);
    glCompileShader(shader);
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    
    if (!compiled) {
        
        GLint infoLen = 0;
        
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:\n%s\n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}



-(GLuint) loadProgram:(NSString*)vShaderSrc fShaderSrc:(NSString*)fShaderSrc {
    
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint program;
    GLint linked;
    
    // load the vertex shader
    vertexShader = [self loadShader:GL_VERTEX_SHADER shaderSrc:vShaderSrc];
    if (vertexShader == 0) {
        return 0;
    }
    // load fragment shader
    fragmentShader = [self loadShader:GL_FRAGMENT_SHADER shaderSrc:fShaderSrc];
    if (fragmentShader == 0) {
        glDeleteShader(vertexShader);
        return 0;
    }
    
    // create the program object
    program = glCreateProgram();
    if (program == 0) {
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        return 0;
    }
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    // link the program
    glLinkProgram(program);
    
    // check the link status
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (!linked) {
        
        GLint infoLen = 0;
        
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc (sizeof(char) * infoLen);
            
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);
            NSLog(@"Error linking program:\n%s\n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(program);
        return 0;
    }
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return program;
}


-(void) useAndAttachLocation:(GLuint) program {
    
    glUseProgram(program);
    [self glCheckError:@"glUseProgram"];

    aPosition = glGetAttribLocation(program, "aPosition");
    [self glCheckError:@"glGetAttribLocation position"];
    aUV = glGetAttribLocation(program, "aUV");
    [self glCheckError:@"glGetAttribLocation uv"];
    
    uProjection = glGetUniformLocation(program, "uProjection");
    [self glCheckError:@"glGetUniformLocation projection"];
    uView = glGetUniformLocation(program, "uView");
    [self glCheckError:@"glGetUniformLocation view"];
    uModel = glGetUniformLocation(program, "uModel");
    [self glCheckError:@"glGetUniformLocation model"];
    uTex = glGetUniformLocation(program, "uTex");
    [self glCheckError:@"glGetUniformLocation texture"];
    
    return;
}


-(void) glCheckError:(NSString *) msg {
    GLenum error;
    
    while (GL_NO_ERROR != (error = glGetError())) {
        NSLog(@"GLERR: %d %@¥n", error, msg);
    }
    
    return;
}

- (void)setSphereRadius:(float)radius
{
    if (radius != shell.radius
        && (DPThetaZNear < radius && DPThetaZFar > radius)) {
        shell = [[DPThetaUVSphere alloc] init:radius divide:DPThetaShellDivides];
    }
}

- (void)rotateCameraWithQuaterion:(DPThetaQuaternion *)quaternion
{
    DPThetaCameraBuilder *builder = [[DPThetaCameraBuilder alloc] initWithCamera:_camera];
    [builder rotateForQuaternion:quaternion];
    _camera = (DPThetaCamera *) [builder create];
}
@end
