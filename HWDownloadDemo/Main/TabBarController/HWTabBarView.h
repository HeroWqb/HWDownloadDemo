//
//  HWTabBarView.h
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWTabBarView;

@protocol HWTabBarViewDelegate <NSObject>

/**
 菜单按钮点击事件

 @param tabBarView HWTabBarView
 @param button 菜单按钮
 */
- (void)SKTabBarView:(HWTabBarView *)tabBarView didClickMenuButton:(UIButton *)button;

@end

@interface HWTabBarView : UIView

@property (nonatomic, weak) id<HWTabBarViewDelegate> delegate;

@end
