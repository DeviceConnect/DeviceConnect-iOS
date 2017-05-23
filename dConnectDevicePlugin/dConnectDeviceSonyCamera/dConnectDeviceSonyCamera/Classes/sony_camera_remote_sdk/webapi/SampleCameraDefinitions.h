/**
 * @file  SampleCameraDefinitions.h
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

/**
 * API names of camera service
 */
static NSString *API_CAMERA_getMethodTypes = @"camera:getMethodTypes";
static NSString *API_CAMERA_getAvailableApiList = @"getAvailableApiList";
static NSString *API_CAMERA_getApplicationInfo = @"getApplicationInfo";
static NSString *API_CAMERA_getShootMode = @"getShootMode";
static NSString *API_CAMERA_setShootMode = @"setShootMode";
static NSString *API_CAMERA_getAvailableShootMode = @"getAvailableShootMode";
static NSString *API_CAMERA_getSupportedShootMode = @"getSupportedShootMode";
static NSString *API_CAMERA_startLiveview = @"startLiveview";
static NSString *API_CAMERA_stopLiveview = @"stopLiveview";
static NSString *API_CAMERA_startRecMode = @"startRecMode";
static NSString *API_CAMERA_actTakePicture = @"actTakePicture";
static NSString *API_CAMERA_startMovieRec = @"startMovieRec";
static NSString *API_CAMERA_stopMovieRec = @"stopMovieRec";
static NSString *API_CAMERA_actZoom = @"actZoom";
static NSString *API_CAMERA_getEvent = @"getEvent";
static NSString *API_CAMERA_setCameraFunction = @"setCameraFunction";

/**
 * Parameter names of camera service
 */
static NSString *PARAM_CAMERA_cameraStatus_idle = @"IDLE";
static NSString *PARAM_CAMERA_cameraStatus_stillCapturing = @"StillCapturing";
static NSString *PARAM_CAMERA_cameraStatus_stillSaving = @"StillSaving";
static NSString *PARAM_CAMERA_cameraStatus_movieWaitRecStart =
    @"MovieWaitRecStart";
static NSString *PARAM_CAMERA_cameraStatus_movieRecording = @"MovieRecording";
static NSString *PARAM_CAMERA_cameraStatus_movieWaitRecStop =
    @"MovieWaitRecStop";
static NSString *PARAM_CAMERA_cameraStatus_movieSaving = @"MovieSaving";
static NSString *PARAM_CAMERA_cameraStatus_intervalWaitRecStart =
    @"IntervalWaitRecStart";
static NSString *PARAM_CAMERA_cameraStatus_intervalRecording =
    @"IntervalRecording";
static NSString *PARAM_CAMERA_cameraStatus_intervalWaitRecStop =
    @"IntervalWaitRecStop";
static NSString *PARAM_CAMERA_cameraStatus_audioWaitRecStart =
    @"AudioWaitRecStart";
static NSString *PARAM_CAMERA_cameraStatus_audioRecording = @"AudioRecording";
static NSString *PARAM_CAMERA_cameraStatus_audioWaitRecStop =
    @"AudioWaitRecStop";
static NSString *PARAM_CAMERA_cameraStatus_audioSaving = @"AudioSaving";
static NSString *PARAM_CAMERA_cameraStatus_contentsTransfer =
    @"ContentsTransfer";
static NSString *PARAM_CAMERA_cameraStatus_streaming = @"Streaming";
static NSString *PARAM_CAMERA_cameraStatus_deleting = @"Deleting";
static NSString *PARAM_CAMERA_cameraStatus_notReady = @"NotReady";

static NSString *PARAM_CAMERA_cameraFunction_remoteShooting =
    @"Remote Shooting";
static NSString *PARAM_CAMERA_cameraFunction_contentsTransfer =
    @"Contents Transfer";

static NSString *PARAM_CAMERA_storageId_noMedia = @"No Media";
