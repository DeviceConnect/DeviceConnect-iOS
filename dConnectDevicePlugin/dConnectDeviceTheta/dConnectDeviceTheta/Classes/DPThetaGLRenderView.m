/*
 * Copyright Ricoh Company, Ltd. All rights reserved.
 */

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
#import "DPThetaGLRenderView.h"
#import "DPThetaUVSphere.h"
/** Camera FOV initial value */
#define CAMERA_FOV_DEGREE_INIT          (45.0f)
/** Camera FOV minimum value */
#define CAMERA_FOV_DEGREE_MIN           (30.0f)
/** Camera FOV maximum value */
#define CAMERA_FOV_DEGREE_MAX           (100.0f)
/** Z/NEAR for OpenGL perspective display */
#define Z_NEAR                          (0.1f)
/** Z/FA for OpenGL perspective display */
#define Z_FAR                           (100.0f)

/** Spherical radius for photo attachment */
#define SHELL_RADIUS                    (2.0f)
/** Number of spherical polygon partitions for photo attachment */
#define SHELL_DIVIDE                    (48)

/** Parameter for amount of rotation control (X axis) */
#define DIVIDE_ROTATE_X                 (500)
/** Parameter for amount of rotation control (Y axis) */
#define DIVIDE_ROTATE_Y                 (500)

/** Parameter for maximum width control */
#define SCALE_RATIO_TICK_EXPANSION      (1.05f)
/** Parameter for minimum width control */
#define SCALE_RATIO_TICK_REDUCTION      (0.95f)

#define KNUM_INTERVAL_INERTIA           (0.020)
#define INERTIA_1ST_SHORT_ADJUST(a)     (a / 3.0)
#define INERTIA_1ST_LONG_ADJUST(a)      (a / 2.0)
#define INERTIA_LONG_ADJUST(a)          (1.4 + a * 0.1)
#define INERTIA_SHORT_ADJUST(a)         (2.9 + a * 0.1)
#define INERTIA_NONE                    (1.0)
#define INERTIA_STOP_LIMT               (0.000002)

/** Amount of movement parameter for inertia (weak) */
#define WEAK_INERTIA_RATIO              (1.0)
/** Amount of movement parameter for inertia (strong) */
#define STRONG_INERTIA_RATIO            (10.0)

#define KSTR_NONE_INERTIA           @"none"
#define KSTR_SHORT_INERTIA          @"weak"
#define KSTR_LONG_INERTIA           @"strong"

#define KINT_HIGHT_INTERVAL_BUTTON  54

typedef enum : int {
    NoneInertia = 0,
    ShortInertia,
    LongInertia
} enumInertia;


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


/**
 * View class for photo spherical display
 *
 * Images acquired from the cameras on each side of the RICOH THETA are combined as
 * camera #2 (left half) + camera1 + camera #2 (right half) using equirectangular projection.
 * These images are acquired at a fixed resolution of 2048 x 1024.
 *
 * These images are pasted as texture onto a spherical object on OpenGL using UVSphere
 * from this class.  As this sphere is drawn at an angle from -pi to pi on the xz plane,
 * the UV coordinates are generated in this orientation and attached to the image, 
 * and are attached so that a mirror image is not generated in the x axis direction
 * when viewed from the inside of the sphere.
 * 
 * Furthermore, as the camera image is from angle -pi, the center of the image captured by
 * camera #1 faces forward from the x axis. The camera image is slanted at the angle of elevation
 * and horizontal angle, the sphere is rotated at each angle, and the image displayed in the x axis
 * forward direction is adjusted to the horizontal direction of the image from camera#1.
 *
 * Pinch and pan operations support zooming in, zooming out and rotating. These are supported by
 * changing the camera slant and FOV angle setting value.
 */
@interface DPThetaGLRenderView (){
    DPThetaUVSphere *shell;

    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;

    float _yaw;
    float _roll;
    float _pitch;
    NSTimer *_timer;
    uint _timerCount;
    int _kindInertia;
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
    
    float cameraPosX;
    float cameraPosY;
    float cameraPosZ;
    float cameraDirectionX;
    float cameraDirectionY;
    float cameraDirectionZ;
    float cameraUpX;
    float cameraUpY;
    float cameraUpZ;
    
    float cameraFovDegree;
    
    double mRotationAngleXZ;
    double mRotationAngleY;
    
    BOOL inPanMode;
    CGPoint panPrev;
    int panLastDiffX;
    int panLastDiffY;
    double inertiaRatio;
    
    DPThetaVector3D *defaultCameraDirection;
    
    BOOL textureUpdate;
}

// opengl shader and program
-(GLuint) loadShader:(GLenum)shaderType shaderSrc:(NSString *)shaderSrc;
-(GLuint) loadProgram:(NSString*)vShaderSrc fShaderSrc:(NSString*)fShaderSrc;
-(void) useAndAttachLocation:(GLuint)program;

-(void) glCheckError:(NSString *)msg;

// gesture operations
-(void) scale:(float) scale;
-(void) rotate:(int) diffx diffy:(int) diffy;
@end

@implementation DPThetaGLRenderView

/**
 * Startup method
 * @param frame Size on screen
 */
-(id) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    _timerCount = 0;
    _timer = nil;
    _kindInertia = NoneInertia;

    projectionMatrix = GLKMatrix4Identity;
    lookAtMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Identity;
    
    // set initial camera pos and direction
    cameraPosX = 0.0f;
    cameraPosY = 0.0f;
    cameraPosZ = 0.0f;
    cameraDirectionX = 1.0f;
    cameraDirectionY = 0.0f;
    cameraDirectionZ = 0.0f;
    cameraUpX = 0.0f;
    cameraUpY = 1.0f;
    cameraUpZ = 0.0f;
    textureUpdate = NO;
    
    cameraFovDegree = CAMERA_FOV_DEGREE_INIT;
    _camera = [[DPThetaCamera alloc] init];
    defaultCameraDirection = [[DPThetaVector3D alloc] initWithX:1.0f y:0.0f z:0.0f];
    
    inPanMode = NO;

    mRotationAngleXZ = 0.0f;
    mRotationAngleY = 0.0f;
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    self.context = context;
    
    if (self) {
//        [self registerGestures];
        [self initOpenGLSettings:context];
        shell = [[DPThetaUVSphere alloc] init:SHELL_RADIUS divide:SHELL_DIVIDE];
    }
    return self;
}


/**
 * Gesture registration method
 */
-(void) registerGestures{

    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panGestureRecognizer];
    
    pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureHandler:)];
    [self addGestureRecognizer:pinchGestureRecognizer];

    return;
}

/**
 * Texture registration method
 * @param data Image for registration
 * @param width Image width for registration
 * @param height Image height for registration
 * @param yaw Camera orientation angle
 * @param pitch Camera elevation angle
 * @param roll Camera horizontal angle
 */
-(void) setTexture:(NSData*)data yaw:(float)yaw pitch:(float) pitch roll:(float) roll {
    
    NSError *error;
    
    
    mTextureInfo = [GLKTextureLoader textureWithContentsOfData:data options:nil error:&error];
    name = mTextureInfo.name;

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, name);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    _yaw = yaw;
    _roll = roll;
    _pitch = pitch;
    
    return;
}

/**
 * Rotation inertia value setting method
 * @param kind Inertia value
 */
-(void) setInertia:(int) kind   {
    _kindInertia = kind;
}

/**
 * OpenGL Initial value setting method
 * @param context OpenGL Context
 */
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

/**
 * Redraw method
 */
-(void) draw{
    projectionMatrix = GLKMatrix4Identity;
    lookAtMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Identity;
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
    // before
//    cameraDirectionX = (float) (cos(mRotationAngleXZ)*cos(mRotationAngleY));
//    cameraDirectionZ = (float) (sin(mRotationAngleXZ)*cos(mRotationAngleY));
//    cameraDirectionY = (float) sin(mRotationAngleY);
//    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(cameraFovDegree), viewAspectRatio, Z_NEAR, Z_FAR);
//    lookAtMatrix = GLKMatrix4MakeLookAt(cameraPosX, cameraPosY, cameraPosZ,
//                                        cameraDirectionX, cameraDirectionY, cameraDirectionZ,
//                                        cameraUpX, cameraUpY, cameraUpZ);

    float x = [_camera.position x];
    float y = [_camera.position y];
    float z = [_camera.position z];
    float frontX = [_camera.frontDirection x];
    float frontY = [_camera.frontDirection y];
    float frontZ = [_camera.frontDirection z];
    float upX = [_camera.upperDirection x];
    float upY = [_camera.upperDirection y];
    float upZ = [_camera.upperDirection z];
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_camera.fovDegree), [self getScreenAspect],
                                                 DPThetaZNear, DPThetaZFar);
    lookAtMatrix = GLKMatrix4MakeLookAt(x, y, z,
                                        frontX, frontY, frontZ,
                                        upX, upY, upZ);
    
    
    
    
    GLKMatrix4 elevetionAngleMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_pitch), 0, 0, 1);
    modelMatrix = GLKMatrix4Multiply(modelMatrix, elevetionAngleMatrix);
    GLKMatrix4 horizontalAngleMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_roll), 1, 0, 0);
    modelMatrix = GLKMatrix4Multiply(modelMatrix, horizontalAngleMatrix);
    
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

/**
 * Method for creating OpenGL shader
 *
 * @param @shaderType Shader type
 * @param @shaderSrc Shader source
 */
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


/**
 * Program creation function for OpenGL
 * @param vShaderSrc Vertex shader source
 * @param fShaderSrc Fragment shader source
 */
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

/**
 * Program validation and various shader variable validation methods for OpenGL
 * @param program OpenGL Program variable
 */
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

/**
 * OpenGL Method for OpenGL error detection
 * @param Output character string at detection
 */
-(void) glCheckError:(NSString *) msg {
    GLenum error;
    
    while (GL_NO_ERROR != (error = glGetError())) {
        NSLog(@"GLERR: %d %@¥n", error, msg);
    }
    
    return;
}

- (void)setSphereRadius:(float)radius
{
    if (radius != shell.radius) {
        shell = [[DPThetaUVSphere alloc] init:radius divide:SHELL_DIVIDE];
    }
}

- (void)rotateCameraWithQuaterion:(DPThetaQuaternion *)quaternion
{
    DPThetaCameraBuilder *builder = [[DPThetaCameraBuilder alloc] initWithCamera:_camera];
    [builder rotateForQuaternion:quaternion];
    _camera = [builder create];
}
@end
