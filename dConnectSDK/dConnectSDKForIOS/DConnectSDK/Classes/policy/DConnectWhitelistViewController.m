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
#import "DConnectWhitelist.h"
#import "DConnectOriginParser.h"

@interface DConnectWhitelistViewController()
{
    NSArray *_origins;
}
@end

@implementation DConnectWhitelistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _origins = [[DConnectWhitelist sharedWhitelist] origins];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _origins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"originCell";
    DConnectWhitelistCell *cell =
        (DConnectWhitelistCell*) [tableView dequeueReusableCellWithIdentifier:cellId
                                                                 forIndexPath:indexPath];
    
    DConnectOriginInfo *info = _origins[indexPath.row];
    [cell.titleLabel setText:info.title];
    [cell.originLabel setText:[info.origin stringify]];
    
    return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)            tableView:(UITableView *)tableView
           commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (IBAction) closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) didEnteredNewOriginForSegue:(UIStoryboardSegue *)segue
{
    _origins = [[DConnectWhitelist sharedWhitelist] origins];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_origins.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationNone];
}

@end


@implementation DConnectWhitelistCell

@end