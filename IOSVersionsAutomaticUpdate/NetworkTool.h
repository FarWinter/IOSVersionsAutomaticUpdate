//
//  NetworkTool.h
//  IOSVersionsAutomaticUpdate
//
//  Created by zhangPeng on 16/8/29.
//  Copyright © 2016年 ZhangPeng. All rights reserved.
//

#import <Foundation/Foundation.h>

//请求地址
#define HttpURL @"http://api.fir.im/apps/"
//项目应用ID(fir.im)
#define FIRID @"57c3a74f959d69216400059c"
//fir的api_token
#define Api_Token @"392c8716cbc2acb93e5088295c4e53b6"
/*
 * block类型
 * completionBlock  完成之后回调
 * errorBlock  错误回调
 */
typedef void(^completionBlock)(id dic);
typedef void(^errorBlock)(NSError *error);

@interface NetworkTool : NSObject

//获取新版本
+ (void)getNewVersion;


@end
