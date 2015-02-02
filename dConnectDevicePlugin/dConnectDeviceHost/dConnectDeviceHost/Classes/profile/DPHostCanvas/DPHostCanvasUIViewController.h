//
//  DPHostCanvasUIViewController.h
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPHostCanvasView.h"

@protocol DPHostCanvasViewControllerDelegate <NSObject>

- (void) disappearViewController;

@end


@interface DPHostCanvasUIViewController : UIViewController

@property (nonatomic, assign) id<DPHostCanvasViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet DPHostCanvasView *canvasView;



/*!
 @brief set draw object.
 @param data image data
 @param x x
 @param y y
 @param mode mode
 */
- (void)setDrawImage: (NSData *) data x: (double) x y: (double) y mode: (NSString *) mode;



@end
