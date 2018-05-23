//
//  UIImage+HW.h
//  HWProject
//
//  Created by wangqibin on 2018/4/9.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HW)

//根据颜色返回图片
+ (UIImage *)imageWithColor:(UIColor *)color;

//获取网络图片
+ (UIImage *)imageWithUrlString:(NSString *)urlString;

//绘制图片圆角
- (UIImage *)drawCornerInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

@end
