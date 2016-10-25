//
//  DPAWSIoTAuthViewController.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTAuthViewController.h"
#import "DPAWSIoTController.h"
#import "DPAWSIoTAuthListCell.h"
#import "DConnectMessage+Private.h"
#import "DPAWSIoTUtils.h"

@interface DPAWSIoTAuthViewController () {
	DConnectArray *_services;
}

@end

@implementation DPAWSIoTAuthViewController

- (void)viewDidLoad {
	[DPAWSIoTUtils fetchServicesWithHandler:^(DConnectResponseMessage *response) {
		_services = response.internalDictionary[@"services"];
		[self.tableView reloadData];
	}];
}

#pragma mark - UITableView

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _services.count;
}

// テーブル内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DPAWSIoTAuthListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	DConnectMessage *msg = [_services objectAtIndex:indexPath.row];
	cell.msg = msg;
	return cell;
}

@end
