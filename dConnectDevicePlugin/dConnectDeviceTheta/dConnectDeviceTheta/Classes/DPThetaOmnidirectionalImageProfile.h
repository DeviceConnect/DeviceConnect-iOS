//
//  DPThetaOmnidirectionalImageProfile.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/21.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import "DPOmnidirectionalImageProfile.h"
#import "DPThetaMixedReplaceMediaServer.h"
#import "DPThetaRoiDeliveryContext.h"

@interface DPThetaOmnidirectionalImageProfile : DPOmnidirectionalImageProfile<DPOmnidirectionalImageProfileDelegate,
                                        DPThetaMixedReplaceMediaServerDelegate, DPThetaRoiDeliveryContextDelegate>

@end
