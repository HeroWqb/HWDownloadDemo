//
//  HWTabBarView.m
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWTabBarView.h"

@implementation HWTabBarView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //普通状态图片
        NSArray *imgNorArray = @[@"tabbar_home_nor", @"tabbar_me_nor"];
        //选中状态图片
        NSArray *imgSelArray = @[@"tabbar_home_sel", @"tabbar_me_sel"];
        
        //菜单按钮
        for (int i = 0; i < imgNorArray.count; i ++) {
            CGFloat btnW = KMainW / imgNorArray.count;
            CGFloat btnX = btnW * i;
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, 0, btnW, 49)];
            btn.adjustsImageWhenHighlighted = NO;
            [btn setImage:[UIImage imageNamed:imgNorArray[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:imgSelArray[i]] forState:UIControlStateSelected];
            [btn setImage:[UIImage imageNamed:imgSelArray[i]] forState:UIControlStateSelected | UIControlStateHighlighted];
            btn.tag = i + 100;
            [btn setSelected:i == 0];
            [btn addTarget:self action:@selector(menuBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
        //线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KMainW, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#a0a0a0"];
        line.alpha = 0.4f;
        [self addSubview:line];
        
        self.backgroundColor = KWhiteColor;
    }
    
    return self;
}

- (void)menuBtnOnClick:(UIButton *)btn
{
    if (btn.selected) return;

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.values = @[@1.0, @1.2, @1.0];
    animation.duration = 0.25;
    animation.calculationMode = kCAAnimationCubic;
    [btn.imageView.layer addAnimation:animation forKey:nil];

    if (_delegate && [_delegate respondsToSelector:@selector(SKTabBarView:didClickMenuButton:)]) {
        [_delegate SKTabBarView:self didClickMenuButton:btn];
    }
}

@end
