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

@property (strong, nonatomic) IBOutlet DPHostCanvasView *canvasView;



/*!
 @brief set draw object.
 @param drawObject draw object
 */
- (void)setDrawObject: (DPHostCanvasDrawObject *)drawObject;



@end
