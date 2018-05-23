//
//  UIColor+HW.h
//  HWProject
//
//  Created by wangqibin on 2018/4/9.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HW)

//16进制转化RGB
+ (UIColor *)colorWithHexString:(NSString *)string;

//随即色
+ (UIColor *)randomColor;

@end
