//
//  DPAllJoynSettingMasterSubTableViewController.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynSettingMasterSubTableViewController.h"

#import "DPAllJoynSettingTableViewCell.h"


// #############################################################################
// Interfaces
// #############################################################################
#pragma mark - Interfaces


@interface DPAllJoynSettingMasterSubTableViewController ()
<UITableViewDataSource, UITableViewDelegate>
@end


// #############################################################################
#pragma mark -


@interface DPAllJoynSettingMasterTutorialData : NSObject

@property NSString *cellImageName;
@property NSString *cellImageExtension;
@property NSString *segueID;

+ (instancetype) dataWithCellImageName:(NSString *)cellImageName
                    cellImageExtension:(NSString *)cellImageExt
                               segueID:(NSString *)segueID;
@end


// #############################################################################
// Implementations
// #############################################################################
#pragma mark - Implementations


@implementation DPAllJoynSettingMasterSubTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Fix a strange, extra left margin of table view's separator.
    //
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    self.tableView.estimatedRowHeight = 55;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


+ (NSArray *)settingTutorials
{
    static NSArray *settingTutorials;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingTutorials =
        @[[DPAllJoynSettingMasterTutorialData dataWithCellImageName:@"LIFX_Logo@2"
                                                 cellImageExtension:@"jpg"
                                                            segueID:@"tutorialLIFX"]];
    });
    return settingTutorials;
}


// =============================================================================
#pragma mark UITableViewDataSource


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DPAllJoynSettingMasterTutorialData *data =
    [DPAllJoynSettingMasterSubTableViewController settingTutorials][indexPath.row];
    DPAllJoynSettingTableViewCell *cell =
    (DPAllJoynSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"imageItem"];
    NSBundle *bundle = DPAllJoynResourceBundle();
    NSString *path = [bundle pathForResource:data.cellImageName
                                      ofType:data.cellImageExtension];
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    cell.mainImageView.image = [UIImage imageWithContentsOfFile:path];
    
//    [cell updateConstraintsIfNeeded];
    [cell.mainImageView sizeToFit];
    [cell.mainImageView layoutIfNeeded];
    
    // Fix a strange, extra left margin of table view's separator.
    //
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [DPAllJoynSettingMasterSubTableViewController settingTutorials].count;
}


// =============================================================================
#pragma mark UITableViewDelegate


- (NSArray *)      tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DPAllJoynSettingMasterTutorialData *data =
    [DPAllJoynSettingMasterSubTableViewController settingTutorials][indexPath.row];
    [self.parentViewController
     performSegueWithIdentifier:data.segueID sender:nil];
}

@end


// #############################################################################
#pragma mark -


@implementation DPAllJoynSettingMasterTutorialData

+ (instancetype) dataWithCellImageName:(NSString *)cellImageName
                    cellImageExtension:(NSString *)cellImageExt
                               segueID:(NSString *)segueID
{
    DPAllJoynSettingMasterTutorialData *instance = [self new];
    if (instance) {
        instance.cellImageName = cellImageName;
        instance.cellImageExtension = cellImageExt;
        instance.segueID = segueID;
    }
    return instance;
}

@end
