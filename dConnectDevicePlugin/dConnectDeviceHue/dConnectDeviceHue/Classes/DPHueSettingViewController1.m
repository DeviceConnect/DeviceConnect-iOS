//
//  DPHueSettingViewController1.m
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueSettingViewController1.h"
#import <HueSDK_iOS/HueSDK.h>
#import "DPHueItemBridge.h"

@interface DPHueSettingViewController1 ()
@property (nonatomic) NSMutableArray *bridgeItems;
@property (weak, nonatomic) IBOutlet UITableView *bridgeListTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchingBridgeIndicator;
@property (weak, nonatomic) IBOutlet UIView *searchingView;
@property (weak, nonatomic) IBOutlet UILabel *processingLabel;


#pragma mark - Portrait Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portCenterTopX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portCenterMiddleX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portBottomRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *portBottomBottom;
#pragma mark - Landscape Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landLeftCenterY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landRightRight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landRightTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landLeftBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landLeftBottomBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landImageLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landMessageLeft;

@end

@implementation DPHueSettingViewController1

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initItems];
    
}

- (void)initItems
{
    _bridgeItems = nil;
    _bridgeItems = [[NSMutableArray alloc] init];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([super iphone]) {
        portConstraints = [NSArray arrayWithObjects:
                               _portCenterTopX, _portCenterMiddleX,  _portBottomRight, _portBottomBottom, nil];

        landConstraints = [NSArray arrayWithObjects:
                           _landLeftCenterY,
                           _landRightRight,
                           _landRightTop,
                           _landLeftBottom,
                           _landLeftBottomBottom,
                           _landImageLeft,
                           _landMessageLeft, nil];
    } else {
        portConstraints = [NSArray arrayWithObjects:
                           _portCenterTopX, _portCenterMiddleX, _portBottomBottom, nil];
        
        landConstraints = [NSArray arrayWithObjects:
                           _landRightRight,
                           _landRightTop, nil];
    }
    _bridgeListTableView.delegate = self;
    _bridgeListTableView.dataSource = self;

    [self searchBridge];

}

- (IBAction)searchHueBridge:(id)sender {
    [self searchBridge];
}

- (void)searchBridge
{
    _processingLabel.text = DPHueLocalizedString(_bundle, @"HueBridgeSearch");
    [self startIndicator];
    
    [self initSelectedItemBridge];
    [self initItems];
    [_bridgeListTableView reloadData];

    [manager searchBridgeWithCompletion:^(NSDictionary *bridgesFound) {
        // Check for results
        if (bridgesFound.count > 0) {
            for (id key in [bridgesFound keyEnumerator]) {
                [self addItem:bridgesFound[key] macAdress:key];
            }
        }
        [self stopIndicator];
    }];
}

//縦向き座標調整
- (void)setLayoutConstraintPortrait
{
    if ([super iphone]) {
        if ([super iphone5]) {
            _portBottomRight.constant = 35;
        } else if ([super iphone6]) {
            _portBottomRight.constant = 60;
        } else if ([super iphone6p]) {
            _portBottomRight.constant = 80;
            _portBottomBottom.constant = 80;
        }
    } else {
        if ([super ipadMini]) {
            _landImageLeft.constant = 214;
        } else {
            _landImageLeft.constant = 350;
        }
    }
}

//横向き座標調整
- (void)setLayoutConstraintLandscape
{
    if ([super iphone]) {
        if ([super iphone5]) {
            _landRightRight.constant = 29;
            _landRightTop.constant = 33;
        } else if ([super iphone6]) {
            _landRightRight.constant = 70;
            _landRightTop.constant = 15;
        } else if ([super iphone6p]) {
            _landRightRight.constant = 140;
            _landRightTop.constant = 5;
        }
    } else {
        if ([super ipadMini]) {
            _landImageLeft.constant = 80;
        } else {
            _landImageLeft.constant = 220;
        }

    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.bridgeItems.count;
}

// セルの生成と設定
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Storyboard で設定したidentifier
    static NSString *CellIdentifier = @"cellBridge";
    // 再利用セルを取得する。
    // 再利用可能なセルがない場合には新しく生成されたインスタンスが返される。
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    // セルを設定する
    DPHueItemBridge *item = self.bridgeItems[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n ( %@ )",item.bridgeId ,item.ipAddress];
    return cell;
}

// セルの編集可否を指定
- (BOOL)    tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark Table view delegate
// セル選択時の処理
- (void)        tableView:(UITableView *)tableView
  didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DPHueItemBridge *item = self.bridgeItems[indexPath.row];
    [self selectNextPage:item];
}


#pragma mark - actions
- (void)addItem:(NSString*)ipAdress
      macAdress:(NSString*)macAdress {
    DPHueItemBridge *newItem = [[DPHueItemBridge alloc] init];
    
    newItem.ipAddress = ipAdress;
    newItem.bridgeId = macAdress;
    
    NSIndexPath *indexPathToInsert =
    [NSIndexPath indexPathForRow:self.bridgeItems.count inSection:0];

    [self.bridgeItems addObject:newItem];
    // テーブルビューの更新
    [_bridgeListTableView insertRowsAtIndexPaths:@[indexPathToInsert]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)selectNextPage:(DPHueItemBridge*)selectedItemBridge {

    [self setSelectedItemBridge:selectedItemBridge];
    _processingLabel.text = DPHueLocalizedString(_bundle, @"HueBridgeConnecting");
    [self startIndicator];
    [manager startAuthenticateBridgeWithIpAddress:selectedItemBridge.ipAddress
                                       bridgeId:selectedItemBridge.bridgeId
                                        receiver:self
                   localConnectionSuccessSelector:@selector(didLocalConnectionSuccess)
                                noLocalConnection:@selector(didNoLocalConnection)
                                 notAuthenticated:@selector(didNotAuthenticated)
    ];
}


-(void)didLocalConnectionSuccess {
    [self stopIndicator];
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
            [[DPHueManager sharedManager] deallocHueSDK];
        });
    });

    //接続できたのでライト検索へ飛ぶ
    [self showLightSearchPage];
    
}

- (void)didNoLocalConnection {
    [self stopIndicator];
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
            [[DPHueManager sharedManager] deallocHueSDK];
        });
    });

    [self showAleart:DPHueLocalizedString(_bundle, @"HueNotConnectingBridge")];
}

-(void)didNotAuthenticated {
    [self stopIndicator];
    dispatch_queue_t updateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(updateQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[DPHueManager sharedManager] deallocPHNotificationManagerWithReceiver:self];
            [[DPHueManager sharedManager] deallocHueSDK];
        });
    });

    [self showAuthPage];
}

-(void)startIndicator
{
    [_searchingBridgeIndicator startAnimating];
    _searchingView.hidden = NO;
}

-(void)stopIndicator
{
    [_searchingBridgeIndicator stopAnimating];
    _searchingView.hidden = YES;
}

@end
