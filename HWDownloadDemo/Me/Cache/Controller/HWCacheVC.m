//
//  HWCacheVC.m
//  HWProject
//
//  Created by wangqibin on 2018/4/28.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWCacheVC.h"
#import "HWDownloadingVC.h"

@interface HWCacheVC ()

@property (nonatomic, weak) UIButton *downloadingBtn;
@property (nonatomic, assign) NSInteger downloadingCount;

@end

@implementation HWCacheVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"缓存";

    // 创建控件
    [self creatControl];
    
    // 添加通知
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 获取缓存
    [self getCacheData];
}

- (void)creatControl
{
    // 正在缓存按钮
    UIButton *downloadingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, KMainW, 50)];
    downloadingBtn.hidden = YES;
    downloadingBtn.backgroundColor = [UIColor lightGrayColor];
    [downloadingBtn addTarget:self action:@selector(downloadingBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downloadingBtn];
    _downloadingBtn = downloadingBtn;
}

- (void)downloadingBtnOnClick
{
    [self.navigationController pushViewController:[[HWDownloadingVC alloc] init] animated:YES];
}

- (void)addNotification
{
    // 状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadStateChange:) name:HWDownloadStateChangeNotification object:nil];
}

- (void)getCacheData
{
    // 获取已缓存数据
    self.dataSource = [[[HWDataBaseManager shareManager] getAllDownloadedData] mutableCopy];
    [self reloadTableView];
    
    // 获取所有未下载完成的数据
    _downloadingCount = [[HWDataBaseManager shareManager] getAllUnDownloadedData].count;
    [self reloadCacheView];
}

// 刷新正在缓存提示视图
- (void)reloadCacheView
{
    _downloadingBtn.hidden = _downloadingCount == 0;
    [_downloadingBtn setTitle:[NSString stringWithFormat:@"%ld个文件正在缓存", _downloadingCount] forState:UIControlStateNormal];
    
    self.tableView.frameY = _downloadingCount == 0 ? 0 : _downloadingBtn.frameHeight;
    self.tableView.frameHeight = KMainH - KNavHeight - self.tableView.frameY - (self.isNavEditing ? self.tabbarViewHeight - self.tableView.sectionFooterHeight + 5 : 0);
}

// 状态改变
- (void)downLoadStateChange:(NSNotification *)notification
{
    HWDownloadModel *downloadModel = notification.object;
    
    if (downloadModel.state == HWDownloadStateFinish) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self insertModel:downloadModel];
            _downloadingCount--;
            [self reloadCacheView];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
