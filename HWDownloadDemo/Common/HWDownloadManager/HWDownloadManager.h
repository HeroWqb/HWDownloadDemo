//
//  HWDownloadManager.h
//  HWProject
//
//  Created by wangqibin on 2018/4/24.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWDownloadModel;

typedef NS_ENUM(NSInteger, HWDownloadState) {
    HWDownloadStateDefault = 0,  // 默认
    HWDownloadStateDownloading,  // 正在下载
    HWDownloadStateWaiting,      // 等待
    HWDownloadStatePaused,       // 暂停
    HWDownloadStateFinish,       // 完成
    HWDownloadStateError,        // 错误
};

@interface HWDownloadManager : NSObject

// 获取单例
+ (instancetype)shareManager;

// 开始下载
- (void)startDownloadTask:(HWDownloadModel *)model;

// 暂停下载
- (void)pauseDownloadTask:(HWDownloadModel *)model;

// 删除下载任务及本地缓存
- (void)deleteTaskAndCache:(HWDownloadModel *)model;

// 下载时，杀死进程，更新所有正在下载的任务为等待
- (void)updateDownloadingTaskState;

// 重启时开启等待下载的任务
- (void)openDownloadTask;

@end
