//
//  HWBaseViewController.m
//  HWProject
//
//  Created by wangqibin on 2018/4/9.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWBaseViewController.h"
#import "HWTabBarController.h"

@interface HWBaseViewController ()

@end

@implementation HWBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置状态栏文字颜色为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //默认视图背景色
    self.view.backgroundColor = KWhiteColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //一级页面显示tabBar
    if (self.navigationController.viewControllers.count == 1) {
        HWTabBarController *tabBarController = (HWTabBarController *)self.tabBarController;
        [tabBarController setTabBarShowWithAnimaition:YES];
    }
}

//设置导航栏标题
- (void)setNavTitle:(NSString *)navTitle
{
    _navTitle = navTitle;
    
    self.navigationItem.title = _navTitle;
}

@end
