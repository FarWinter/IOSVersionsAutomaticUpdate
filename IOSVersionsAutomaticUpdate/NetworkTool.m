//
//  NetworkTool.m
//  IOSVersionsAutomaticUpdate
//
//  Created by zhangPeng on 16/8/29.
//  Copyright © 2016年 ZhangPeng. All rights reserved.
//

#import "NetworkTool.h"

@implementation NetworkTool

+ (void)getNewVersion{
    
    //系统数据请求转圈提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    //系统bundleID
    NSString *bundleID = [[NSBundle mainBundle]bundleIdentifier];
    
    //请求地址
    NSString * requestUrl = [NSString stringWithFormat:@"%@latest/%@?api_token=%@&type=ios",HttpURL,bundleID,Api_Token];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/html", @"text/json", nil];
    
    manager.requestSerializer.timeoutInterval = 10.;
    
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@",responseObject);
        
        NSDictionary *dic = (NSDictionary *)responseObject;
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDictionary));
        //获取 app build号
        NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
        //最新的build
        NSString *firApp_build = dic[@"build"];
        //更新地址
        NSString *update_url = dic[@"update_url"];
        //更新说明
        NSString *changelog = dic[@"changelog"];
        //版本号
        NSString *version = dic[@"versionShort"];
        
        
        if ([app_build integerValue] < [firApp_build integerValue]) {
            
            //如果当前的版本号<请求过来的版本号，就发通知提示有最新版本
            [NOTI_CENTER postNotificationName:@"newVersion"
                                       object:nil
                                     userInfo:@{@"update_url":update_url,
                                                @"changelog":changelog,
                                                @"version":version}];
            
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    
}


@end
