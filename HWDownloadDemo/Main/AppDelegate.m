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
    
    // 初始化下载单例，若之前程序杀死时有正在下的任务，会自动恢复下载
    [HWDownloadManager shareManager];
    
    return YES;
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
    NSString *onceKey = @"HWProjectOnceKey";
    if (![defaults boolForKey:onceKey]) {
        // 初始化下载最大并发数为1，不允许蜂窝网络下载
        [defaults setInteger:1 forKey:HWDownloadMaxConcurrentCountKey];
        [defaults setBool:NO forKey:HWDownloadAllowsCellularAccessKey];
        [defaults setBool:YES forKey:onceKey];
    }
}

@end
