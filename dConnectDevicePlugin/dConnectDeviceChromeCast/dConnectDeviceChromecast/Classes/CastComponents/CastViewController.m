// Copyright 2014 Google Inc. All Rights Reserved.
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

#import "CastViewController.h"
#import "CastDeviceController.h"
#import "NotificationConstants.h"
#import "SimpleImageFetcher.h"
#import "TracksTableViewController.h"

#import <GoogleCast/GCKDevice.h>
#import <GoogleCast/GCKMediaControlChannel.h>
#import <GoogleCast/GCKMediaInformation.h>
#import <GoogleCast/GCKMediaMetadata.h>
#import <GoogleCast/GCKMediaQueueItem.h>
#import <GoogleCast/GCKMediaStatus.h>

static NSString * const kListTracks = @"listTracks";
static NSString * const kListTracksPopover = @"listTracksPopover";
NSString * const kCastComponentPosterURL = @"castComponentPosterURL";

@interface CastViewController () <CastDeviceControllerDelegate> {
  /* Flag to indicate we are scrubbing - the play position is only updated at the end. */
  BOOL _currentlyDraggingSlider;
  /* Flag to indicate whether we have status from the Cast device and can show the UI. */
  BOOL _readyToShowInterface;
  /* The most recent playback time - used for syncing between local and remote playback. */
  NSTimeInterval _lastKnownTime;
}

/* The device manager used for the currently casting media. */
@property(weak, nonatomic) CastDeviceController *castDeviceController;

/* The image of the current media. */
@property IBOutlet UIImageView *thumbnailImage;
/* The label displaying the currently connected device. */
@property IBOutlet UILabel *castingToLabel;
/* The label displaying the currently playing media. */
@property(weak, nonatomic) IBOutlet UILabel *mediaTitleLabel;
/* An activity indicator while the cast is starting. */
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *castActivityIndicator;
/* A timer to trigger a callback to update the times/slider position. */
@property(weak, nonatomic) NSTimer *updateStreamTimer;
/* A timer to trigger removal of the volume control. */
@property(weak, nonatomic) NSTimer *fadeVolumeControlTimer;

/* The time of the play head in the current video. */
@property(nonatomic) IBOutlet UILabel *currTime;
/* The total time of the video. */
@property(nonatomic) IBOutlet UILabel *totalTime;
/* The tracks selector button (for closed captions primarily in this sample). */
@property(nonatomic) IBOutlet UIButton *cc;
/* The button that brings up the volume control: Apple recommends not overriding the hardware
   volume controls, so we use a separate on-screen UI. */
@property(nonatomic) IBOutlet UIButton *volumeButton;
/* The play icon button. */
@property(nonatomic) IBOutlet UIButton *playButton;
/* A slider for the progress/scrub bar. */
@property(nonatomic) IBOutlet UISlider *slider;
/* The next button. */
@property(nonatomic) IBOutlet UIButton *nextButton;
/* The previous button. */
@property(nonatomic) IBOutlet UIButton *previousButton;

/* Play image. */
@property(nonatomic) UIImage *playImage;
/* Pause image. */
@property(nonatomic) UIImage *pauseImage;

/* Whether the viewcontroller is currently visible. */
@property BOOL visible;

@end

@implementation CastViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.visible = false;

  self.castDeviceController = [CastDeviceController sharedInstance];

  self.castingToLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil),
      _castDeviceController.deviceManager.device.friendlyName];

  self.volumeControlLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Volume", nil),
                                    _castDeviceController.deviceManager.device.friendlyName];
  self.volumeSlider.minimumValue = 0;
  self.volumeSlider.maximumValue = 1.0;
  self.volumeSlider.value = _castDeviceController.deviceManager.deviceVolume ?
      _castDeviceController.deviceManager.deviceVolume : 0.5;
  self.volumeSlider.continuous = NO;
  [self.volumeSlider addTarget:self
                        action:@selector(sliderValueChanged:)
              forControlEvents:UIControlEventValueChanged];

  UIButton *transparencyButton = [[UIButton alloc] initWithFrame:self.view.bounds];
  transparencyButton.autoresizingMask =
      (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
  transparencyButton.backgroundColor = [UIColor clearColor];
  [self.view insertSubview:transparencyButton aboveSubview:self.thumbnailImage];
  [transparencyButton addTarget:self
                         action:@selector(showVolumeSlider:)
               forControlEvents:UIControlEventTouchUpInside];
  self.navigationController.interactivePopGestureRecognizer.enabled = NO;
  [self initControls];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // Signal that this view appeared.
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kCastViewControllerAppearedNotification object:self];

  // Listen for volume change notifications.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(volumeDidChange)
                                               name:kCastVolumeChangedNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(didReceiveMediaStateChange)
                                               name:kCastMediaStatusChangeNotification
                                             object:nil];

  // Add the cast icon to our nav bar.
  UIBarButtonItem *item = [[CastDeviceController sharedInstance] queueItemForController:self];
  self.navigationItem.rightBarButtonItems = @[item];

  // Make the navigation bar transparent.
  self.navigationController.navigationBar.translucent = YES;
  [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.shadowImage = [UIImage new];

  [self.playButton setImage:self.playImage forState:UIControlStateNormal];
  [self showToolbar:NO];

  [self resetInterfaceElements];

  _readyToShowInterface = (_castDeviceController.mediaInformation != nil);

  [self configureView];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(applicationDidEnterForeground)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.visible = true;

  // Assign ourselves as the delegate.
  _castDeviceController.delegate = self;

  if (_castDeviceController.deviceManager.applicationConnectionState
      != GCKConnectionStateConnected) {
    // If we're not connected, exit.
    [self maybePopController];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  // I think we can safely stop the timer here
  [self.updateStreamTimer invalidate];
  self.updateStreamTimer = nil;

  // We no longer want to be delegate.
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [self.navigationController.navigationBar setBackgroundImage:nil
                                                forBarMetrics:UIBarMetricsDefault];
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  // Signal that this view disappeared.
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kCastViewControllerDisappearedNotification object:self];

  self.visible = false;
  [super viewDidDisappear:animated];
}

- (void)applicationDidEnterForeground {
  if (_castDeviceController.deviceManager.applicationConnectionState
      != GCKConnectionStateConnected) {
    // If we're not connected, exit.
    [self maybePopController];
    return;
  }

  if (_castDeviceController.playerState == GCKMediaPlayerStateIdle ) {
    // If the device is idle, exit.
    [self maybePopController];
    return;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if (!_castDeviceController) {
    self.castDeviceController = [CastDeviceController sharedInstance];
  }
  if ([segue.identifier isEqualToString:kListTracks] ||
      [segue.identifier isEqualToString:kListTracksPopover]) {
    GCKMediaInformation *media = _castDeviceController.mediaInformation;

    UITabBarController *controller;
    controller = (UITabBarController *)
        ((UINavigationController *)segue.destinationViewController).visibleViewController;
    TracksTableViewController *trackController = controller.viewControllers[0];
    [trackController setMedia:media
                      forType:GCKMediaTrackTypeText
             deviceController:_castDeviceController.mediaControlChannel];
    TracksTableViewController *audioTrackController = controller.viewControllers[1];
    [audioTrackController setMedia:media
                           forType:GCKMediaTrackTypeAudio
                  deviceController:_castDeviceController.mediaControlChannel];
  }
}

- (void)maybePopController {
  // Only take action if we're visible.
  if (self.visible) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)showToolbar:(BOOL)show {
  BOOL hidden = !show;
  _cc.hidden = hidden;
  _currTime.hidden = hidden;
  _totalTime.hidden = hidden;
  _nextButton.hidden = hidden;
  _previousButton.hidden = hidden;
  _volumeButton.hidden = hidden;
  _slider.hidden = hidden;
  _playButton.hidden = hidden;
}

#pragma mark - Managing the detail item

- (void)resetInterfaceElements {
  self.totalTime.text = @"";
  self.currTime.text = @"";
  [self.slider setValue:0];
  [self.castActivityIndicator startAnimating];
  _currentlyDraggingSlider = NO;
  [self showToolbar:NO];
  _readyToShowInterface = NO;
}

- (void)fadeVolumeSlider:(NSTimer *)timer {
  [self.volumeControls setAlpha:1.0];

  [UIView animateWithDuration:0.5
                   animations:^{
                     self.volumeControls.alpha = 0.0;
                   }
                   completion:^(BOOL finished){
                     self.volumeControls.hidden = YES;
                   }];
}


- (void)updateInterfaceFromCast:(NSTimer *)timer {
  if (!_readyToShowInterface) {
    return;
  }

  if (_castDeviceController.playerState != GCKMediaPlayerStateBuffering) {
    [_castActivityIndicator stopAnimating];
    [self showToolbar:YES];
  } else {
    [_castActivityIndicator startAnimating];
  }

  if (_castDeviceController.streamDuration > 0 && !_currentlyDraggingSlider) {
    _lastKnownTime = _castDeviceController.streamPosition;
    self.currTime.text = [self getFormattedTime:_castDeviceController.streamPosition];
    self.totalTime.text = [self getFormattedTime:_castDeviceController.streamDuration];
    [self.slider
        setValue:(_castDeviceController.streamPosition / _castDeviceController.streamDuration)
        animated:YES];
  }
  [self updateToolbarControls];
}


- (void)updateToolbarControls {
  switch (_castDeviceController.playerState) {
    case GCKMediaPlayerStatePaused:
    case GCKMediaPlayerStateIdle:
    case GCKMediaPlayerStateUnknown:
      [self.playButton setImage:self.playImage forState:UIControlStateNormal];
      break;
    case GCKMediaPlayerStatePlaying:
    case GCKMediaPlayerStateBuffering:
      [self.playButton setImage:self.pauseImage forState:UIControlStateNormal];
      break;
  }
}

// Basic time formatter.
- (NSString *)getFormattedTime:(NSTimeInterval)timeInSeconds {
  int seconds = round(timeInSeconds);
  int hours = seconds / (60 * 60);
  seconds %= (60 * 60);

  int minutes = seconds / 60;
  seconds %= 60;

  if (hours > 0) {
    return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
  } else {
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
  }
}

- (void)configureView {
  GCKMediaInformation *media = _castDeviceController.mediaInformation;
  BOOL connected =
      _castDeviceController.deviceManager.applicationConnectionState == GCKConnectionStateConnected;
  if (!media || !connected) {
    [self resetInterfaceElements];
    return;
  }

  [self showToolbar:YES];

  NSString *title = [media.metadata stringForKey:kGCKMetadataKeyTitle];
  // TODO(i18n): Localize this string.
  self.castingToLabel.text =
      [NSString stringWithFormat:@"Casting to %@",
          _castDeviceController.deviceManager.device.friendlyName];
  self.mediaTitleLabel.text = title;

  NSLog(@"Configured view with media: %@", media);

  // Loading thumbnail async.
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *posterURL = [media.metadata stringForKey:kCastComponentPosterURL];
    if (posterURL) {
      UIImage *image = [UIImage
          imageWithData:[SimpleImageFetcher getDataFromImageURL:[NSURL URLWithString:posterURL]]];

      dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Loaded thumbnail image");
        self.thumbnailImage.image = image;
        [self.view setNeedsLayout];
      });
    }
  });

  self.cc.enabled = media.mediaTracks.count > 0;

  // Dance to find our position in the queue, and enable/disable buttons
  // as required.
  GCKMediaStatus *mediaStatus = _castDeviceController.mediaControlChannel.mediaStatus;
  GCKMediaQueueItem *currentItem = [mediaStatus queueItemWithItemID:mediaStatus.currentItemID];
  BOOL hasPrevious = YES;
  BOOL hasNext = NO;
  NSInteger count = [mediaStatus queueItemCount];
  for (NSInteger i = 0; i < count; ++i) {
    GCKMediaQueueItem *item = [mediaStatus queueItemAtIndex:i];
    if (currentItem == item) {
      hasPrevious = (i > 0);
      hasNext = (i < count - 1);
    }
  }
  self.nextButton.enabled = hasNext;
  self.previousButton.enabled = hasPrevious;

  // Start the timer
  if (self.updateStreamTimer) {
    [self.updateStreamTimer invalidate];
    self.updateStreamTimer = nil;
  }

  self.updateStreamTimer =
      [NSTimer scheduledTimerWithTimeInterval:1.0
                                       target:self
                                     selector:@selector(updateInterfaceFromCast:)
                                     userInfo:nil
                                      repeats:YES];
}

#pragma mark - Interface

- (IBAction)previousButtonClicked:(id)sender {
  [_castDeviceController.mediaControlChannel queuePreviousItem];
}

- (IBAction)nextButtonClicked:(id)sender {
  [_castDeviceController.mediaControlChannel queueNextItem];
}

- (IBAction)playButtonClicked:(id)sender {
  if (_castDeviceController.playerState == GCKMediaPlayerStatePaused) {
    [_castDeviceController.mediaControlChannel play];
  } else {
    [_castDeviceController.mediaControlChannel pause];
  }
}

- (IBAction)subtitleButtonClicked:(id)sender {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self performSegueWithIdentifier:kListTracksPopover sender:self];
  } else {
    [self performSegueWithIdentifier:kListTracks sender:self];
  }
}

- (IBAction)onTouchDown:(id)sender {
  _currentlyDraggingSlider = YES;
}

// This is continuous, so we can update the current/end time labels
- (IBAction)onSliderValueChanged:(id)sender {
  float pctThrough = [self.slider value];
  if (_castDeviceController.streamDuration > 0) {
    self.currTime.text =
        [self getFormattedTime:(pctThrough * _castDeviceController.streamDuration)];
  }
}

- (IBAction)sliderValueChanged:(id)sender {
  UISlider *slider = (UISlider *)sender;
  NSLog(@"Got new slider value: %.2f", slider.value);
  [_castDeviceController.deviceManager setVolume:slider.value];
}

- (IBAction)unwindToCastView:(UIStoryboardSegue *)segue; {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

// This is called only on one of the two touch up events
- (IBAction)touchIsFinished {
  [_castDeviceController setPlaybackPercent:[self.slider value]];
  _currentlyDraggingSlider = NO;
}

- (IBAction)onTouchUpInside:(id)sender {
  NSLog(@"Touch up inside");
  [self touchIsFinished];

}
- (IBAction)onTouchUpOutside:(id)sender {
  NSLog(@"Touch up outside");
  [self touchIsFinished];
}

- (IBAction)showVolumeSlider:(id)sender {
  if (self.volumeControls.hidden) {
    self.volumeControls.hidden = NO;
    [self.volumeControls setAlpha:0];

    [UIView animateWithDuration:0.5
                     animations:^{
                       self.volumeControls.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                       NSLog(@"Volume slider hidden done!");
                     }];

  }
  // Do this so if a user taps the screen or plays with the volume slider, it resets the timer
  // for fading the volume controls
  if (self.fadeVolumeControlTimer != nil) {
    [self.fadeVolumeControlTimer invalidate];
  }
  self.fadeVolumeControlTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                 target:self
                                                               selector:@selector(fadeVolumeSlider:)
                                                               userInfo:nil
                                                                repeats:NO];
}

- (void)initControls {
  // Hide the toolbar in case minicontroller is displayed.
  self.navigationController.toolbarHidden = YES;
  NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceChromecast_resources" ofType:@"bundle"];
  NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

  // Play/Pause images.
  self.playImage = [UIImage imageNamed:@"media_play" inBundle:bundle compatibleWithTraitCollection:nil];
  self.pauseImage = [UIImage imageNamed:@"media_pause" inBundle:bundle compatibleWithTraitCollection:nil];
  _playButton.tintColor = [UIColor whiteColor];

  // Slider.
  UIImage *thumb = [UIImage imageNamed:@"thumb.png" inBundle:bundle compatibleWithTraitCollection:nil];
  [_slider setThumbImage:thumb forState:UIControlStateNormal];
  [_slider setThumbImage:thumb forState:UIControlStateHighlighted];

  // Volume.
  _volumeButton.tintColor = [UIColor whiteColor];

  // Queue.
  _previousButton.tintColor = [UIColor whiteColor];
  _nextButton.tintColor = [UIColor whiteColor];

  // Round the corners on the volume pop up.
  _volumeControls.layer.cornerRadius = 5;
  _volumeControls.layer.masksToBounds = YES;
  // Update default volume value.
  [self volumeDidChange];
}

#pragma mark - CastDeviceControllerDelegate

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect {
  [self maybePopController];
}

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange {
  _readyToShowInterface = YES;
  if ([self isViewLoaded] && self.view.window) {
    // Display toolbar if we are current view.
    [self showToolbar:YES];
    [self configureView];
  }

  // If we are idle and not loading anything, we can bounce back.
  if (_castDeviceController.mediaControlChannel.mediaStatus.playerState == GCKMediaPlayerStateIdle
      && !_castDeviceController.mediaControlChannel.mediaStatus.loadingItemID) {
    [self maybePopController];
  }
}

#pragma mark Volume listener.

- (void)volumeDidChange {
  _volumeSlider.value = _castDeviceController.deviceManager.deviceVolume;
}

@end