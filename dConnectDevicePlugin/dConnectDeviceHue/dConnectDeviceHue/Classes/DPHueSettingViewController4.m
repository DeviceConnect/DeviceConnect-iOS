//
//  DPHueSettingViewController4.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHueSettingViewController4.h"
@interface DPHueSettingViewController4 ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lightSearchingIndicator;

@property (weak, nonatomic) IBOutlet UITableView *foundLightListView;
@property (strong, nonatomic) NSString *serial;
@property (weak, nonatomic) UIAlertAction *okAction;
- (IBAction)searchAutomatic:(id)sender;
- (IBAction)searchManual:(id)sender;



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
    cell.imageView.image = [UIImage imageNamed:path];
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
    [_lightSearchingIndicator startAnimating];
    _lightSearchingIndicator.hidden = NO;
}

-(void)stopIndicator
{
    [_lightSearchingIndicator stopAnimating];
    _lightSearchingIndicator.hidden = YES;
}


- (IBAction)searchAutomatic:(id)sender {
    [self startIndicator];
    [manager searchLightWithCompletion:^(NSArray *errors) {

        [self stopIndicator];
        
        if (!errors) {
            [self showAleart:DPHueLocalizedString(_bundle, @"HueSearchLight")];
        } else {
            [self showAleart:DPHueLocalizedString(_bundle, @"HueSearchLightError")];
        }
        [_foundLightListView reloadData];
    }];
}

- (IBAction)searchManual:(id)sender {
    UIAlertController *serialAlert = [UIAlertController alertControllerWithTitle:DPHueLocalizedString(_bundle, @"HueSerialNoTitle")
                                                                         message:DPHueLocalizedString(_bundle, @"HueSerialNoDesc")
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    [serialAlert addAction:cancelAction];
    _okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self startIndicator];
        NSArray *serials = @[_serial];
        [manager registerLightForSerialNo:serials completion:^(NSArray *errors) {
            [self stopIndicator];
            
            if (!errors) {
                [self showAleart:DPHueLocalizedString(_bundle, @"HueSearchLight")];
            } else {
                [self showAleart:DPHueLocalizedString(_bundle, @"HueSearchLightError")];
            }
            [_foundLightListView reloadData];

        }];
    }];
    _okAction.enabled = NO;
    [serialAlert addAction:_okAction];
    
    [serialAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        
        textField.placeholder = DPHueLocalizedString(_bundle, @"HueSerialNoHint");
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
    }];
    [self presentViewController:serialAlert animated:YES completion:nil];
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
@end
