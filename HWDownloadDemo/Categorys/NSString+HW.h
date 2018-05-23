//
//  NSString+HW.h
//  HWProject
//
//  Created by wangqibin on 2018/4/9.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HW)

// MD5加密
- (NSString *)MD5;

// 中文、特殊字符转码
- (NSString *)transEncodingString;

@end
