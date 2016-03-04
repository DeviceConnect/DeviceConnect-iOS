//
//  GHSettingController.m
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "GHSettingController.h"
#import "GHDataManager.h"
#import <DConnectSDK/DConnectSDK.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
@interface GHSettingController ()
@property (nonatomic, strong) NSArray* datasource;
@property (nonatomic, strong) UISwitch* managerSW;
@property (nonatomic, strong) UISwitch* blockSW;
@end


#define CELL_ID @"setting"
#define ALERT_COOKIE  100
#define ALERT_HISTORY 101


@implementation GHSettingController
//--------------------------------------------------------------//
#pragma mark - 初期化
//--------------------------------------------------------------//
- (id)initWithStyle:(UITableViewStyle)style
{
//    NSString *ip = [NSString stringWithFormat:@"Host: %@", [self myIPAddress]];
    self = [super initWithStyle:style];
    if (self) {
        self.datasource = @[@[@"DeviceConnectManager(ON/OFF)",
                              @"Port 4035",
                              @"アクセストークン削除",
                              @"Originホワイトリスト管理",
                              @"Originブロック機能"]
                            ];
        
        self.title = @"設定";

    }
    return self;
}

- (void)dealloc
{
    self.datasource = nil;
    self.managerSW   = nil;
}


//--------------------------------------------------------------//
#pragma mark - view cycle
//--------------------------------------------------------------//
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //セルの登録
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_ID];
    
//    if (![GHUtils isiPad]) {
        //ナビボタンのセット
        UIBarButtonItem* close = [[UIBarButtonItem alloc]initWithTitle:@"閉じる"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(close)];
        self.navigationItem.leftBarButtonItem = close;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)close
{
    [self updateSwitchState];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)myIPAddress
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}
//--------------------------------------------------------------//
#pragma mark - ManagerスイッチのON/OFF
//--------------------------------------------------------------//
- (void)updateSwitch:(UISwitch*)sender
{
    DConnectManager *manager = [DConnectManager sharedManager];
    if (sender.isOn) {
        [manager startByHttpServer];
    } else {
        [manager stopByHttpServer];
    }
}

//--------------------------------------------------------------//
#pragma mark - Originブロック機能のON/OFF
//--------------------------------------------------------------//
- (void)updateOriginBlockingSwitch:(UISwitch*)sender
{
    [DConnectManager sharedManager].settings.useOriginBlocking = sender.isOn;
}

///スイッチの状態を保存
- (void)updateSwitchState
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:@(self.managerSW.isOn) forKey:IS_MANAGER_LAUNCH];
    [def setObject:@(self.blockSW.isOn) forKey:IS_ORIGIN_BLOCKING];
    [def synchronize];
    
    //Cookie許可設定
    [GHUtils setCookieAccept:self.managerSW.isOn];
}

//--------------------------------------------------------------//
#pragma mark - Table view data source
//--------------------------------------------------------------//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)[self.datasource objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 2:
                //Device Connect Managerのアクセストークン削除
                [DConnectUtil showAccessTokenList];
                break;
            case 3:
                //ホワイトリスト管理
                [DConnectUtil showOriginWhitelist];
                break;
            default:
                break;
        }
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

/**
 * セルの表示内容をセット
 * @param cell 対象のセル
 * @param indexPath indexPath
 */
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                //DeviceConnectManagerのON/OFF
                if (!self.managerSW ) {
                    self.managerSW = [[UISwitch alloc]init];
                    [self.managerSW addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];
                    DConnectManager *manager = [DConnectManager sharedManager];
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    BOOL sw = [def boolForKey:IS_MANAGER_LAUNCH];
                    if (sw) {
                        [manager startByHttpServer];
                    }
                    [self.managerSW setOn:sw animated:NO];
                    
                    cell.accessoryView = self.managerSW;
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
                
            case 2:
                //Device Connect Managerのアクセストークン削除
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 3:
                //ホワイトリスト管理
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 4:
            {
                //Originブロック機能 ON/OFF
                if (!self.blockSW ) {
                    self.blockSW = [[UISwitch alloc]init];
                    [self.blockSW addTarget:self action:@selector(updateOriginBlockingSwitch:) forControlEvents:UIControlEventValueChanged];
                    
                    //スイッチの状態セット
                    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                    BOOL sw = [def boolForKey:IS_ORIGIN_BLOCKING];
                    [self.blockSW setOn:sw animated:NO];
                    
                    cell.accessoryView = self.blockSW;
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
                break;
            default:
                break;
        }
    }
}



@end
