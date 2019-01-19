//
//  HWHomeVC.m
//  HWProject
//
//  Created by wangqibin on 2018/4/10.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWHomeVC.h"
#import "HWHomeCell.h"
#import "HWPlayVC.h"

@interface HWHomeVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<HWDownloadModel *> *dataSource;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation HWHomeVC

- (NSMutableArray<HWDownloadModel *> *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"首页";
    
    // 创建控件
    [self creatControl];
    
    // 添加通知
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 获取网络数据
    [self getInfo];

    // 获取缓存
    [self getCacheData];
}

- (void)getInfo
{
    // 模拟网络数据
    NSArray *testData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testData.plist" ofType:nil]];

    // 转模型
    self.dataSource = [HWDownloadModel mj_objectArrayWithKeyValuesArray:testData];
}

- (void)getCacheData
{
    // 获取已缓存数据
    NSArray *cacheData = [[HWDataBaseManager shareManager] getAllCacheData];

    // 这里是把本地缓存数据更新到网络请求的数据中，实际开发还是尽可能避免这样在两个地方取数据再整合
    for (int i = 0; i < self.dataSource.count; i++) {
        HWDownloadModel *model = self.dataSource[i];
        for (HWDownloadModel *downloadModel in cacheData) {
            if ([model.url isEqualToString:downloadModel.url]) {
                self.dataSource[i] = downloadModel;
                break;
            }
        }
    }
    
    [_tableView reloadData];
}

- (void)creatControl
{
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, KMainW - 20, KMainH - KNavHeight - KTabBarHeight)];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 80.f;
    tableView.sectionHeaderHeight = 5.f;
    tableView.sectionFooterHeight = 5.f;
    tableView.backgroundColor = KWhiteColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)addNotification
{
    // 进度通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadProgress:) name:HWDownloadProgressNotification object:nil];
    // 状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadStateChange:) name:HWDownloadStateChangeNotification object:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HWHomeCell *cell = [HWHomeCell cellWithTableView:tableView];
    
    cell.model = self.dataSource[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HWDownloadModel *model = self.dataSource[indexPath.row];

    if (model.state == HWDownloadStateFinish) {
        HWPlayVC *vc = [[HWPlayVC alloc] init];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = KClearColor;
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = KClearColor;
    
    return view;
}

#pragma mark - HWDownloadNotification
// 正在下载，进度回调
- (void)downLoadProgress:(NSNotification *)notification
{
    HWDownloadModel *downloadModel = notification.object;

    [self.dataSource enumerateObjectsUsingBlock:^(HWDownloadModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.url isEqualToString:downloadModel.url]) {
            // 主线程更新cell进度
            dispatch_async(dispatch_get_main_queue(), ^{
                HWHomeCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                [cell updateViewWithModel:downloadModel];
            });
            
            *stop = YES;
        }
    }];
}

// 状态改变
- (void)downLoadStateChange:(NSNotification *)notification
{
    HWDownloadModel *downloadModel = notification.object;

    [self.dataSource enumerateObjectsUsingBlock:^(HWDownloadModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.url isEqualToString:downloadModel.url]) {
            // 更新数据源
            self.dataSource[idx] = downloadModel;
            
            // 主线程刷新cell
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });

            *stop = YES;
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
