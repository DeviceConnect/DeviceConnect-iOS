//
//  DPThetaOmnidirectionalImageProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaOmnidirectionalImageProfile.h"
#import "DPThetaROI.h"


@interface DPThetaOmnidirectionalImageProfile()
@property (nonatomic) DPThetaMixedReplaceMediaServer *server;
@property (nonatomic) NSMutableDictionary *roiContexts;
@property (nonatomic) NSMutableDictionary *omniImages;
@end

@implementation DPThetaOmnidirectionalImageProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        _omniImages = [NSMutableDictionary new];
        _roiContexts = [NSMutableDictionary new];
        _server = [DPThetaMixedReplaceMediaServer new];
    }
    return self;
}

- (BOOL)                     profile:(DPOmnidirectionalImageProfile *)profile
             didReceiveGetRoiRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                              source:(NSString *)source
{
    return [self requestViewWithRequest:request
                               response:response
                              serviceId:serviceId
                                 source:source
                                  isGet:YES];
}

- (BOOL)                     profile:(DPOmnidirectionalImageProfile *)profile
             didReceivePutRoiRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                              source:(NSString *)source
{
    return [self requestViewWithRequest:request
                               response:response
                              serviceId:serviceId
                                 source:source
                                  isGet:NO];
}

- (BOOL)                     profile:(DPOmnidirectionalImageProfile *)profile
     didReceivePutRoiSettingsRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
{
    NSString *uri = [self omitParametersWithUri:[request stringForKey:DPOmnidirectionalImageProfileParamURI]];
    DPThetaRoiDeliveryContext *roiContext = _roiContexts[uri];
    if (!roiContext) {
        [response setErrorToInvalidRequestParameterWithMessage:@"The specified media is not found."];
        return YES;
    }
    [response setResult:DConnectMessageResultTypeOk];
    DPThetaParam *param = [self getParamForRequest:request];
    [roiContext changeRenderParameter:param isUserRequest:YES];
    return YES;
}



- (BOOL)                     profile:(DPOmnidirectionalImageProfile *)profile
          didReceiveDeleteRoiRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                                 uri:(NSString *)uri
{
    DPThetaRoiDeliveryContext *roiContext = _roiContexts[[self omitParametersWithUri:uri]];
    if (roiContext) {
        [_roiContexts removeObjectForKey:[self omitParametersWithUri:uri]];
        if ([_server isRunning]) {
            [_server startStopServer];
        }
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:@"The specified media is not found."];
    }
    return YES;
}


#pragma mark - private method

- (BOOL)requestViewWithRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
                        source:(NSString *)source
                         isGet:(BOOL)isGet
{
    if (![_server isRunning]) {
        [_server startStopServer];
    }
    __block DPThetaOmnidirectionalImage *omniImage = _omniImages[source];
    if (!omniImage) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *origin = [bundle bundleIdentifier];
        NSString *uri = [self omitParametersWithUri:source];
        NSRange range = [[uri stringByRemovingPercentEncoding] rangeOfString:@"file://"];
        NSUInteger index = range.location;

        if (index != NSNotFound) {
            omniImage = [DPThetaOmnidirectionalImage new];
            NSString *path = [[[uri stringByRemovingPercentEncoding]
                                stringByReplacingOccurrencesOfString:@"uri=file://" withString:@""]
                                stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            NSData* imageData = [NSData dataWithContentsOfFile:path];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            omniImage.image = imageData;

        } else {
            NSURL *url = [NSURL URLWithString:source];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 500);
            dispatch_async(dispatch_get_main_queue(), ^{
                omniImage = [[DPThetaOmnidirectionalImage alloc] initWithURL:url origin:origin callback:^() {
                    dispatch_semaphore_signal(semaphore);
                }];
            });
            dispatch_semaphore_wait(semaphore, timeout);
        }
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 500);
    DPThetaRoiDeliveryContext *roiContext = [[DPThetaRoiDeliveryContext alloc] initWithSource:omniImage callback:^{
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, timeout);

    NSString *segment = [[NSUUID UUID] UUIDString];
    NSString *uri = [NSString stringWithFormat:@"%@/%@", [_server getUrl], segment];
    roiContext.uri = [NSURL URLWithString:uri];
    roiContext.segment = segment;
    roiContext.delegate = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [roiContext changeRenderParameter:[[DPThetaParam alloc] init] isUserRequest:YES];
    });
    _roiContexts[uri] = roiContext;
    [response setResult:DConnectMessageResultTypeOk];
    if (isGet) {
        [response setString:[NSString stringWithFormat:@"%@?snapshot", uri] forKey:DPOmnidirectionalImageProfileParamURI];
    } else {
        [response setString:uri forKey:DPOmnidirectionalImageProfileParamURI];
    }
    [[DConnectManager sharedManager] sendResponse:response];

    return NO;
}


- (NSString*)omitParametersWithUri:(NSString*)uri
{
    NSRange range = [uri rangeOfString:@"?"];
    NSUInteger index = range.location;
    if (index != NSNotFound) {
        NSString *param = [uri substringFromIndex:index + 1];
        NSLog(@"substring uri: %@", param);
        return param;
    }
    return uri;
}


- (DPThetaParam *)getParamForRequest:(DConnectRequestMessage *)request
{
    double x = [request doubleForKey:DPOmnidirectionalImageProfileParamX];
    double y = [request doubleForKey:DPOmnidirectionalImageProfileParamY];
    double z = [request doubleForKey:DPOmnidirectionalImageProfileParamZ];
    double yaw = [request doubleForKey:DPOmnidirectionalImageProfileParamYaw];
    double roll = [request doubleForKey:DPOmnidirectionalImageProfileParamRoll];
    double pitch = [request doubleForKey:DPOmnidirectionalImageProfileParamPitch];
    double fov = [request doubleForKey:DPOmnidirectionalImageProfileParamFOV];
    double sphereSize = [request doubleForKey:DPOmnidirectionalImageProfileParamSphereSize];
    int width = [request integerForKey:DPOmnidirectionalImageProfileParamWidth];
    int height = [request integerForKey:DPOmnidirectionalImageProfileParamHeight];
    BOOL stereo = [request boolForKey:DPOmnidirectionalImageProfileParamStereo];
    BOOL vr = [request boolForKey:DPOmnidirectionalImageProfileParamVR];
    NSString *stereoString = [request stringForKey:DPOmnidirectionalImageProfileParamStereo];
    NSString *vrString = [request stringForKey:DPOmnidirectionalImageProfileParamVR];
    if (stereoString && [stereoString isEqualToString:@"true"]) {
        stereo = YES;
    } else {
        stereo = NO;
    }
    if (vrString && [vrString isEqualToString:@"true"]) {
        vr = YES;
    } else {
        vr = NO;
    }
    DPThetaParam *param = [[DPThetaParam alloc] init];
    param.vrMode = vr;
    param.stereoMode = stereo;
    param.cameraX = x;
    param.cameraY = y;
    param.cameraZ = z;
    param.cameraRoll = roll;
    param.cameraPitch = pitch;
    param.cameraYaw = yaw;
    param.cameraFOV = fov;
    param.sphereSize = sphereSize;
    param.imageWidth = width;
    param.imageHeight = height;
    return param;
}



#pragma mark - delegate method

-(void)didUpdateMediaWithSegment:(NSString*)segment data:(NSData *)data
{
    [_server offerMediaWithData:data segment:segment];
}

- (void)didConnectForUri:(NSString*)uri
{
    
}

- (void)didDisconnectForUri:(NSString*)uri
{
    
}



- (void)didCloseServer
{
    
}

@end
