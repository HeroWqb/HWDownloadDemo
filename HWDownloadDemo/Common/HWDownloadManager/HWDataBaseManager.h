//
//  HWDataBaseManager.h
//  HWProject
//
//  Created by wangqibin on 2018/4/25.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, HWDBUpdateOption) {
    HWDBUpdateOptionState         = 1 << 0,  // 更新状态
    HWDBUpdateOptionLastStateTime = 1 << 1,  // 更新状态最后改变的时间
    HWDBUpdateOptionResumeData    = 1 << 2,  // 更新下载的数据
    HWDBUpdateOptionProgressData  = 1 << 3,  // 更新进度数据（包含tmpFileSize、totalFileSize、progress、intervalFileSize、lastSpeedTime）
    HWDBUpdateOptionAllParam      = 1 << 4   // 更新全部数据
};

@interface HWDataBaseManager : NSObject

// 获取单例
+ (instancetype)shareManager;

// 插入数据
- (void)insertModel:(HWDownloadModel *)model;

// 获取数据
- (HWDownloadModel *)getModelWithUrl:(NSString *)url;    // 根据url获取数据
- (HWDownloadModel *)getWaitingModel;                    // 获取第一条等待的数据
- (HWDownloadModel *)getLastDownloadingModel;            // 获取最后一条正在下载的数据
- (NSArray<HWDownloadModel *> *)getAllCacheData;         // 获取所有数据
- (NSArray<HWDownloadModel *> *)getAllDownloadingData;   // 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<HWDownloadModel *> *)getAllDownloadedData;    // 获取所有下载完成的数据
- (NSArray<HWDownloadModel *> *)getAllUnDownloadedData;  // 获取所有未下载完成的数据（包含正在下载、等待、暂停、错误）
- (NSArray<HWDownloadModel *> *)getAllWaitingData;       // 获取所有等待下载的数据

// 更新数据
- (void)updateWithModel:(HWDownloadModel *)model option:(HWDBUpdateOption)option;

// 删除数据
- (void)deleteModelWithUrl:(NSString *)url;

@end
