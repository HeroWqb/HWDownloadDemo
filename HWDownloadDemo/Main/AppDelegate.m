//
//  AppDelegate.m
//  HWDownloadDemo
//
//  Created by wangqibin on 2018/5/21.
//  Copyright © 2018年 hero. All rights reserved.
//

#import "AppDelegate.h"
#import "HWTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = KWhiteColor;
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[HWTabBarController alloc] init];
    
    // 一次性代码
    [self projectOnceCode];
    
    // 开启网络监听
    [[HWNetworkReachabilityManager shareManager] monitorNetworkStatus];
    
    // 开启等待下载的任务
    [[HWDownloadManager shareManager] openDownloadTask];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 实现如下代码，才能使程序处于后台时被杀死，调用applicationWillTerminate:方法
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){}];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[HWDownloadManager shareManager] updateDownloadingTaskState];
}

// 应用处于后台，所有下载任务完成调用
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    _backgroundSessionCompletionHandler = completionHandler;
}

// 一次性代码
- (void)projectOnceCode
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"HWProjectOnceKey"]) {
        // 初始化下载最大并发数为1
        [defaults setInteger:1 forKey:HWDownloadMaxConcurrentCountKey];
        // 初始化不允许蜂窝网络下载
        [defaults setBool:NO forKey:HWDownloadAllowsCellularAccessKey];
        [defaults setBool:YES forKey:@"HWProjectOnceKey"];
    }
}

@end
