//
//  HWCacheBaseVC.m
//  HWProject
//
//  Created by wangqibin on 2018/4/28.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWCacheBaseVC.h"
#import "HWHomeCell.h"
#import "HWPlayVC.h"

@interface HWCacheBaseVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIButton *navRightBtn;  // 导航右侧删除按钮
@property (nonatomic, weak) UIView *tabbarView;     // 底部工具栏
@property (nonatomic, weak) UIButton *allSelbtn;    // 全选按钮
@property (nonatomic, weak) UIButton *deleteBtn;    // 底部工具栏删除按钮
@property (nonatomic, readwrite) BOOL navEditing;   // 是否是编辑删除状态

@end

@implementation HWCacheBaseVC

- (NSMutableArray<HWDownloadModel *> *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self creatBaseControl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isNavEditing) [self navBtnOnClick:_navRightBtn];
}

- (void)creatBaseControl
{
    // 列表
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 0, KMainW - 20, KMainH - KNavHeight)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 80.f;
    tableView.sectionHeaderHeight = 5.f;
    tableView.sectionFooterHeight = KIsBangScreen ? KBottomSafeArea - 5 : 5;
    tableView.backgroundColor = KClearColor;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.allowsMultipleSelectionDuringEditing = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    _tableView = tableView;

    // 导航右侧按钮
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(9, 0, 40, 40)];
    [deleteBtn setImage:[UIImage imageNamed:@"nav_deleteBtn"] forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"nav_deleteBtn"] forState:UIControlStateHighlighted];
    [deleteBtn setImage:[UIImage imageNamed:@"nav_cancelBtn"] forState:UIControlStateSelected];
    [deleteBtn addTarget:self action:@selector(navBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightView addSubview:deleteBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    _navRightBtn = deleteBtn;
    
    // 底部视图
    UIView *tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, KMainH - KNavHeight, KMainW, 49 + KBottomSafeArea)];
    tabbarView.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
    [self.view addSubview:tabbarView];
    _tabbarView = tabbarView;
    
    // 全选、删除按钮
    NSArray *titleArray = @[@"全选", @"删除"];
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(KMainW * 0.5 * i, 0, KMainW * 0.5, 49)];
        btn.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#2f9cd4"]] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor colorWithHexString:@"#2f9ad2"] forState:UIControlStateNormal];
        [btn setTitleColor:KWhiteColor forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(tabbarBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [tabbarView addSubview:btn];
        if (i == 0) _allSelbtn = btn;
        if (i == 1) _deleteBtn = btn;
    }
    
    // 线
    for (int i = 0; i < 2; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(KMainW * 0.5, 10, 0.5, 29)];
        if (i == 1) line.frame = CGRectMake(0, 0, KMainW, 0.5);
        line.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
        [tabbarView addSubview:line];
    }
}

- (BOOL)isNavEditing
{
    return _navRightBtn.selected;
}

- (CGFloat)tabbarViewHeight
{
    return _tabbarView.boundsHeight;
}

- (void)reloadTableView
{
    [_tableView reloadData];
    [self reloadNavRightBtn];
}

- (void)reloadRowWithModel:(HWDownloadModel *)model index:(NSInteger)index
{
    self.dataSource[index] = model;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)insertModel:(HWDownloadModel *)model
{
    int index = 0;
    [self.dataSource insertObject:model atIndex:index];
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self reloadNavRightBtn];
    [_allSelbtn setTitle:@"全选" forState:UIControlStateNormal];
}

- (void)deleteRowAtIndex:(NSInteger)index
{
    [self.dataSource removeObjectAtIndex:index];
    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSArray *indexPaths = _tableView.indexPathsForSelectedRows;
    NSString *deleteBtnTitle = indexPaths.count > 0 ? [NSString stringWithFormat:@"删除(%ld)", indexPaths.count] : @"删除";
    [_deleteBtn setTitle:deleteBtnTitle forState:UIControlStateNormal];
}

- (void)updateViewWithModel:(HWDownloadModel *)model index:(NSInteger)index
{
    HWHomeCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell updateViewWithModel:model];
}

- (void)navBtnOnClick:(UIButton *)btn
{
    // 左滑cell至出现删除按钮状态和调用“setEditing: animated:”方法使所有cell进入编辑状态，tableView的editing属性都为YES，所以当一个cell处于左滑编辑状态时，点击导航删除按钮想使所有cell进入编辑状态，需要先取消一次tableView的编辑状态
    if (!btn.selected && _tableView.isEditing) [_tableView setEditing:NO animated:YES];

    btn.selected = !btn.selected;
    [_tableView setEditing:!_tableView.editing animated:YES];

    if (!btn.selected) [self cancelAllSelect];
    
    CGFloat tabbarY = KMainH - KNavHeight - (btn.selected ? self.tabbarViewHeight : 0);
    CGFloat tableViewChangeH = self.tabbarViewHeight - _tableView.sectionFooterHeight + 5;
    [UIView animateWithDuration:0.25f animations:^{
        _tabbarView.frame = CGRectMake(0, tabbarY, KMainW, _allSelbtn.boundsHeight + KBottomSafeArea);
        _tableView.frameHeight += (btn.selected ? - tableViewChangeH : tableViewChangeH);
    }];
}

- (void)tabbarBtnOnClick:(UIButton *)btn
{
    NSArray *indexPaths = _tableView.indexPathsForSelectedRows;
    
    if (btn == _allSelbtn) {
        if ([_allSelbtn.titleLabel.text isEqualToString:@"全选"]) {
            // 全选
            for (int i = 0; i < self.dataSource.count; i ++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            [_allSelbtn setTitle:@"取消全选" forState:UIControlStateNormal];
            [_deleteBtn setTitle:[NSString stringWithFormat:@"删除(%ld)", self.dataSource.count] forState:UIControlStateNormal];
            
        }else {
            // 取消全选
            [self cancelAllSelect];
        }
        
    }else {
        // 删除
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
        for (NSIndexPath *indexPath in indexPaths) {
            [indexes addIndex:indexPath.row];
            [[HWDownloadManager shareManager] deleteTaskAndCache:self.dataSource[indexPath.row]];
        }
        [self.dataSource removeObjectsAtIndexes:indexes];
        [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        if (self.dataSource.count == 0) [_allSelbtn setTitle:@"全选" forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self navBtnOnClick:_navRightBtn];
            [self reloadNavRightBtn];
        });
    }
}

- (void)reloadNavRightBtn
{
    _navRightBtn.hidden = self.dataSource.count == 0 ? YES : NO;
}

- (void)cancelAllSelect
{
    for (int i = 0; i < self.dataSource.count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [_allSelbtn setTitle:@"全选" forState:UIControlStateNormal];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
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
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tabbarView.frame.origin.y == KMainH - KNavHeight - self.tabbarViewHeight) {
        NSArray *indexPaths = _tableView.indexPathsForSelectedRows;
        if (indexPaths.count > 0) [_deleteBtn setTitle:[NSString stringWithFormat:@"删除(%ld)", indexPaths.count] forState:UIControlStateNormal];
        if (indexPaths.count == self.dataSource.count) [_allSelbtn setTitle:@"取消全选" forState:UIControlStateNormal];
        
    }else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        HWDownloadModel *model = self.dataSource[indexPath.row];
        if (model.state == HWDownloadStateFinish) {
            HWPlayVC *vc = [[HWPlayVC alloc] init];
            vc.model = model;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (_tabbarView.frame.origin.y == KMainH - KNavHeight - self.tabbarViewHeight) {
        NSArray *indexPaths = _tableView.indexPathsForSelectedRows;
        NSString *deleteBtnTitle = indexPaths.count > 0 ? [NSString stringWithFormat:@"删除(%ld)", indexPaths.count] : @"删除";
        [_deleteBtn setTitle:deleteBtnTitle forState:UIControlStateNormal];
        if (indexPaths.count < self.dataSource.count) [_allSelbtn setTitle:@"全选" forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HWDownloadModel *model = self.dataSource[indexPath.row];
    [self deleteRowAtIndex:indexPath.row];
    [self reloadNavRightBtn];
    [[HWDownloadManager shareManager] deleteTaskAndCache:model];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setNeedsLayout];
}

@end
