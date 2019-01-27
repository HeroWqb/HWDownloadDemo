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
    CGFloat controlX = 30;
    CGFloat controlYPadding = 50.f;
    CGFloat controlW = KMainW - controlX * 2;
    CGFloat controlH = 44.f;

    // 我的缓存
    UIButton *cacheBtn = [[UIButton alloc] initWithFrame:CGRectMake(controlX, controlYPadding, controlW, controlH)];
    [cacheBtn setTitle:@"我的缓存" forState:UIControlStateNormal];
    cacheBtn.backgroundColor = [UIColor lightGrayColor];
    [cacheBtn addTarget:self action:@selector(cacheBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cacheBtn];
    
    // 设置
    UIButton *setBtn = [[UIButton alloc] initWithFrame:CGRectMake(controlX, CGRectGetMaxY(cacheBtn.frame) + controlYPadding, controlW, controlH)];
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
