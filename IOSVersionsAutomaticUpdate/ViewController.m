//
//  ViewController.m
//  IOSVersionsAutomaticUpdate
//
//  Created by zhangPeng on 16/8/27.
//  Copyright © 2016年 ZhangPeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ViewController

- (void)dealloc{
    [NOTI_CENTER removeObserver:@"newVersion"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.title = @"检测更新";
    
    self.titleLabel.text = @"第11次更新";
    
    
    //监听推送消息
    [NOTI_CENTER addObserver:self selector:@selector(newVersion:) name:@"newVersion" object:nil];
    
}
- (void)newVersion:(NSNotification *)sender{
    
    
    NSDictionary *userDic = sender.userInfo;
    
    //更新日志
    NSString *changelogStr = userDic[@"changelog"];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //新版本
    NSString *newVersion = userDic[@"version"];
    
    NSString *changelog = [NSString stringWithFormat:@"有新版本是否更新,更新内容:当前版本:%@,新版本:%@,更新日志:%@",app_Version,newVersion,changelogStr];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:changelog
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"点击了取消");
    }];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"点击了确定");
        
        NSString *update_url = userDic[@"update_url"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:update_url]];
        
    }];
    
    
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
