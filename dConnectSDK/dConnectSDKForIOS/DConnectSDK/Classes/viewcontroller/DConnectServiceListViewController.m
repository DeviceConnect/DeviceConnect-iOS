//
//  DConnectServiceListViewController.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceListViewController.h>
#import <DConnectSDK/DConnectService.h>
#import "DConnectServiceListViewCell.h"

@interface DConnectServiceListViewController ()

@end

@implementation DConnectServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger rows = 0;
    if (self.delegate) {
        DConnectServiceProvider *serviceProvider = [self.delegate serviceProvider];
        if (serviceProvider) {
            rows = [serviceProvider.services count];
        }
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DConnectServiceListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell) {
        
        NSString *serviceName = @"";
        NSString *onlineStatus = @"";
        
        if (self.delegate) {
            DConnectServiceProvider *serviceProvider = [self.delegate serviceProvider];
            if (serviceProvider) {
                DConnectService *service = serviceProvider.services[indexPath.row];
                if (service) {
                    serviceName = [service name];
                    onlineStatus = [service online] ? @"Online" : @"Offline";
                }
            }
        }
        
        cell.serviceNameLabel.text = serviceName;
        cell.onlineStatusLabel.text = onlineStatus;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tapAddButton:(id)sender {
    UIViewController *setting = self.delegate.settingViewController;
    if (setting) {
        [self presentViewController:setting animated:YES completion:nil];
    }
}

- (IBAction)tapRemoveButton:(id)sender {
}

- (IBAction)tapCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
