//
//  NSURLSession+CorrectedResumeData.h
//  HWDownloadDemo
//
//  Created by wangqibin on 2018/5/25.
//  Copyright © 2018年 hero. All rights reserved.
//  用于修复iOS 10.0、10.1系统暂停后继续下载错误问题

#import <Foundation/Foundation.h>

@interface NSURLSession (CorrectedResumeData)

- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;

@end
