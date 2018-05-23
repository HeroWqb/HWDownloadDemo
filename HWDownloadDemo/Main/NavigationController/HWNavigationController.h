//
//  HWNavigationController.h
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>

@optional
/**
 导航栏返回按钮点击事件，默认返回上一级，如有特殊操作可调用此方法
 */
- (void)back;

@end

@interface UIViewController (customBackPopButton)<BackButtonHandlerProtocol>

@end

@interface HWNavigationController : UINavigationController

@end
