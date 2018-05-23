//
//  HWTabBarController.m
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWTabBarController.h"
#import "HWTabBarView.h"
#import "HWNavigationController.h"

@interface HWTabBarController ()<HWTabBarViewDelegate>

@property (nonatomic, weak) HWTabBarView *tabBarView;

@end

@implementation HWTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    //隐藏系统的tabbar
    self.tabBar.alpha = 0.0;
    
    [self creatControl];
    
    [self addViewControllers];
}

- (void)creatControl
{
    //初始化tabBar视图
    HWTabBarView *tabBarView = [[HWTabBarView alloc] initWithFrame:(CGRect){0, KMainH - KTabBarHeight, KMainW, KTabBarHeight}];
    tabBarView.delegate = self;
    [self.view addSubview:tabBarView];
    _tabBarView = tabBarView;
}

- (void)addViewControllers
{
    NSArray *classNameArray = @[@"HWHomeVC", @"HWMeVC"];
    NSMutableArray *array = [NSMutableArray array];

    for (int i = 0; i < classNameArray.count; i++) {
        UIViewController *vc = [[NSClassFromString(classNameArray[i]) alloc] init];
        HWNavigationController *nav = [[HWNavigationController alloc] initWithRootViewController:vc];
        [array addObject:nav];
    }
    
    self.viewControllers = array;
    self.selectedIndex = 0;
}

#pragma mark - HWTabBarViewDelegate
- (void)SKTabBarView:(HWTabBarView *)tabBarView didClickMenuButton:(UIButton *)button
{    
    //让所有button归位成非选中状态
    for (int i = 0; i < 3; i ++) {
        UIButton *btn = (UIButton *) [_tabBarView viewWithTag:i + 100];
        [btn setSelected:NO];
    }
    
    //设置当前按钮为选中状态
    button.selected = YES;
    
    //设置当前tabBarController的选中页面
    [self setSelectedIndex:button.tag - 100];
}

//隐藏TabBar
- (void)setTabBarHiddenWithAnimaition:(BOOL)annimation
{
    [UIView animateWithDuration:annimation ? 0.25 : 0 animations:^{
        _tabBarView.frame = CGRectMake(0, KMainH + KTabBarHeight, KMainW, KTabBarHeight);
    }];
}

//显示TabBar
- (void)setTabBarShowWithAnimaition:(BOOL)annimation
{
    [UIView animateWithDuration:annimation ? 0.25 : 0 animations:^{
        _tabBarView.frame = CGRectMake(0, KMainH - KTabBarHeight, KMainW, KTabBarHeight);
    }];
}

@end
