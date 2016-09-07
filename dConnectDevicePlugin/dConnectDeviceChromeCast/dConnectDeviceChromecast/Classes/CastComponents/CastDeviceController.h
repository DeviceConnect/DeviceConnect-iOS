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

#import <Foundation/Foundation.h>
#import <GoogleCast/GCKDeviceScanner.h>
#import <GoogleCast/GCKMediaStatus.h>

@class GCKDevice;
@class GCKDeviceManager;
@class GCKMediaControlChannel;
@class GCKMediaInformation;

extern NSString * const kCastViewController;

@protocol CastDeviceControllerDelegate <NSObject>

@optional

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice *)device;

/**
 *  Called when the device disconnects.
 */
- (void)didDisconnect;

/**
 * Called when Cast devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork;

/**
 * Called when the connected device's queue updates.
 */
- (void)didUpdateQueueForDevice:(GCKDevice *)device;

/**
 *  Called when the next item in a queue starts preloading.
 *
 *  @param item GCKMediaQueueItem
 */
- (void)didUpdatePreloadStatusForItem:(GCKMediaQueueItem *)item;

/**
 *  Whether or not the device controller should be displayed.
 *
 *  @return YES to display, NO to prevent.
 */
- (BOOL)shouldDisplayModalDeviceController;

@end

@interface CastDeviceController : NSObject <GCKDeviceScannerListener>

/**
 *  The storyboard contianing the Cast component views used by the controllers in
 *  the CastComponents group.
 */
@property(nonatomic, readonly) UIStoryboard *storyboard;

/**
 *  The delegate for this object.
 */
@property(nonatomic, weak) id<CastDeviceControllerDelegate> delegate;

/**
 *  The Cast application ID to launch.
 */
@property(nonatomic, copy) NSString *applicationID;

/**
 *  The device manager used to manage a connection to a Cast device.
 */
@property(nonatomic, strong) GCKDeviceManager *deviceManager;

/**
 *  The device scanner used to detect devices on the network.
 */
@property(nonatomic, strong) GCKDeviceScanner *deviceScanner;

/**
 *  The media information of the loaded media on the device.
 */
@property(nonatomic, readonly) GCKMediaInformation *mediaInformation;

/**
 *  The media control channel for the playing media.
 */
@property(nonatomic, strong) GCKMediaControlChannel *mediaControlChannel;

/**
 *  The information about the next item to be played in the autoplay queue.
 */
@property(nonatomic, readonly) GCKMediaQueueItem *preloadingItem;

/**
 *  Helper accessor for the media player state of the media on the device.
 */
@property(nonatomic, readonly) GCKMediaPlayerState playerState;

/**
 *  Helper accessor for the duration of the currently casting media.
 */
@property(nonatomic, readonly) NSTimeInterval streamDuration;

/**
 *  The current playback position of the currently casting media.
 */
@property(nonatomic, readonly) NSTimeInterval streamPosition;

/**
 *  Main access point for the class. Use this to retrieve an object you can use.
 *
 *  @return CastDeviceController
 */
+ (instancetype)sharedInstance;

/**
 *  Display the media currently being cast.
 */
- (void)displayCurrentlyPlayingMedia;

/**
 *  Sets the position of the playback on the Cast device.
 *
 *  @param newPercent 0.0-1.0
 */
- (void)setPlaybackPercent:(float)newPercent;

/**
 *  Connect to the given Cast device.
 *
 *  @param device A GCKDevice from the deviceScanner list.
 */
- (void)connectToDevice:(GCKDevice *)device;

/**
 *  "Play Now" the specified GCKMediaInformation. This will clobber the any current queue
 *  of media.
 *
 *  @param media The GCKMediaInformation to play.
 */
- (void)mediaPlayNow:(GCKMediaInformation *)media;

/**
 *  "Play Next" the specified GCKMediaInformation. If there is nothing currently playing,
 *  the media will play immediately.
 *
 *  @param media The GCKMediaInformation to play.
 */
- (void)mediaPlayNext:(GCKMediaInformation *)media;

/**
 *  "Add To Queue" the specified GCKMediaInformation. This method should only be called
 *  once media is playing. This is to avoid situations where the queue is unavailable due
 *  to an updated mediaStatus not having been received.
 *
 *  @param media The GCKMediaInformation to play.
 */
- (void)mediaAddToQueue:(GCKMediaInformation *)media;

/**
 *  Enable Cast enhancing of a controller by returning a UIBarButtonItem to show the queue
 *  status. Signals that a view controller is being used to present the UI.
 *
 *  @param item UIViewController to use as a parent for queue actions
 *  @return item The decorated UIBarButtonItem, always non-nil
 */
- (UIBarButtonItem *)queueItemForController:(UIViewController *)controller;

/**
 *  Return the last known stream position for the given contentID. This will generally only
 *  be useful for the last Cast media, and allows a local player to resume playback at the
 *  position noted before disconnect. In many cases it will return 0.
 *
 *  @param contentID The string of the identifier of the media to be displayed.
 *
 *  @return the position in the stream of the media, if any.
 */
- (NSTimeInterval)streamPositionForPreviouslyCastMedia:(NSString *)contentID;

/**
 * Update the stored last known stream position to the current stream position. This must be
 * called regularly to ensure the value tracks the actual stream position.
 */
- (void)updateLastPosition;

/**
 *  Prevent automatically reconnecting to the Cast device if we see it again.
 */
- (void)clearPreviousSession;

/**
 *  Enable basic logging of all GCKLogger messages to the console.
 */
- (void)enableLogging;
- (UIButton*)controller:(UIViewController *)controller;
@end
