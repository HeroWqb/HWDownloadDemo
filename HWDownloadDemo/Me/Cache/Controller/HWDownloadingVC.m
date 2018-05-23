//
//  HWDownloadingVC.m
//  HWProject
//
//  Created by wangqibin on 2018/5/1.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWDownloadingVC.h"

@interface HWDownloadingVC ()

@end

@implementation HWDownloadingVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"正在缓存";
    
    // 添加通知
    [self addNotification];
    
    // 获取缓存
    [self getCacheData];
}

- (void)addNotification
{
    // 进度通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadProgress:) name:HWDownloadProgressNotification object:nil];
    // 状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadStateChange:) name:HWDownloadStateChangeNotification object:nil];
}

- (void)getCacheData
{
    // 获取所有未下载完成的数据
    self.dataSource = [[[HWDataBaseManager shareManager] getAllUnDownloadedData] mutableCopy];
    [self reloadTableView];
}

#pragma mark - HWDownloadNotification
// 正在下载，进度回调
- (void)downLoadProgress:(NSNotification *)notification
{
    HWDownloadModel *downloadModel = notification.object;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataSource enumerateObjectsUsingBlock:^(HWDownloadModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.url isEqualToString:downloadModel.url]) {
                // 更新cell进度
                [self updateViewWithModel:downloadModel index:idx];
                
                *stop = YES;
            }
        }];
    });
}

// 状态改变
- (void)downLoadStateChange:(NSNotification *)notification
{
    HWDownloadModel *downloadModel = notification.object;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dataSource enumerateObjectsUsingBlock:^(HWDownloadModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.url isEqualToString:downloadModel.url]) {
                if (downloadModel.state == HWDownloadStateFinish) {
                    // 下载完成，移除cell
                    [self deleteRowAtIndex:idx];
                    
                    // 没有正在下载的数据，则返回
                    if (self.dataSource.count == 0) [self.navigationController popViewControllerAnimated:YES];
                    
                }else {
                    // 刷新列表
                    [self reloadRowWithModel:downloadModel index:idx];
                }
                
                *stop = YES;
            }
        }];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
