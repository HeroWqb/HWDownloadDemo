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
    
    //默认视图背景色
    self.view.backgroundColor = KWhiteColor;
    
    //设置状态栏文字颜色为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    //用以支持二级页面边缘右滑返回
    _isAllowScrollBack = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

    // 列表适配
    [self adaptiveView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = _isAllowScrollBack;

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

// 列表适配
- (void)adaptiveView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [UITableView appearance].estimatedRowHeight = 0;
    [UITableView appearance].estimatedSectionHeaderHeight = 0;
    [UITableView appearance].estimatedSectionFooterHeight = 0;
    // iOS 11 解决SafeArea的问题，同时能解决pop时上级页面scrollView抖动的问题
    if (@available(iOS 11, *)) [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

@end
