//
//  HWTabBarController.h
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWTabBarController : UITabBarController

//隐藏TabBar
- (void)setTabBarHiddenWithAnimaition:(BOOL)annimation;

//显示TabBar
- (void)setTabBarShowWithAnimaition:(BOOL)annimation;

@end
