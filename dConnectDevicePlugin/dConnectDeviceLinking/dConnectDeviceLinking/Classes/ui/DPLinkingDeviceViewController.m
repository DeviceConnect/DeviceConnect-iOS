//
//  DPLinkingDeviceViewController.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceViewController.h"

@interface DPLinkingDeviceViewController () <DPLinkingDeviceConnectDelegate, DPLinkingDeviceSensorDelegate, DPLinkingDeviceButtonIdDelegate, DPLinkingDeviceRangeDelegate, DPLinkingDeviceBatteryDelegate, DPLinkingDeviceTemperatureDelegate, DPLinkingDeviceHumidityDelegate, DPLinkingDeviceAtmosphericPressureDelegate>

@property (nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic) IBOutlet UIButton *ledPatternButton;
@property (nonatomic) IBOutlet UIButton *ledColorButton;
@property (nonatomic) IBOutlet UIButton *vibrationPatternButton;
@property (nonatomic) IBOutlet UIButton *ledOnButton;
@property (nonatomic) IBOutlet UIButton *ledOffButton;
@property (nonatomic) IBOutlet UIButton *vibrationOnButton;
@property (nonatomic) IBOutlet UIButton *vibrationOffButton;
@property (nonatomic) IBOutlet UIButton *sensorOnButton;
@property (nonatomic) IBOutlet UIButton *sensorOffButton;
@property (nonatomic) IBOutlet UIButton *batteryOnButton;
@property (nonatomic) IBOutlet UIButton *batteryOffButton;
@property (nonatomic) IBOutlet UIButton *atmosphericPressureOnButton;
@property (nonatomic) IBOutlet UIButton *atmosphericPressureOffButton;
@property (nonatomic) IBOutlet UIButton *temperatureOnButton;
@property (nonatomic) IBOutlet UIButton *temperatureOffButton;
@property (nonatomic) IBOutlet UIButton *humidityOnButton;
@property (nonatomic) IBOutlet UIButton *humidityOffButton;
@property (nonatomic) IBOutlet UIButton *buttonIdOnButton;
@property (nonatomic) IBOutlet UIButton *buttonIdOffButton;
@property (nonatomic) IBOutlet UILabel *rangeLogLabel;
@property (nonatomic) IBOutlet UITextView *buttonLogView;

@property (nonatomic) IBOutlet UILabel *gryoXLabel;
@property (nonatomic) IBOutlet UILabel *gryoYLabel;
@property (nonatomic) IBOutlet UILabel *gryoZLabel;

@property (nonatomic) IBOutlet UILabel *accelerationXLabel;
@property (nonatomic) IBOutlet UILabel *accelerationYLabel;
@property (nonatomic) IBOutlet UILabel *accelerationZLabel;

@property (nonatomic) IBOutlet UILabel *compassXLabel;
@property (nonatomic) IBOutlet UILabel *compassYLabel;
@property (nonatomic) IBOutlet UILabel *compassZLabel;

@property (nonatomic) IBOutlet UILabel *batteryLabel;
@property (nonatomic) IBOutlet UILabel *humidityLabel;
@property (nonatomic) IBOutlet UILabel *temperatureLabel;
@property (nonatomic) IBOutlet UILabel *atmosphericPressureLabel;

@end

@implementation DPLinkingDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.deviceNameLabel.text = self.device.name;
    self.navigationItem.title = @"デバイス確認";

    [self setTitleForLedColorButton];
    [self setTitleForLedPatternButton];
    [self setTitleForVibrationPatternButton];
    [self setLEDOnOffButton];
    [self setVibrationOnOffButton];
    [self setSensorOnOffButton];
    [self setBatteryOnOffButton];
    [self setTemperatureOnOffButton];
    [self setHumidityOnOffButton];
    [self setButtonIdOnOffButton];
    [self setAtmosphericPressureOnOffButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [self.deviceManager addConnectDelegate:self];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.deviceManager removeConnectDelegate:self];
    
    [self.deviceManager disableListenSensor:self.device delegate:self];
    [self.deviceManager disableListenBattery:self.device delegate:self];
    [self.deviceManager disableListenTemperature:self.device delegate:self];
    [self.deviceManager disableListenHumidity:self.device delegate:self];
    [self.deviceManager disableListenRange:self.device delegate:self];
    [self.deviceManager disableListenButtonId:self.device delegate:self];
    [self.deviceManager disableListenAtmosphericPressure:self.device delegate:self];
}

#pragma mark - Private Method

- (void) setTitleForLedColorButton {
    if ([self.device isSupportLED]) {
        NSNumber *index = self.device.setting.settingInformationDataLED[@"settingColorNumber"];
        NSArray *colorList = [[[BLERequestController sharedInstance] getSettingName:self.device.peripheral settingNameType:LEDColorName] mutableCopy];
        [self.ledColorButton setTitle:colorList[[index integerValue] - 1] forState:UIControlStateNormal];
    } else {
        self.ledColorButton.enabled = NO;
        [self.ledColorButton setTitle:@"未設定" forState:UIControlStateNormal];
    }
}

- (void) setTitleForLedPatternButton {
    if ([self.device isSupportLED]) {
        NSNumber *index = self.device.setting.settingInformationDataLED[@"settingPatternNumber"];
        NSArray *patternList = [[[BLERequestController sharedInstance] getSettingName:self.device.peripheral settingNameType:LEDPatternName] mutableCopy];
        [self.ledPatternButton setTitle:patternList[[index integerValue] - 1] forState:UIControlStateNormal];
    } else {
        self.ledPatternButton.enabled = NO;
        [self.ledPatternButton setTitle:@"未設定" forState:UIControlStateNormal];
    }
}

- (void) setTitleForVibrationPatternButton {
    if ([self.device isSupportVibration]) {
        NSNumber *index = self.device.setting.settingInformationDataVibration[@"settingPatternNumber"];
        NSArray *patternList = [[[BLERequestController sharedInstance] getSettingName:self.device.peripheral settingNameType:VibrationPatternName] mutableCopy];
        [self.vibrationPatternButton setTitle:patternList[[index integerValue] - 1] forState:UIControlStateNormal];
    } else {
        self.vibrationPatternButton.enabled = NO;
        [self.vibrationPatternButton setTitle:@"未設定" forState:UIControlStateNormal];
    }
}

- (void) setLEDOnOffButton {
    if (![self.device isSupportLED]) {
        self.ledOnButton.enabled = NO;
        self.ledOffButton.enabled = NO;
    }
}

- (void) setVibrationOnOffButton {
    if (![self.device isSupportVibration]) {
        self.vibrationOnButton.enabled = NO;
        self.vibrationOffButton.enabled = NO;
    }
}

- (void) setSensorOnOffButton {
    if (![self.device isSupportSensor]) {
        self.sensorOnButton.enabled = NO;
        self.sensorOffButton.enabled = NO;
    }
}

- (void) setBatteryOnOffButton {
    if (![self.device isSupportBattery]) {
        self.batteryOnButton.enabled = NO;
        self.batteryOffButton.enabled = NO;
    }
}

- (void) setTemperatureOnOffButton {
    if (![self.device isSupportTemperature]) {
        self.temperatureOnButton.enabled = NO;
        self.temperatureOffButton.enabled = NO;
    }
}

- (void) setHumidityOnOffButton {
    if (![self.device isSupportHumidity]) {
        self.humidityOnButton.enabled = NO;
        self.humidityOffButton.enabled = NO;
    }
}

- (void) setAtmosphericPressureOnOffButton {
    if (![self.device isSupportAtmosphericPressure]) {
        self.atmosphericPressureOnButton.enabled = NO;
        self.atmosphericPressureOffButton.enabled = NO;
    }
}

- (void) setButtonIdOnOffButton {
    if (![self.device isSupportButtonId]) {
        self.buttonIdOnButton.enabled = NO;
        self.buttonIdOffButton.enabled = NO;
    }
}

- (void) setLedPattern:(NSUInteger)index {
    self.device.setting.settingInformationDataLED[@"settingPatternNumber"] = @(index);
    [self.deviceManager setDefaultLED:self.device];
    [self setTitleForLedPatternButton];
}

- (void) setLedColor:(NSUInteger)index {
    self.device.setting.settingInformationDataLED[@"settingColorNumber"] = @(index);
    [self.deviceManager setDefaultLED:self.device];
    [self setTitleForLedColorButton];
}

- (void) setVibrationPattern:(NSUInteger)index {
    self.device.setting.settingInformationDataVibration[@"settingPatternNumber"] = @(index);
    [self.deviceManager setDefaultVibration:self.device];
    [self setTitleForVibrationPatternButton];
}

- (void) openLEDPatternDialog {
    __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"パターン選択"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *patternList = [[[BLERequestController sharedInstance] getSettingName:self.device.peripheral settingNameType:LEDPatternName] mutableCopy];
    [patternList enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self setLedPattern:idx + 1];
                                                       }];
        [alert addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"キャンセル"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openLEDColorDialog {
    __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"色選択"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *colorList = [[[BLERequestController sharedInstance] getSettingName:self.device.peripheral settingNameType:LEDColorName] mutableCopy];
    [colorList enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self setLedColor:idx + 1];
                                                       }];
        [alert addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"キャンセル"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openVibrationPatternDialog {
    __block UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"バイブレーション選択"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *patternList = [[[BLERequestController sharedInstance] getSettingName:self.device.peripheral settingNameType:VibrationPatternName] mutableCopy];
    [patternList enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self setVibrationPattern:idx + 1];
                                                       }];
        [alert addAction:action];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"キャンセル"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) openDisconnectDeviceDialog {
    __block DPLinkingDeviceViewController *_self = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告"
                                                                   message:@"デバイスが切断されました。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [_self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void) openNotSupportDialog:(NSString *)msg {
    __block DPLinkingDeviceViewController *_self = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [_self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    return cell;
}

#pragma mark - DPLinkingDeviceConnectDelegate

- (void) didDiscoveryPeripheral:(CBPeripheral *)peripheral {
}

- (void) didConnectedDevice:(DPLinkingDevice *)device {
}

- (void) didFailToConnectDevice:(DPLinkingDevice *)device {
}

- (void) didDisonnectedDevice:(DPLinkingDevice *)device {
    [self openDisconnectDeviceDialog];
}

#pragma mark - DPLinkingDeviceSensorDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device sensor:(DPLinkingSensorData *)data {
    switch (data.type) {
        case DPLinkingSensorTypeAccelerometer:
            self.accelerationXLabel.text = [NSString stringWithFormat:@"x: %f", data.x];
            self.accelerationYLabel.text = [NSString stringWithFormat:@"y: %f", data.y];
            self.accelerationZLabel.text = [NSString stringWithFormat:@"z: %f", data.z];
            break;
        case DPLinkingSensorTypeGyroscope:
            self.gryoXLabel.text = [NSString stringWithFormat:@"x: %f", data.x];
            self.gryoYLabel.text = [NSString stringWithFormat:@"y: %f", data.y];
            self.gryoZLabel.text = [NSString stringWithFormat:@"z: %f", data.z];
            break;
        case DPLinkingSensorTypeOrientation:
            self.compassXLabel.text = [NSString stringWithFormat:@"x: %f", data.x];
            self.compassYLabel.text = [NSString stringWithFormat:@"y: %f", data.y];
            self.compassZLabel.text = [NSString stringWithFormat:@"z: %f", data.z];
            break;
        default:
            break;
    }
}

#pragma mark - DPLinkingDeviceButtonIdDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device buttonId:(int)buttonId {
    if ([self.device isEqual:device]) {
        NSString *text = self.buttonLogView.text;
        self.buttonLogView.text = [NSString stringWithFormat:@"ButtonId:[%d]\n%@", buttonId, text];
    }
}

#pragma mark - DPLinkingDeviceRangeDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device range:(DPLinkingRange)range {
    switch (range) {
        case DPLinkingRangeImmediate:
            self.rangeLogLabel.text = @"IMMEDIATE";
            break;
        case DPLinkingRangeNear:
            self.rangeLogLabel.text = @"NEAR";
            break;
        case DPLinkingRangeFar:
            self.rangeLogLabel.text = @"FAR";
            break;
    }
}

#pragma mark - DPLinkingDeviceBatteryDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device lowBattery:(BOOL)lowBattery level:(float)level {
    self.batteryLabel.text = [NSString stringWithFormat:@"%@", @(level)];
}

#pragma mark - DPLinkingDeviceTemperatureDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device temperature:(float)temperature {
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@℃", @(temperature)];
}

#pragma mark - DPLinkingDeviceHumidityDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device humidity:(float)humidity {
    self.humidityLabel.text = [NSString stringWithFormat:@"%@%%", @(humidity)];
}

#pragma mark - DPLinkingDeviceAtmosphericPressureDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device atmosphericPressure:(float)atmosphericPressure {
    self.atmosphericPressureLabel.text = [NSString stringWithFormat:@"%@", @(atmosphericPressure)];
}

#pragma mark - IBAction

- (IBAction) ledPatternButtonTap:(id)sender {
    if ([self.device isSupportLED]) {
        [self openLEDPatternDialog];
    } else {
        [self openNotSupportDialog:@"LEDはサポートしていません。"];
    }
}

- (IBAction) ledColorButtonTap:(id)sender {
    if ([self.device isSupportLED]) {
        [self openLEDColorDialog];
    } else {
        [self openNotSupportDialog:@"LEDはサポートしていません。"];
    }
}

- (IBAction) vibrationPatternButtonTap:(id)sender {
    if ([self.device isSupportVibration]) {
        [self openVibrationPatternDialog];
    } else {
        [self openNotSupportDialog:@"バイブレーションはサポートしていません。"];
    }
}

- (IBAction) ledOnButtonTap:(id)sender {
    if ([self.device isSupportLED]) {
        [self.deviceManager sendLEDCommand:self.device power:YES];
    } else {
        [self openNotSupportDialog:@"LEDはサポートしていません。"];
    }
}

- (IBAction) ledOffButtonTap:(id)sender {
    if ([self.device isSupportLED]) {
        [self.deviceManager sendLEDCommand:self.device power:NO];
    } else {
        [self openNotSupportDialog:@"LEDはサポートしていません。"];
    }
}

- (IBAction) vibrationOnButtonTap:(id)sender {
    if ([self.device isSupportVibration]) {
        [self.deviceManager sendVibrationCommand:self.device power:YES];
    } else {
        [self openNotSupportDialog:@"バイブレーションはサポートしていません。"];
    }
}

- (IBAction) vibrationOffButtonTap:(id)sender {
    if ([self.device isSupportVibration]) {
        [self.deviceManager sendVibrationCommand:self.device power:NO];
    } else {
        [self openNotSupportDialog:@"バイブレーションはサポートしていません。"];
    }
}

- (IBAction) sensorRegisterButtonTap:(id)sender {
    if ([self.device isSupportSensor]) {
        [self.deviceManager enableListenSensor:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"センサーはサポートしていません。"];
    }
}

- (IBAction) sensorUnregisterButtonTap:(id)sender {
    if ([self.device isSupportSensor]) {
        [self.deviceManager disableListenSensor:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"センサーはサポートしていません。"];
    }
}

- (IBAction)batteryRegisterButtonTap:(id)sender {
    if ([self.device isSupportBattery]) {
        [self.deviceManager enableListenBattery:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"バッテリーセンサーはサポートしていません。"];
    }
}

- (IBAction)batteryUnregisterButtonTap:(id)sender {
    if ([self.device isSupportBattery]) {
        [self.deviceManager disableListenBattery:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"バッテリーセンサーはサポートしていません。"];
    }
}

- (IBAction)temperatureRegisterButtonTap:(id)sender {
    if ([self.device isSupportTemperature]) {
        [self.deviceManager enableListenTemperature:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"気温センサーはサポートしていません。"];
    }
}

- (IBAction)temperatureUnregisterButtonTap:(id)sender {
    if ([self.device isSupportTemperature]) {
        [self.deviceManager disableListenTemperature:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"気温センサーはサポートしていません。"];
    }
}

- (IBAction)atmosphericPressureRegisterButtonTap:(id)sender {
    if ([self.device isSupportAtmosphericPressure]) {
        [self.deviceManager enableListenAtmosphericPressure:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"気圧センサーはサポートしていません。"];
    }
}

- (IBAction)atmosphericPressureUnregisterButtonTap:(id)sender {
    if ([self.device isSupportAtmosphericPressure]) {
        [self.deviceManager disableListenAtmosphericPressure:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"気圧センサーはサポートしていません。"];
    }
}


- (IBAction)humidityRegisterButtonTap:(id)sender {
    if ([self.device isSupportHumidity]) {
        [self.deviceManager enableListenHumidity:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"湿度センサーはサポートしていません。"];
    }
}

- (IBAction)humidityUnregisterButtonTap:(id)sender {
    if ([self.device isSupportHumidity]) {
        [self.deviceManager disableListenHumidity:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"湿度センサーはサポートしていません。"];
    }
}

- (IBAction) rangeRegisterButtonTap:(id)sender {
    [self.deviceManager enableListenRange:self.device delegate:self];
}

- (IBAction) rangeUnregisterButtonTap:(id)sender {
    [self.deviceManager disableListenRange:self.device delegate:self];
}

- (IBAction) buttonIdRegisterButtonTap:(id)sender {
    if ([self.device isSupportButtonId]) {
        [self.deviceManager enableListenButtonId:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"ButtonIdはサポートしていません。"];
    }
}

- (IBAction) buttonIdUnregisterButtonTap:(id)sender {
    if ([self.device isSupportButtonId]) {
        [self.deviceManager disableListenButtonId:self.device delegate:self];
    } else {
        [self openNotSupportDialog:@"ButtonIdはサポートしていません。"];
    }
}

@end
