//
//  HWPlayVC.m
//  HWProject
//
//  Created by wangqibin on 2018/4/25.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWPlayVC.h"
#import <AVKit/AVKit.h>

@interface HWPlayVC ()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation HWPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = _model.fileName;
    
    [self creatControl];
}

- (void)creatControl
{
    // 进度条
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(50, KSuitFloat(400), KMainW - 100, 50)];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    // 创建播放器
    _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:_model.localPath]]];

    // 创建显示的图层
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = CGRectMake(0, 0, KMainW, 400);
    [self.view.layer addSublayer:playerLayer];

    // 播放视频
    [_player play];
    
    // 进度回调
    weakify(self);
    [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        strongify(weakSelf);
        // 刷新slider
        slider.value = CMTimeGetSeconds(time) / CMTimeGetSeconds(strongSelf.player.currentItem.duration);
    }];
}

- (void)sliderValueChanged:(UISlider *)slider
{
    // 计算时间
    float time = slider.value * CMTimeGetSeconds(_player.currentItem.duration);
    
    // 跳转到指定时间
    [_player seekToTime:CMTimeMake(time, 1.0)];
}

@end
