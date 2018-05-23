//
//  HWDownloadButton.m
//  HWProject
//
//  Created by wangqibin on 2018/4/24.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWDownloadButton.h"

@interface HWDownloadButton () {
    id _target;
    SEL _action;
}

@property (nonatomic, weak) UILabel *proLabel;    // 进度标签
@property (nonatomic, weak) UIImageView *imgView; // 状态视图

@end

@implementation HWDownloadButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = KWhiteColor;
        
        // 百分比标签
        UILabel *proLabel = [[UILabel alloc] initWithFrame:self.bounds];
        proLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        proLabel.textColor = [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:1];
        proLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:proLabel];
        _proLabel = proLabel;
        
        // 状态视图
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        imgView.backgroundColor = KWhiteColor;
        imgView.image = [UIImage imageNamed:@"com_download_default"];
        [self addSubview:imgView];
        _imgView = imgView;
    }
    
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    _proLabel.text = [NSString stringWithFormat:@"%d%%", (int)floor(progress * 100)];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat lineWidth = 3.f;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = lineWidth;
    [_proLabel.textColor set];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    CGFloat radius = (MIN(rect.size.width, rect.size.height) - lineWidth) * 0.5;
    // 画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
    [path addArcWithCenter:(CGPoint){rect.size.width * 0.5, rect.size.height * 0.5} radius:radius startAngle:M_PI * 1.5 endAngle:M_PI * 1.5 + M_PI * 2 * _progress clockwise:YES];
    [path stroke];
}

- (void)setModel:(HWDownloadModel *)model
{
    _model = model;
    
    self.state = model.state;
}

- (void)setState:(HWDownloadState)state
{
    _imgView.hidden = state == HWDownloadStateDownloading;
    _proLabel.hidden = !_imgView.hidden;
    
    switch (state) {
        case HWDownloadStateDefault:
            _imgView.image = [UIImage imageNamed:@"com_download_default"];
            break;
            
        case HWDownloadStateDownloading:
            break;
            
        case HWDownloadStateWaiting:
            _imgView.image = [UIImage imageNamed:@"com_download_waiting"];
            break;
            
        case HWDownloadStatePaused:
            _imgView.image = [UIImage imageNamed:@"com_download_pause"];
            break;
            
        case HWDownloadStateFinish:
            _imgView.image = [UIImage imageNamed:@"com_download_finish"];
            break;
            
        case HWDownloadStateError:
            _imgView.image = [UIImage imageNamed:@"com_download_error"];
            break;
            
        default:
            break;
    }
    
    _state = state;
}

- (void)addTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_state == HWDownloadStateDefault || _state == HWDownloadStatePaused || _state == HWDownloadStateError) {
        // 点击默认、暂停、失败状态，调用开始下载
        [[HWDownloadManager shareManager] startDownloadTask:_model];
        
    }else if (_state == HWDownloadStateDownloading || _state == HWDownloadStateWaiting) {
        // 点击正在下载、等待状态，调用暂停下载
        [[HWDownloadManager shareManager] pauseDownloadTask:_model];
    }

    if (!_target || !_action) return;
    ((void (*)(id, SEL, id))[_target methodForSelector:_action])(_target, _action, self);
}

@end
