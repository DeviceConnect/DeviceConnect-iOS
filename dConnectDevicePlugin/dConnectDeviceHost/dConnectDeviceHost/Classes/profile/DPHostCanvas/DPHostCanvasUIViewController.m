//
//  DPHostCanvasUIViewController.m
//  dConnectDeviceHost
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostCanvasUIViewController.h"
#import "DPHostCanvasDrawImage.h"

@interface DPHostCanvasUIViewController () {
    DPHostCanvasDrawImage *_drawImage;
}


@end

@implementation DPHostCanvasUIViewController

- (void)setDrawImage: (NSData *) data x: (double) x y: (double) y mode: (NSString *) mode {
    _drawImage = [[DPHostCanvasDrawImage alloc] initWithParameter: data x: x y: y mode: mode];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_drawImage != nil) {
        [self.canvasView setDrawObject: _drawImage];
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
