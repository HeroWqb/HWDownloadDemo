//
//  HWBaseViewController.h
//  HWProject
//
//  Created by wangqibin on 2018/4/9.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWBaseViewController : UIViewController

// 导航栏标题
@property (nonatomic, copy) NSString *navTitle;

// 是否允许二级页面屏幕左侧右滑返回，默认允许
@property (nonatomic, assign) BOOL isAllowScrollBack;

@end
