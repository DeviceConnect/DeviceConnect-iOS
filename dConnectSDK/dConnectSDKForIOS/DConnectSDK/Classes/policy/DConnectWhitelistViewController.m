//
//  DConnectWhitelistViewController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DConnectWhitelistViewController.h"
#import "DConnectEditOriginViewController.h"
#import "DConnectWhitelist.h"
#import "DConnectOriginParser.h"
#import "DConnectManager.h"

@interface DConnectWhitelistViewController()
{
    NSArray *_origins;
}
- (IBAction) handleLongPress:(id)sender;
@end

@implementation DConnectWhitelistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _origins = [[DConnectWhitelist sharedWhitelist] origins];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _origins.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DConnectOriginInfo *info = _origins[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"originCell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = info.title;
    cell.detailTextLabel.text = [info.origin stringify];
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}

- (void)            tableView:(UITableView *)tableView
           commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DConnectWhitelist *whitelist = [DConnectWhitelist sharedWhitelist];
        [whitelist removeOrigin:_origins[indexPath.row]];
        _origins = [whitelist origins];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    }
}

- (IBAction) closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) didEnteredNewOriginForSegue:(UIStoryboardSegue *)segue
{
    _origins = [[DConnectWhitelist sharedWhitelist] origins];
    [self.tableView reloadData];
}

- (IBAction) handleLongPress:(id)sender
{
    UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer *) sender;
    CGPoint p = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath && recognizer.state == UIGestureRecognizerStateBegan) {
        DConnectOriginInfo *info = _origins[indexPath.row];
        DConnectEditOriginViewController *editView
        = [self.storyboard instantiateViewControllerWithIdentifier:@"originEditView"];
        editView.originInfo = info;
        editView.mode = DConnectEditOriginModeChange;
        [self.navigationController pushViewController:editView animated:YES];
    }
}

@end
