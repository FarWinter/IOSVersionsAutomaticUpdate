#fir.im版本自动更新
###1.在fir.im上上传你需要测试的代码包
* **上传fir.im命令：**

cd ~打开项目
fir login     登录   输入token，如果已经登录过的就省略这一步
 fir b ./ -w -S 项目名称 -C Debug -p -c “提交信息"
 -w  如果项目使用了cocopods管理就需要
 -S  cocopods相关  如果使用了cocopods就需要
 -C  配置
 -p  上传项目到 fir.im
 -c  提交信息
 * **更新上传的项目：**
  
  fir b ./ -C Debug -p -c "更新说明"
###2.查看fir.im官网文档
*原文文档链接：[fir.im官方文档](http://fir.im/docs)  

*查看文档可以看到有很多的API可以使用，这里用到了版本查询这个API
*接口说明：调用检测更新接口会返回最新版本的版本信息。接口反馈的版本信息与应用的当前版本进行比较，可以实现应用检测更新功能。
*更多详细API请看官方文档，这里不做过多说明
###3.项目中具体实现
*在项目中创建请求，这里用到了AFNetWorking请求数据：

```
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    //系统bundleID
    NSString *bundleID = [[NSBundle mainBundle]bundleIdentifier];
    
    //请求地址
    NSString * requestUrl = [NSString stringWithFormat:@"%@latest/%@?api_token=%@&type=ios",HttpURL,bundleID,Api_Token];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"application/json", @"text/html", @"text/json", nil];
    
    manager.requestSerializer.timeoutInterval = 10.;
    
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

```

*看一下返回值:
```    {
        binary ={
            fsize = @150221;
        };
        build = @11;
        changelog = "\U7b2c11\U6b21\U66f4\U65b0\U6d4b\U8bd5";
        direct_install_url = "";
        installUrl = "https://download.fir.im/v2/app/install/57c3a74f959d69216400059c?download_token=e0ee21d26aae370d447c838e0fd485ba";
        install_url = "https://download.fir.im/v2/app/install/57c3a74f959d69216400059c?download_token=e0ee21d26aae370d447c838e0fd485ba";
        name = IOSVersionsAutomaticUpdate;
        update_url = "http://fir.im/48x3";
        updated_at = 1472461834;
        version = 11;
        versionShort = "2.0";
    }
```
* **binary:更新文件的对象，仅有大小字段fsize
name:应用名称
version:版本
changelog:更新日志
versionShort:版本编号(兼容旧版字段)
build:编译号
installUrl:安装地址（兼容旧版字段
install_url	:安装地址(新增字段)
update_url:更新地址(新增字段)**
####**这里只用到了3个返回值**
*update_url，changelog，version
*判断如果当前的版本号 **<** 请求回来的版本号，就发通知把这3个值传过去
*在HomeViewControll里监听:

```objc
[NOTI_CENTER addObserver:self selector:@selector(newVersion:) name:@"newVersion" object:nil];
```
*方法：

```objc
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

```
*这里顺便说一下IOS9以后用的UIAlertController
*首先创建UIAlertController对象，有个对象方法：

```objc
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle;
```
***注意的是这个preferredStyle这个参数，是要选择Alert还是ActionSheet**
*创建成功之后运行，你会发现这并不像以前的Alertview一样有“取消”和“确定”按钮,那么就要用到UIAlertAction来创建者2个按钮

```objc
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        NSLog(@"点击了取消");
    }];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSLog(@"点击了确定");       
    }];
```
*值得一提的是，这里不像以前还需要代理方法，是使用block直接回调，节省了很多时间。在block方法中直接做你需要完成的事。
*最后添加到UIAlertController上：

```objc
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
```
***千万不要忘了最重要的一步，把弹框弹出来，这里用了模态：**

```obje
    [self presentViewController:alert animated:YES completion:nil];
```
###接着上面的说，在监听到需要更新后，提示更新，点击确定就打开系统的safari浏览器(用传过来的URL打开)：
```objc
    //使用safari打开URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:update_url]];
```
*在safari中就会有下载，点击下载即可更新。

##总结：需要注意的一点，在提示了更新以后，有可能会有人点击取消，最开始我是把请求写在了didFinishLaunchingWithOptions这个方法中，最后我发现，当点击了取消以后，下次运行就不会提示更新，除非把后台运行的也结束掉。这样就显得很麻烦，于是就把方法写在了applicationWillEnterForeground，在每次即将在前台显示的时候就发请求看看有没有更新，以防点击了取消，而忘记了更新。
##这样做减轻了测试需要多次到我们这安装新的测试版本的麻烦，减少了工作量。


