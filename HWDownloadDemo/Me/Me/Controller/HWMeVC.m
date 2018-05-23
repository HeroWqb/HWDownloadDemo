//
//  HWMeVC.m
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWMeVC.h"
#import "HWCacheVC.h"
#import "HWSettingVC.h"

@interface HWMeVC ()

@end

@implementation HWMeVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"我的";
    
    [self creatControl];
}

- (void)creatControl
{
    // 我的缓存
    UIButton *cacheBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, KMainW - 100, 44)];
    [cacheBtn setTitle:@"我的缓存" forState:UIControlStateNormal];
    cacheBtn.backgroundColor = [UIColor lightGrayColor];
    [cacheBtn addTarget:self action:@selector(cacheBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cacheBtn];
    
    // 设置
    UIButton *setBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(cacheBtn.frame) + 50, KMainW - 100, 44)];
    [setBtn setTitle:@"设置" forState:UIControlStateNormal];
    setBtn.backgroundColor = [UIColor lightGrayColor];
    [setBtn addTarget:self action:@selector(setBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setBtn];
}

- (void)cacheBtnOnClick
{
    [self.navigationController pushViewController:[[HWCacheVC alloc] init] animated:YES];
}

- (void)setBtnOnClick
{
    [self.navigationController pushViewController:[[HWSettingVC alloc] init] animated:YES];
}

@end
