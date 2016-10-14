// Copyright 2015 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "CastIconButton.h"
#import "CastInstructionsViewController.h"
#import "CastViewController.h"
#import "CastDeviceController.h"
#import "DeviceTableViewController.h"
#import "NotificationConstants.h"
#import "RepeatingTimerManager.h"
#import <GoogleCast/GoogleCast.h>
#import "DPChromecastManager.h"

/**
 *  Constant for the storyboard ID for the device table view controller.
 */
static NSString * const kDeviceTableViewController = @"deviceTableViewController";

/**
 *  Constant for the amount of time to load a queued item before the current item
 *  finishes. This also is the time the preload status change will trigger from the
 *  receiver, which will generate a callback to the |GCKMediaControlChannelDelegate|.
 */
static NSInteger const kPreloadTime = 30;

/**
 *  Constant for the storyboard ID for the expanded view Cast controller.
 */
NSString * const kCastViewController = @"castViewController";

@interface CastDeviceController() <
    DeviceTableViewControllerDelegate,
    GCKDeviceManagerDelegate,
    GCKLoggerDelegate,
    GCKMediaControlChannelDelegate
>

/**
 *  The core storyboard containing the UI for the Cast components.
 */
@property(nonatomic, readwrite) UIStoryboard *storyboard;

/**
 *  The (optional) view controller that we are managing.
 */
@property(nonatomic, weak) UIViewController *controller;

/**
 *  The Cast Icon Button controlled by this class.
 */
@property(nonatomic) CastIconButton *castIconButton;

/**
 *  The information about the next item to be played in the autoplay queue.
 */
@property(nonatomic, readwrite) GCKMediaQueueItem *preloadingItem;

/**
 *  Whether or not we are attempting reconnect.
 */
@property(nonatomic) BOOL isReconnecting;

/**
 *  The last played content identifier.
 */
@property(nonatomic) NSString *lastContentID;

/**
 *  The last known playback position of the last played content.
 */
@property(nonatomic) NSTimeInterval lastPosition;

/**
 * The timer manager responsible for keeping the record of the stream's last known
 * position up to date.
 */
@property(nonatomic) RepeatingTimerManager *streamPositionUpdateTimer;

@end

@implementation CastDeviceController

#pragma mark - Lifecycle

+ (instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedDeviceController = nil;

  dispatch_once(&p, ^{
    _sharedDeviceController = [[self alloc] init];
  });

  return _sharedDeviceController;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    // Initialize UI controls for navigation bar.
    [self initControls];
    // Load the storyboard for the Cast component UI.
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceChromecast_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    self.storyboard = [UIStoryboard storyboardWithName:@"CastComponents" bundle:bundle];
  }
  return self;
}

- (void)dealloc {
  // Stop the position tracker.
  [_streamPositionUpdateTimer invalidateTimer];
  self.streamPositionUpdateTimer = nil;
}

# pragma mark - Internals

- (void)updateLastPosition {
  self.lastPosition = [_mediaControlChannel approximateStreamPosition];
}

# pragma mark - Accessors

- (GCKMediaPlayerState)playerState {
  return _mediaControlChannel.mediaStatus.playerState;
}

- (NSTimeInterval)streamDuration {
  return _mediaInformation.streamDuration;
}

- (NSTimeInterval)streamPosition {
  return _lastPosition;
}

- (void)setPlaybackPercent:(float)newPercent {
  newPercent = MAX(MIN(1.0, newPercent), 0.0);

  NSTimeInterval newTime = newPercent * self.streamDuration;
  if (newTime > 0 && _deviceManager.applicationConnectionState == GCKConnectionStateConnected) {
    [self.mediaControlChannel seekToTimeInterval:newTime];
  }
}

/**
 *  Set the application ID and initialise a scan.
 *
 *  @param applicationID Cast application ID
 */
- (void)setApplicationID:(NSString *)applicationID {
  _applicationID = applicationID;

  // Create filter criteria to only show devices that can run your app
  GCKFilterCriteria *filterCriteria =
      [GCKFilterCriteria criteriaForAvailableApplicationWithID:applicationID];

  // Add the criteria to the scanner to only show devices that can run your app.
  // This allows you to publish your app to the Apple App store before before publishing in Cast
  // console. Once the app is published in Cast console the cast icon will begin showing up on ios
  // devices. If an app is not published in the Cast console the cast icon will only appear for
  // whitelisted dongles
  self.deviceScanner = [[GCKDeviceScanner alloc] initWithFilterCriteria:filterCriteria];

  // Always start a scan as soon as we have an application ID.
  NSLog(@"Starting Scan");
  [self.deviceScanner addListener:self];
  [self.deviceScanner startScan];
}

# pragma mark - UI Management

- (void)chooseDevice:(id)sender {
  BOOL showPicker = YES;
  if ([_delegate respondsToSelector:@selector(shouldDisplayModalDeviceController)]) {
    showPicker = [_delegate shouldDisplayModalDeviceController];
  }
  if (self.controller && showPicker) {
    UINavigationController *dtvc = (UINavigationController *)
        [_storyboard instantiateViewControllerWithIdentifier:kDeviceTableViewController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      dtvc.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    ((DeviceTableViewController *)dtvc.viewControllers[0]).delegate = self;
    [self.controller presentViewController:dtvc animated:YES completion:nil];
  }
}

- (void)dismissDeviceTable {
  [self.controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateCastIconButtonStates {
  if (self.deviceManager.applicationConnectionState == GCKConnectionStateConnected) {
    _castIconButton.status = CIBCastConnected;
  } else if (self.deviceManager.applicationConnectionState == GCKConnectionStateConnecting) {
    _castIconButton.status = CIBCastConnecting;
  } else if (self.deviceScanner.devices.count == 0) {
    _castIconButton.status = CIBCastUnavailable;
  } else {
    _castIconButton.status = CIBCastAvailable;
  }
}

- (void)initControls {
  _castIconButton = [CastIconButton buttonWithFrame:CGRectMake(0, 0, 29, 22)];
  
  [_castIconButton addTarget:self
                      action:@selector(chooseDevice:)
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)displayCurrentlyPlayingMedia {
  if (self.controller) {
    CastViewController *vc =
        [_storyboard instantiateViewControllerWithIdentifier:kCastViewController];
    [self.controller.navigationController pushViewController:vc animated:YES];
  }
}

# pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {

  if (_isReconnecting) {
    // Reconnect, if our app is playing. Attempt to join our session if current.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastSessionID = [defaults valueForKey:@"lastSessionID"];
    [self.deviceManager joinApplication:_applicationID sessionID:lastSessionID];
    
  } else {
    // Explicit connect request.
    [self.deviceManager launchApplication:_applicationID];
  }
  [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
  self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
  self.mediaControlChannel.delegate = self;
  [self.deviceManager addChannel:self.mediaControlChannel];
  [self.mediaControlChannel requestStatus];

  [self updateCastIconButtonStates];
  [[NSNotificationCenter defaultCenter] postNotificationName:kCastApplicationConnectedNotification
                                                      object:self];

  if ([_delegate respondsToSelector:@selector(didConnectToDevice:)]) {
    [_delegate didConnectToDevice:deviceManager.device];
  }
  [[DPChromecastManager sharedManager] updateManageServiceWithId:deviceManager.device.deviceID online:YES];

  self.isReconnecting = NO;
  // Store sessionID in case of restart
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:sessionID forKey:@"lastSessionID"];
  [defaults setObject:deviceManager.device.deviceID forKey:@"lastDeviceID"];
  [defaults synchronize];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    volumeDidChangeToLevel:(float)volumeLevel
                   isMuted:(BOOL)isMuted {
  [[NSNotificationCenter defaultCenter] postNotificationName:kCastVolumeChangedNotification
                                                      object:self];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToConnectToApplicationWithError:(NSError *)error {
  self.isReconnecting = NO;
  [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToConnectWithError:(GCKError *)error {
  [self clearPreviousSession];

  [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
  NSLog(@"Received notification that device disconnected");

  // Stop the position tracker.
  [_streamPositionUpdateTimer invalidateTimer];
  self.streamPositionUpdateTimer = nil;

  if (!error || (
      error.code == GCKErrorCodeDeviceAuthenticationFailure ||
      error.code == GCKErrorCodeDisconnected ||
      error.code == GCKErrorCodeApplicationNotFound)) {
    [self clearPreviousSession];
  }

  _mediaInformation = nil;
  [self updateCastIconButtonStates];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kCastApplicationDisconnectedNotification object:self];
    [[DPChromecastManager sharedManager] updateManageServiceWithId:deviceManager.device.deviceID online:NO];

  if ([_delegate respondsToSelector:@selector(didDisconnect)]) {
    [_delegate didDisconnect];
  }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didDisconnectFromApplicationWithError:(NSError *)error {
  NSLog(@"Received notification that app disconnected");

  // Stop the position tracker.
  [_streamPositionUpdateTimer invalidateTimer];
  self.streamPositionUpdateTimer = nil;

  if (error) {
    NSLog(@"Application disconnected with error: %@", error);
  }

  [[NSNotificationCenter defaultCenter]
      postNotificationName:kCastApplicationDisconnectedNotification object:self];

  // If we've lost the app connection, tear down the device connection.
  [deviceManager disconnect];
}

# pragma mark - Reconnection

- (void)clearPreviousSession {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:@"lastDeviceID"];
  [defaults synchronize];
}

- (NSTimeInterval)streamPositionForPreviouslyCastMedia:(NSString *)contentID {
  if ([contentID isEqualToString:_lastContentID]) {
    return _lastPosition;
  }
  return 0;
}

# pragma mark - GCKDeviceScannerListener

- (void)deviceDidComeOnline:(GCKDevice *)device {
  NSLog(@"device found - %@", device.friendlyName);

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *lastDeviceID = [defaults objectForKey:@"lastDeviceID"];
  if (lastDeviceID != nil && [[device deviceID] isEqualToString:lastDeviceID]){
    self.isReconnecting = YES;
    [self connectToDevice:device];
  }

  if ([_delegate respondsToSelector:@selector(didDiscoverDeviceOnNetwork)]) {
    [_delegate didDiscoverDeviceOnNetwork];
  }

  [[NSNotificationCenter defaultCenter] postNotificationName:kCastScanStatusUpdatedNotification
                                                      object:self];
  [self updateCastIconButtonStates];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
  NSLog(@"device went offline - %@", device.friendlyName);
  [[NSNotificationCenter defaultCenter] postNotificationName:kCastScanStatusUpdatedNotification
                                                      object:self];
  [self updateCastIconButtonStates];
}

- (void)deviceDidChange:(GCKDevice *)device {
  [[NSNotificationCenter defaultCenter] postNotificationName:kCastScanStatusUpdatedNotification
                                                      object:self];
}

#pragma mark - GCKMediaControlChannelDelegate methods

- (void)mediaControlChannelDidUpdateStatus:(GCKMediaControlChannel *)mediaControlChannel {
  NSLog(@"Media control channel status changed");
  _mediaInformation = mediaControlChannel.mediaStatus.mediaInformation;

  // Always invalidate the existing stream position timer; we can get a new one later if necessary.
  [_streamPositionUpdateTimer invalidateTimer];
  self.streamPositionUpdateTimer = nil;
  // Start a new stream position timer if there's content playing.
  if (_mediaInformation.contentID) {
    self.streamPositionUpdateTimer =
    [[RepeatingTimerManager alloc] initWithTarget:self
                                         selector:@selector(updateLastPosition)
                                        frequency:1.0];
  }

  self.lastContentID = _mediaInformation.contentID;

  [[NSNotificationCenter defaultCenter] postNotificationName:kCastMediaStatusChangeNotification
                                                      object:self];
  [self updateCastIconButtonStates];
}

- (void)mediaControlChannelDidUpdateMetadata:(GCKMediaControlChannel *)mediaControlChannel {
  NSLog(@"Media control channel metadata changed");
  [[NSNotificationCenter defaultCenter] postNotificationName:kCastMediaStatusChangeNotification
                                                      object:self];
}

- (void)mediaControlChannelDidUpdateQueue:(GCKMediaControlChannel *)mediaControlChannel {
  NSLog(@"Media control channel queue changed");

  [[NSNotificationCenter defaultCenter] postNotificationName:kCastQueueUpdatedNotification
                                                      object:self];

  if ([_delegate respondsToSelector:@selector(didUpdateQueueForDevice:)]) {
    [_delegate didUpdateQueueForDevice:_deviceManager.device];
  }
}

- (void)mediaControlChannelDidUpdatePreloadStatus:(GCKMediaControlChannel *)mediaControlChannel {
  NSLog(@"Preloading status changed");

  if (mediaControlChannel.mediaStatus && mediaControlChannel.mediaStatus.preloadedItemID) {
    self.preloadingItem = [mediaControlChannel.mediaStatus
                           queueItemWithItemID:mediaControlChannel.mediaStatus.preloadedItemID];
  } else {
    // Clear the preloading item when it starts playing.
    self.preloadingItem = nil;
  }

  if ([_delegate respondsToSelector:@selector(didUpdatePreloadStatusForItem:)]) {
    [_delegate didUpdatePreloadStatusForItem:self.preloadingItem];
  }

  [[NSNotificationCenter defaultCenter]
      postNotificationName:kCastPreloadStatusChangeNotification object:self];
}

#pragma mark - Device & Media Management

- (void)connectToDevice:(GCKDevice *)device {
  NSLog(@"Connecting to device address: %@:%d", device.ipAddress, (unsigned int)device.servicePort);

  NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
  NSString *appIdentifier = [info objectForKey:@"CFBundleIdentifier"];
  self.deviceManager =
      [[GCKDeviceManager alloc] initWithDevice:device clientPackageName:appIdentifier];
  self.deviceManager.delegate = self;
  [self.deviceManager connect];

  // Start animating the cast connect images.
  self.castIconButton.status = CIBCastConnecting;
}

- (void)mediaPlayNow:(GCKMediaInformation *)media {
  GCKMediaStatus *status = _mediaControlChannel.mediaStatus;
  // If there's nothing in the queue, just play the media.
  if ([status queueItemCount] == 0) {
    [_mediaControlChannel loadMedia:media autoplay:YES];
  } else {
    // Otherwise, explicitly create a queue item.
    GCKMediaQueueItem *queueItem = [[GCKMediaQueueItem alloc] initWithMediaInformation:media
                                                                              autoplay:YES
                                                                             startTime:0
                                                                           preloadTime:kPreloadTime
                                                                        activeTrackIDs:nil
                                                                            customData:nil];

    // If this is the last item in the queue, insert it at the end.
    if ([status queueItemAtIndex:[status queueItemCount]-1].itemID == status.currentItemID) {
      [_mediaControlChannel queueInsertAndPlayItem:queueItem
                                  beforeItemWithID:kGCKMediaQueueInvalidItemID];
    } else {
      // Otherwise, insert right after the current position.
      NSUInteger candidatePosition = [status queueIndexForItemID:status.currentItemID] + 1;
      GCKMediaQueueItem *candidate = [status queueItemAtIndex:candidatePosition];
      [_mediaControlChannel queueInsertAndPlayItem:queueItem beforeItemWithID:candidate.itemID];
    }
  }
}

- (void)mediaPlayNext:(GCKMediaInformation *)media {
  GCKMediaQueueItem *queueItem = [[GCKMediaQueueItem alloc] initWithMediaInformation:media
                                                                            autoplay:YES
                                                                           startTime:0
                                                                         preloadTime:kPreloadTime
                                                                      activeTrackIDs:nil
                                                                          customData:nil];
  GCKMediaStatus *status = _mediaControlChannel.mediaStatus;

  // If this is the last item in the queue, insert it at the end.
  if ([status queueItemAtIndex:[status queueItemCount]-1].itemID == status.currentItemID) {
    [_mediaControlChannel queueInsertItem:queueItem beforeItemWithID:kGCKMediaQueueInvalidItemID];
  } else {
    // Otherwise, insert right after the current position.
    NSUInteger candidatePosition = [status queueIndexForItemID:status.currentItemID] + 1;
    GCKMediaQueueItem *candidate = [status queueItemAtIndex:candidatePosition];

    [_mediaControlChannel queueInsertItem:queueItem beforeItemWithID:candidate.itemID];
  }
}

- (void)mediaAddToQueue:(GCKMediaInformation *)media {
  GCKMediaQueueItem *queueItem = [[GCKMediaQueueItem alloc] initWithMediaInformation:media
                                                                            autoplay:YES
                                                                           startTime:0
                                                                         preloadTime:kPreloadTime
                                                                      activeTrackIDs:nil
                                                                          customData:nil];
  NSInteger requestID = [_mediaControlChannel queueInsertItem:queueItem
                                             beforeItemWithID:kGCKMediaQueueInvalidItemID];

  if (requestID == kGCKInvalidRequestID) {
    NSLog(@"Failed to add to queue.");
  } else {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCastItemQueuedNotification
                                                        object:self];
  }
}

- (UIBarButtonItem *)queueItemForController:(UIViewController *)controller {
  _controller = controller;
  if (!controller) {
    return nil;
  }

  return [[UIBarButtonItem alloc] initWithCustomView:_castIconButton];
}


- (UIButton*)controller:(UIViewController *)controller {
    _controller = controller;
    if (!controller) {
        return nil;
    }
    
    return _castIconButton;

}
#pragma mark - GCKLoggerDelegate implementation

- (void)enableLogging {
  [[GCKLogger sharedInstance] setDelegate:self];
}

- (void)logFromFunction:(const char *)function message:(NSString *)message {
  // Send SDK’s log messages directly to the console, as an example.
  NSLog(@"%s  %@", function, message);
}

@end
