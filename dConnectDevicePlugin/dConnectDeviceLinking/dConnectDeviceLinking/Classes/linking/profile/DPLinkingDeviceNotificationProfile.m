//
//  DPLinkingDeviceNotificationProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceNotificationProfile.h"
#import "DPLinkingDeviceManager.h"

@implementation DPLinkingDeviceNotificationProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        NSString *postNotifyRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectNotificationProfileAttrNotify];
        [self addPostPath: postNotifyRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          return [_self onPostNotify:request response:response];
                      }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onPostNotify:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSNumber *type = [DConnectNotificationProfile typeFromRequest:request];
    NSString *body = [DConnectNotificationProfile bodyFromRequest:request];
    NSString *serviceId = [request serviceId];
    
    if (!body) {
        [response setErrorToInvalidRequestParameterWithMessage:@"body is null."];
        return YES;
    }

    if (!type || type.intValue < 0 || 3 < type.intValue) {
        [response setErrorToInvalidRequestParameterWithMessage:@"type is null or invalid."];
        return YES;
    }

    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToInvalidRequestParameterWithMessage:@"serviceId is invalid."];
        return YES;
    }

    NSString *title = @"EVENT";
    switch ([type intValue]) {
        case DConnectNotificationProfileNotificationTypePhone:
            title = @"PHONE";
            break;
        case DConnectNotificationProfileNotificationTypeMail:
            title = @"MAIL";
            break;
        case DConnectNotificationProfileNotificationTypeSMS:
            title = @"SMS";
            break;
        case DConnectNotificationProfileNotificationTypeEvent:
            title = @"EVENT";
            break;
        default:
            [response setErrorToInvalidRequestParameterWithMessage:@"Not support type"];
            return YES;
    }
    
    [deviceMgr sendNotification:device title:title message:body];
    
    [response setString:@"0" forKey:DConnectNotificationProfileParamNotificationId];
    [response setResult:DConnectMessageResultTypeOk];

    return YES;
}

@end
