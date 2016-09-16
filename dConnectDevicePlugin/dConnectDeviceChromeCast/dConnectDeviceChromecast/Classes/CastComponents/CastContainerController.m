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

#import "CastContainerController.h"
#import "CastDeviceController.h"
#import "CastViewController.h"
#import "NotificationConstants.h"
#import "SimpleImageFetcher.h"
#import "Toast.h"

#import <GoogleCast/GoogleCast.h>

static const NSInteger kCastContainerUpNextDisplayHeight = 55;
static const NSInteger kCastContainerMiniViewDisplayHeight = 45;

@interface CastContainerController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upNextHeight;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *miniHeight;
//
//@property (weak, nonatomic) IBOutlet UIView *upNextView;
//@property (nonatomic) IBOutlet UIButton *upNextStopButton;
//@property (nonatomic) IBOutlet UIButton *upNextPlayButton;
//@property (nonatomic) IBOutlet UIImageView *upNextImage;
//@property (nonatomic) IBOutlet UILabel *upNextTitle;
//@property (nonatomic) GCKMediaQueueItem *upNextItem;
//
//@property (weak, nonatomic) IBOutlet UIView *miniView;
//@property (weak, nonatomic) IBOutlet UIButton *thumbnailImage;
//@property (weak, nonatomic) IBOutlet UIButton *mediaStateButton;
//@property (weak, nonatomic) IBOutlet UILabel *miniTitle;
//@property (weak, nonatomic) IBOutlet UILabel *miniSubtitle;
@property (nonatomic) NSURL *imageUrl;
@property (nonatomic) BOOL extendedControlsVisible;
@end

@implementation CastContainerController

- (void)viewDidLoad {
  [super viewDidLoad];
//  self.extendedControlsVisible = NO;

  // Add actions to bar buttons.
//  [_upNextPlayButton addTarget:self
//                             action:@selector(onSkipToNextItem:)
//                   forControlEvents:UIControlEventTouchUpInside];
//  [_upNextStopButton addTarget:self
//                             action:@selector(onStopAutoplay:)
//                   forControlEvents:UIControlEventTouchUpInside];
//  [_thumbnailImage addTarget:self
//                               action:@selector(onShowMedia:)
//                     forControlEvents:UIControlEventTouchUpInside];
//  [_mediaStateButton addTarget:self
//                                 action:@selector(onToggleMediaState:)
//                       forControlEvents:UIControlEventTouchUpInside];

  // Listen for changes to the upnext bar.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(preloadStatusChange)
                                               name:kCastPreloadStatusChangeNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(hideUpNext)
                                               name:kCastApplicationDisconnectedNotification
                                             object:nil];

  // Listen for changes to the mini toolbar.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateMiniToolbar)
                                               name:kCastMediaStatusChangeNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateMiniToolbar)
                                               name:kCastApplicationConnectedNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateMiniToolbar)
                                               name:kCastApplicationDisconnectedNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onExtendedControlsAppeared)
                                               name:kCastViewControllerAppearedNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onExtendedControlsDisappeared)
                                               name:kCastViewControllerDisappearedNotification
                                             object:nil];

  // Listen for queue events so we can publish toasts.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onItemQueued)
                                               name:kCastItemQueuedNotification
                                             object:nil];

  // Set initial upnext state based on current preload.
  [self preloadStatusChange];

  // Set initial mini toolbar state.
  [self hideMini];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
  self = [super init];
  if (self) {
    [self addChildViewController:viewController];
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
  }
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  Respond to changes in preload status by hiding or showing the up next view.
 */
- (void)preloadStatusChange {
  GCKMediaQueueItem *preload = [CastDeviceController sharedInstance].preloadingItem;

  // If we have a preloaded item, configure the UpNext bar to display it.
  if (!preload) {
    [self hideUpNext];
  } else {
//    self.upNextItem = preload;
//
//    self.upNextTitle.text = [_upNextItem.mediaInformation.metadata
//                             stringForKey:kGCKMetadataKeyTitle];
//    [self showUpNext];
//
//    // Load the thumbnail image asynchronously.
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//      NSString *posterURL = [_upNextItem.mediaInformation.metadata
//                             stringForKey:kCastComponentPosterURL];
//      if (posterURL) {
//        UIImage *image =
//        [UIImage imageWithData:
//         [SimpleImageFetcher getDataFromImageURL:[NSURL URLWithString:posterURL]]];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//          NSLog(@"Loaded thumbnail image");
//          self.upNextImage.image = image;
//          [_upNextView setNeedsLayout];
//        });
//      }
//    });
  }
}

- (void)hideUpNext {
//  _upNextView.hidden = YES;
//  _upNextHeight.constant = 0;
}

- (void)showUpNext {
//  _upNextView.hidden = NO;
//  _upNextHeight.constant = kCastContainerUpNextDisplayHeight;
}

- (void)hideMini {
//  _miniView.hidden = YES;
//  _miniHeight.constant = 0;
}

- (void)showMini {
//  _miniView.hidden = NO;
//  _miniHeight.constant = kCastContainerMiniViewDisplayHeight;
}

- (void)onItemQueued {
  [Toast displayToastInView:[UIApplication sharedApplication].delegate.window
                withMessage:@"Item added to queue."
           forTimeInSeconds:3.5f];
}

- (void)onSkipToNextItem:(UIView *)sender {
  [[CastDeviceController sharedInstance].mediaControlChannel queueNextItem];
}

- (void)onStopAutoplay:(UIView *)sender {
  CastDeviceController *castDeviceController = [CastDeviceController sharedInstance];
  NSMutableArray *ids = [NSMutableArray array];
  GCKMediaStatus *mediaStatus = castDeviceController.mediaControlChannel.mediaStatus;
  NSInteger count = [mediaStatus queueItemCount];

  NSInteger currentLocation = [mediaStatus queueIndexForItemID:mediaStatus.currentItemID];

  for(NSInteger i = currentLocation + 1; i < count; ++i) {
    GCKMediaQueueItem *item = [mediaStatus queueItemAtIndex:i];
    [ids addObject:@(item.itemID)];
  }

  [castDeviceController.mediaControlChannel queueRemoveItemsWithIDs:ids];
  // Optimistically hide the up next view.
  [self hideUpNext];
}

- (void)onShowMedia:(UIView *)sender {
  [self hideMini];
  [[CastDeviceController sharedInstance] displayCurrentlyPlayingMedia];
}

- (void)onToggleMediaState:(UIView *)sender {

  CastDeviceController *castDeviceController = [CastDeviceController sharedInstance];

  if([castDeviceController mediaControlChannel]) {
    GCKMediaPlayerState state = [CastDeviceController sharedInstance].playerState;
    BOOL playing = (state == GCKMediaPlayerStatePlaying || state == GCKMediaPlayerStateBuffering);
    if (playing) {
      [[castDeviceController mediaControlChannel] pause];
    } else {
      [[castDeviceController mediaControlChannel] play];
    }
    [self updateMiniToolbar];
  }
}

- (void)onExtendedControlsAppeared {
  self.extendedControlsVisible = YES;
  [self updateMiniToolbar];
}

- (void)onExtendedControlsDisappeared {
//  self.extendedControlsVisible = NO;
  [self updateMiniToolbar];
}

- (void)updateMiniToolbar {
  CastDeviceController *castDeviceController = [CastDeviceController sharedInstance];

  GCKMediaInformation *info = castDeviceController.mediaInformation;
  GCKMediaPlayerState state = castDeviceController.playerState;

  // Update the play/pause state.
  if (state == GCKMediaPlayerStateUnknown ||
      state == GCKMediaPlayerStateIdle ||
      _extendedControlsVisible) {
//    [_mediaStateButton setImage:nil forState:UIControlStateNormal];
    [self hideMini];
  } else {
    [self showMini];
    BOOL playing = (state == GCKMediaPlayerStatePlaying || state == GCKMediaPlayerStateBuffering);
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceChromecast_resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

    if (playing) {
//      [_mediaStateButton setImage:[UIImage imageNamed:@"media_pause" inBundle:bundle compatibleWithTraitCollection:nil]
//                                  forState:UIControlStateNormal];
    } else {
//      [_mediaStateButton setImage:[UIImage imageNamed:@"media_play" inBundle:bundle compatibleWithTraitCollection:nil]
//                                  forState:UIControlStateNormal];
    }
  }

  // Update the text.
//  [_miniTitle setText:[info.metadata stringForKey:kGCKMetadataKeyTitle]];
//  [_miniSubtitle setText:[NSString stringWithFormat:@"Casting to %@",
//      castDeviceController.deviceManager.device.friendlyName]];

  // Update the image.
//  GCKImage *img = [info.metadata.images objectAtIndex:0];
//  if ([img.URL isEqual:_imageUrl]) {
//    return;
//  }

  // Load thumbnail asynchronously.
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    UIImage *newImage = [UIImage imageWithData:[SimpleImageFetcher getDataFromImageURL:img.URL]];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//      self.imageUrl = img.URL;
//      [_thumbnailImage setImage:newImage forState:UIControlStateNormal];
//    });
//  });
}

@end
