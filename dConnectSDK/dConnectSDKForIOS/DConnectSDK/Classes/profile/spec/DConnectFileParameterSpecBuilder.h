//
//  DConnectFileParameterSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectParameterSpecBaseBuilder.h"
#import "DConnectFileParameterSpec.h"

@interface DConnectFileParameterSpecBuilder : DConnectParameterSpecBaseBuilder

/*!
 @brief {@link FileParameterSpec}のインスタンスを生成する.
 @retval {@link FileParameterSpec}のインスタンス
 */
- (DConnectFileParameterSpec *) build;

@end
