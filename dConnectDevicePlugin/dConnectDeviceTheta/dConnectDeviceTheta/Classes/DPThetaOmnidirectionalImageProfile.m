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
#import "DPThetaManager.h"


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
        _omniImages = [[NSMutableDictionary alloc] initWithCapacity:0];
        _roiContexts = [[NSMutableDictionary alloc] initWithCapacity:0];
        _server = [DPThetaMixedReplaceMediaServer new];
        _server.delegate = self;
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
    NSString *uri = [DPThetaManager omitParametersToUri:[request stringForKey:DPOmnidirectionalImageProfileParamURI]];
    DPThetaRoiDeliveryContext *roiContext = _roiContexts[uri];
    if (!roiContext) {
        [response setErrorToInvalidRequestParameterWithMessage:@"The specified media is not found."];
        return YES;
    }
    
    if (![self correctParamsWithRequest:request
                               response:response]) {
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
    NSString *url = [DPThetaManager omitParametersToUri:uri];
    DPThetaRoiDeliveryContext *roiContext = _roiContexts[url];
    if (roiContext) {
        [roiContext destroy];
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", [_server getUrl]] withString:@""];
        [_server stopMediaForSegment:url];
        [_roiContexts removeObjectForKey:url];
        
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
    if (!source) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Non exist Source"];
        return YES;
    }
    
    
    if (![_server isRunning]) {
        [_server startStopServer];
    }
    __block DPThetaOmnidirectionalImage *omniImage = _omniImages[source];
    if (!omniImage) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *origin = [bundle bundleIdentifier];
        NSString *uri = [DPThetaManager omitParametersFromUri:source];
        NSRange range = [[uri stringByRemovingPercentEncoding] rangeOfString:@"file://"];
        NSUInteger index = range.location;

        if (index != NSNotFound) {
            omniImage = [DPThetaOmnidirectionalImage new];
            NSString *path = [[[uri stringByRemovingPercentEncoding]
                                stringByReplacingOccurrencesOfString:@"uri=file://" withString:@""]
                                stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            NSData* imageData = [NSData dataWithContentsOfFile:path];
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
        NSString  *res = [[NSString alloc] initWithData:omniImage.image encoding:NSJapaneseEUCStringEncoding];
        
        if ([res isEqualToString:@"No valid api was detected in URL."]) {
            [response setErrorToInvalidRequestParameterWithMessage:@"Non exist Source"];
            return YES;
        }
        _omniImages[source] = omniImage;
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
        [roiContext startExpiredTimer];
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
    if ([request stringForKey:DPOmnidirectionalImageProfileParamVR]) {
        param.vrMode = vr;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamStereo]) {
        param.stereoMode = stereo;
    }

    if ([request stringForKey:DPOmnidirectionalImageProfileParamX]) {
        param.cameraX = x;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamY]) {
        param.cameraY = y;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamZ]) {
        param.cameraZ = z;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamRoll]) {
        param.cameraRoll = roll;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamPitch]) {
        param.cameraPitch = pitch;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamYaw]) {
        param.cameraYaw = yaw;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamFOV]) {
        param.cameraFOV = fov;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamSphereSize]) {
        param.sphereSize = sphereSize;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamWidth]) {
        param.imageWidth = width;
    }
    if ([request stringForKey:DPOmnidirectionalImageProfileParamHeight]) {
        param.imageHeight = height;
    }
    return param;
}

- (BOOL)correctParamsWithRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
{
    
    NSString *xString = [request stringForKey:DPOmnidirectionalImageProfileParamX];
    NSString *yString = [request stringForKey:DPOmnidirectionalImageProfileParamY];
    NSString *zString = [request stringForKey:DPOmnidirectionalImageProfileParamZ];
    NSString *yawString = [request stringForKey:DPOmnidirectionalImageProfileParamYaw];
    NSString *rollString = [request stringForKey:DPOmnidirectionalImageProfileParamRoll];
    NSString *pitchString = [request stringForKey:DPOmnidirectionalImageProfileParamPitch];
    NSString *fovString = [request stringForKey:DPOmnidirectionalImageProfileParamFOV];
    NSString *sphereSizeString = [request stringForKey:DPOmnidirectionalImageProfileParamSphereSize];
    NSString *widthString = [request stringForKey:DPOmnidirectionalImageProfileParamWidth];
    NSString *heightString = [request stringForKey:DPOmnidirectionalImageProfileParamHeight];
    NSString *stereoString = [request stringForKey:DPOmnidirectionalImageProfileParamStereo];
    NSString *vrString = [request stringForKey:DPOmnidirectionalImageProfileParamVR];
    NSString *parameters[] = {xString, yString, zString, yawString, rollString, pitchString,
                            fovString, sphereSizeString, widthString, heightString};

    for (int i = 0; i < 10; i++) {
        if (![DPThetaManager existDecimalWithString:[parameters[i] stringByReplacingOccurrencesOfString:@"e-" withString:@""]]) {
            NSString *errorMessage = [NSString stringWithFormat:@"%@ is not a number.", parameters[i]];
            [response setErrorToInvalidRequestParameterWithMessage:errorMessage];
            return NO;
        }
    }
    
    for (int i = 3; i < 10; i++) {
        if (parameters[i].floatValue < 0) {
            NSString *errorMessage = [NSString stringWithFormat:@"%@ is negative.", parameters[i]];
            [response setErrorToInvalidRequestParameterWithMessage:errorMessage];
            return NO;
        }
    }
    for (int i = 3; i < 6; i++) {
        if (parameters[i].floatValue > 360) {
            NSString *errorMessage = [NSString stringWithFormat:@"%@ is over 360.", parameters[i]];
            [response setErrorToInvalidRequestParameterWithMessage:errorMessage];
            return NO;
        }
    }
    
    if (fovString.floatValue > 180) {
        NSString *errorMessage = [NSString stringWithFormat:@"%@ is over 180.", fovString];
        [response setErrorToInvalidRequestParameterWithMessage:errorMessage];
        return NO;
    }
    
    if (stereoString && ![DPThetaManager existBOOL:stereoString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"stereo is non Boolean."];
        return NO;
    }

    if (vrString && ![DPThetaManager existBOOL:vrString]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"vr is non Boolean."];
        return NO;
    }
    return YES;
}



#pragma mark - delegate method

-(void)didUpdateMediaWithSegment:(NSString*)segment data:(NSData *)data
{
    [_server offerMediaWithData:data segment:segment];
}

-(void)didExpiredMediaWithSegment:(NSString*)segment
{
    NSString *url = [NSString stringWithFormat:@"%@/%@", [_server getUrl],segment];
    DPThetaRoiDeliveryContext *context = _roiContexts[[DPThetaManager omitParametersToUri:url]];
    if (context) {
        [_server stopMediaForSegment:segment];
        [_roiContexts removeObjectForKey:[DPThetaManager omitParametersToUri:url]];
    }
}

- (void)didConnectForSegment:(NSString*)segment
                       isGet:(BOOL)isGet
{
    NSString *url = [NSString stringWithFormat:@"%@%@", [_server getUrl],segment];
    DPThetaRoiDeliveryContext *target = _roiContexts[[DPThetaManager omitParametersToUri:url]];
    if (!target) {
        return;
    }
    if (isGet) {
        [target restartExpiredTimer];
    } else {
        [target stopExpiredTimer];
    }

}

- (void)didDisconnectForSegment:(NSString*)segment
{
    if (_server) {
        [_server stopMediaForSegment:segment];
    }
    DPThetaRoiDeliveryContext *context = _roiContexts[[DPThetaManager omitParametersToUri:
                                                       [NSString stringWithFormat:@"%@%@",
                                                       [_server getUrl],segment]]];
    if (context) {
        [context destroy];
        [_roiContexts removeObjectForKey:segment];
        
    }
}

- (void)didCloseServer
{
    if (_server && [_server isRunning]) {
        [_server startStopServer];
    }
}

@end
