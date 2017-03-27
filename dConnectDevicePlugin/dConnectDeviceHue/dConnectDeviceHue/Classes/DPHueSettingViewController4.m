//
//  DPHueSettingViewController4.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHueSettingViewController4.h"

#define PutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
top = top.presentedViewController; \
}
@interface DPHueSettingViewController4 () {
    int lightCount;
    int retryCount;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lightSearchingIndicator;
@property (weak, nonatomic) IBOutlet UIView *indicator;

@property (weak, nonatomic) IBOutlet UITableView *foundLightListView;
@property (strong, nonatomic) NSString *serial;
@property (weak, nonatomic) UIAlertAction *okAction;

- (IBAction)searchAutomatic:(id)sender;
- (IBAction)searchManual:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *autoSearchBtn;
@property (weak, nonatomic) IBOutlet UIButton *manualSearchBtn;


@end

@implementation DPHueSettingViewController4

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _foundLightListView.delegate = self;
    _foundLightListView.dataSource = self;
    [_foundLightListView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellLight"];
    [_foundLightListView reloadData];
    if ([_foundLightListView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_foundLightListView setSeparatorInset:UIEdgeInsetsZero];
    }
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 4.;
    };
    roundCorner(_indicator);
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[DPHueManager sharedManager] getLightStatus].count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
}

// セルの生成と設定
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Storyboard で設定したidentifier
    static NSString *CellIdentifier = @"cellLight";
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    cell.exclusiveTouch = YES;
    cell.accessoryView.exclusiveTouch = YES;
    NSString * path = [_bundle pathForResource:@"hue_small_icon" ofType:@"png"];
    cell.imageView.image = [UIImage imageWithContentsOfFile:path];
    NSDictionary* dic = [[DPHueManager sharedManager] getLightStatus];
    int i = 0;
    for (PHLight *light in dic.allValues) {
        if (indexPath.row == i) {
            
            cell.textLabel.text = light.name;
            break;
        }
        i++;
    }
    return cell;
}

-(void)startIndicator
{
    _lightSearchingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_lightSearchingIndicator.layer setValue:[NSNumber numberWithFloat:1.39f] forKeyPath:@"transform.scale"];

    [_lightSearchingIndicator startAnimating];
    _lightSearchingIndicator.hidden = NO;
    _autoSearchBtn.enabled = NO;
    _manualSearchBtn.enabled = NO;
    [super setCloseBtn:NO];
}

-(void)stopIndicator
{
    [_lightSearchingIndicator stopAnimating];
    _lightSearchingIndicator.hidden = YES;
    _autoSearchBtn.enabled = YES;
    _manualSearchBtn.enabled = YES;
    [super setCloseBtn:YES];
}


- (IBAction)searchAutomatic:(id)sender {
    _indicator.hidden = NO;
    retryCount = 2;
    [self startIndicator];
    [manager searchLightWithCompletion:^(NSArray *errors) {
        dispatch_async(dispatch_get_main_queue(), ^{
            lightCount = (int) [[DPHueManager sharedManager] getLightStatus].allValues.count;
            [self reloadHue];
        });
    }];
}

- (IBAction)searchManual:(id)sender {
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (osVersion > 8.0) {
        UIAlertController *serialAlert = [UIAlertController alertControllerWithTitle:DPHueLocalizedString(_bundle, @"HueSerialNoTitle")
                                                                             message:DPHueLocalizedString(_bundle, @"HueSerialNoDesc")
                                                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
        [serialAlert addAction:cancelAction];
        _okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            _indicator.hidden = NO;
            [self startIndicator];
            NSArray *serials = @[_serial];
            [manager registerLightForSerialNo:serials completion:^(NSArray *errors) {
                retryCount = 2;
                lightCount = (int) [[DPHueManager sharedManager] getLightStatus].allValues.count;
                [self  reloadHue];
            }];
        }];
        _okAction.enabled = NO;
        [serialAlert addAction:_okAction];

        [serialAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            
            textField.placeholder = DPHueLocalizedString(_bundle, @"HueSerialNoHint");
            textField.delegate = self;
            textField.keyboardType = UIKeyboardTypeAlphabet;
        }];
        [self presentViewController:serialAlert animated:YES completion:nil];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:DPHueLocalizedString(_bundle, @"HueSerialNoTitle")
                                                        message:DPHueLocalizedString(_bundle, @"HueSerialNoDesc")
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
        alert.delegate       = self;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].placeholder = DPHueLocalizedString(_bundle, @"HueSerialNoHint");
        [alert textFieldAtIndex:0].delegate = self;
        [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeAlphabet;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == alertView.cancelButtonIndex ) { return; }
    
    NSString* textValue = [[alertView textFieldAtIndex:0] text];
    if( [textValue length] >= 6 )
    {
        _indicator.hidden = NO;
        [self startIndicator];
        NSArray *serials = @[textValue];
        [manager registerLightForSerialNo:serials completion:^(NSArray *errors) {
            retryCount = 2;
            lightCount = (int) [[DPHueManager sharedManager] getLightStatus].allValues.count;
            [self  reloadHue];
        }];
    }
}


- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *text = [textField.text mutableCopy];
    [text replaceCharactersInRange:range withString:string];
    if ([text length] >= 6) {
        _okAction.enabled = YES;
        _serial = text;
    }
    return ([text length] <= 6);
}


- (void)reloadHue
{
    
    DPHueItemBridge *item = [self getSelectedItemBridge];
    [[DPHueManager sharedManager] initHue];
    [[DPHueManager sharedManager] startAuthenticateBridgeWithIpAddress:item.ipAddress
                                                            bridgeId:item.bridgeId
                                                              receiver:self
                                        localConnectionSuccessSelector:@selector(didBridgeSuccess)
                                                     noLocalConnection:@selector(didBridgeFailed)
                                                      notAuthenticated:@selector(didBridgeFailed)];
}

- (void)didBridgeSuccess
{
    [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
    [[DPHueManager sharedManager] deallocHueSDK];
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (retryCount < 0 || lightCount < [[DPHueManager sharedManager] getLightStatus].allValues.count) {
                [_foundLightListView reloadData];
                _indicator.hidden = YES;
                [self stopIndicator];
                if (lightCount < [[DPHueManager sharedManager] getLightStatus].allValues.count) {
                    NSString *successMessage = [DPHueLocalizedString(_bundle, @"HueSearchLight")
                                                stringByAppendingFormat:DPHueLocalizedString(_bundle, @"HueSearchHitLight"),
                                                [[DPHueManager sharedManager] getLightStatus].allValues.count - lightCount];
                    [self showAleart:successMessage];
                } else {
                    [self showAleart:DPHueLocalizedString(_bundle, @"HueSearchLightOld")];
                }
            } else {
                retryCount--;
                [self reloadHue];
            }
        });
    });
}

- (void)didBridgeFailed
{
    [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
    [[DPHueManager sharedManager] deallocHueSDK];
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
            [[DPHueManager sharedManager] deallocHueSDK];
            [_foundLightListView reloadData];
            _indicator.hidden = YES;
            [self stopIndicator];
            [self showAleart:DPHueLocalizedString(_bundle, @"HueSearchLightError")];
        });
    });
}

@end
