//
//  DPHostCanvasUIViewController.m
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostCanvasUIViewController.h"
#import "DPHostCanvasDrawObject.h"

@interface DPHostCanvasUIViewController () {
    DPHostCanvasDrawObject *_drawObject;
}

@end

@implementation DPHostCanvasUIViewController

- (void)setDrawObject: (DPHostCanvasDrawObject *)drawObject {
    _drawObject = drawObject;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_drawObject != nil) {
        [self.canvasView setDrawObject: _drawObject];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onTouchUpCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    /* view controller closed */
    [self.delegate disappearViewController];
}



@end
