//
//  HWHomeCell.m
//  HWProject
//
//  Created by wangqibin on 2018/4/23.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWHomeCell.h"
#import "HWDownloadButton.h"

@interface HWHomeCell ()

@property (nonatomic, weak) UILabel *titleLabel;            // 标题
@property (nonatomic, weak) UILabel *speedLabel;            // 进度标签
@property (nonatomic, weak) UILabel *fileSizeLabel;         // 文件大小标签
@property (nonatomic, weak) HWDownloadButton *downloadBtn;  // 下载按钮

@end

@implementation HWHomeCell

+ (instancetype)cellWithTableView:(UITableView *)tabelView
{
    static NSString *identifier = @"HWHomeCellIdentifier";
    
    HWHomeCell *cell = [tabelView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[HWHomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = KWhiteColor;
        
        // 选中时cell背景色
        UIView *backgroundViews = [[UIView alloc] initWithFrame:cell.frame];
        backgroundViews.backgroundColor = [[UIColor colorWithHexString:@"#00CDCD"] colorWithAlphaComponent:0.5f];
        [cell setSelectedBackgroundView:backgroundViews];
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 底图
        CGFloat margin = 10.f;
        CGFloat backViewH = 70.f;
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, margin * 0.5, KMainW - margin * 2, backViewH)];
        backView.backgroundColor = [UIColor colorWithHexString:@"#00CDCD"];
        [self.contentView addSubview:backView];
        
        // 下载按钮
        CGFloat btnW = 50.f;
        HWDownloadButton *downloadBtn = [[HWDownloadButton alloc] initWithFrame:CGRectMake(backView.frameWidth - btnW - margin, (backViewH - btnW) * 0.5, btnW, btnW)];
        [downloadBtn addTarget:self action:@selector(downBtnOnClick:)];
        [backView addSubview:downloadBtn];
        _downloadBtn = downloadBtn;

        // 标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, 0, backView.frameWidth - margin * 3 - btnW, backViewH * 0.6)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
        titleLabel.textColor = KWhiteColor;
        titleLabel.backgroundColor = backView.backgroundColor;
        titleLabel.layer.masksToBounds = YES;
        [backView addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        // 进度标签
        UILabel *speedLable = [[UILabel alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(titleLabel.frame), titleLabel.frameWidth * 0.36, backViewH * 0.4)];
        speedLable.font = [UIFont systemFontOfSize:14.f];
        speedLable.textColor = KWhiteColor;
        speedLable.textAlignment = NSTextAlignmentRight;
        speedLable.backgroundColor = backView.backgroundColor;
        speedLable.layer.masksToBounds = YES;
        [backView addSubview:speedLable];
        _speedLabel = speedLable;
        
        // 文件大小标签
        UILabel *fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(speedLable.frame), CGRectGetMaxY(titleLabel.frame), titleLabel.frameWidth - speedLable.frameWidth, backViewH * 0.4)];
        fileSizeLabel.font = [UIFont systemFontOfSize:14.f];
        fileSizeLabel.textColor = KWhiteColor;
        fileSizeLabel.textAlignment = NSTextAlignmentRight;
        fileSizeLabel.backgroundColor = backView.backgroundColor;
        fileSizeLabel.layer.masksToBounds = YES;
        [backView addSubview:fileSizeLabel];
        _fileSizeLabel = fileSizeLabel;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSArray *subviews = ISIOS11 ? self.superview.subviews : self.subviews;
    NSString *classString = ISIOS11 ? @"UISwipeActionPullView" : @"UITableViewCellDeleteConfirmationView";
    for (UIView *view in subviews) {
        if ([view isKindOfClass:NSClassFromString(classString)]) {
            UIButton *deleteBtn = view.subviews.firstObject;
            view.backgroundColor = KClearColor;
            deleteBtn.frameY = 5;
            deleteBtn.frameHeight = 70;
            [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)setModel:(HWDownloadModel *)model
{
    _model = model;
    
    _downloadBtn.model = model;
    _titleLabel.text = model.fileName;
    [self updateViewWithModel:model];
}

// 更新视图
- (void)updateViewWithModel:(HWDownloadModel *)model
{
    _downloadBtn.progress = model.progress;
    
    [self reloadLabelWithModel:model];
}

// 刷新标签
- (void)reloadLabelWithModel:(HWDownloadModel *)model
{
    NSString *totalSize = [HWToolBox stringFromByteCount:model.totalFileSize];
    NSString *tmpSize = [HWToolBox stringFromByteCount:model.tmpFileSize];

    if (model.state == HWDownloadStateFinish) {
        _fileSizeLabel.text = [NSString stringWithFormat:@"%@", totalSize];
        
    }else {
        _fileSizeLabel.text = [NSString stringWithFormat:@"%@ / %@", tmpSize, totalSize];
    }
    _fileSizeLabel.hidden = model.totalFileSize == 0;
    
    if (model.speed > 0) {
        _speedLabel.text = [NSString stringWithFormat:@"%@ / s", [HWToolBox stringFromByteCount:model.speed]];
    }
    _speedLabel.hidden = !(model.state == HWDownloadStateDownloading && model.totalFileSize > 0);
}

- (void)downBtnOnClick:(HWDownloadButton *)btn
{
    // do something...
}

@end
