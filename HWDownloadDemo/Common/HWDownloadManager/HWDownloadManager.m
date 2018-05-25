//
//  HWDownloadManager.m
//  HWProject
//
//  Created by wangqibin on 2018/4/24.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWDownloadManager.h"
#import "NSURLSession+CorrectedResumeData.h"

@interface HWDownloadManager ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;             // NSURLSession
@property (nonatomic, strong) NSMutableDictionary *dataTaskDic;  // 同时下载多个文件，需要创建多个NSURLSessionDownloadTask，用该字典来存储
@property (nonatomic, assign) NSInteger currentCount;            // 当前正在下载的个数
@property (nonatomic, assign) NSInteger maxConcurrentCount;      // 最大同时下载数量
@property (nonatomic, assign) BOOL allowsCellularAccess;         // 是否允许蜂窝网络下载

@end

@implementation HWDownloadManager

+ (instancetype)shareManager
{
    static HWDownloadManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        // 初始化
        _currentCount = 0;
        _maxConcurrentCount = [[NSUserDefaults standardUserDefaults] integerForKey:HWDownloadMaxConcurrentCountKey];
        _allowsCellularAccess = [[NSUserDefaults standardUserDefaults] boolForKey:HWDownloadAllowsCellularAccessKey];
        _dataTaskDic = [NSMutableDictionary dictionary];
        
        // 单线程代理队列
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;

        // 后台下载标识
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"HWDownloadBackgroundSessionIdentifier"];
        // 允许蜂窝网络下载，默认为YES，这里开启，我们添加了一个变量去控制用户切换选择
        configuration.allowsCellularAccess = YES;
        
        // 创建NSURLSession，配置信息、代理、代理线程
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];

        // 最大下载并发数变更通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadMaxConcurrentCountChange:) name:HWDownloadMaxConcurrentCountChangeNotification object:nil];
        // 是否允许蜂窝网络下载改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAllowsCellularAccessChange:) name:HWDownloadAllowsCellularAccessChangeNotification object:nil];
        // 网路改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkingReachabilityDidChange:) name:HWNetworkingReachabilityDidChangeNotification object:nil];
    }
    
    return self;
}

// 加入准备下载任务
- (void)startDownloadTask:(HWDownloadModel *)model
{
    // 取出数据库中模型数据，如果不存在，添加到数据空中
    HWDownloadModel *downloadModel = [[HWDataBaseManager shareManager] getModelWithUrl:model.url];
    if (!downloadModel) {
        downloadModel = model;
        [[HWDataBaseManager shareManager] insertModel:downloadModel];
    }
    
    // 更新状态为等待下载
    downloadModel.state = HWDownloadStateWaiting;
    [[HWDataBaseManager shareManager] updateWithModel:downloadModel option:HWDBUpdateOptionState | HWDBUpdateOptionLastStateTime];

    // 下载
    if (_currentCount < _maxConcurrentCount && [self networkingAllowsDownloadTask]) [self downloadwithModel:downloadModel];
}

// 开始下载
- (void)downloadwithModel:(HWDownloadModel *)model
{
    // 更新状态为开始
    model.state = HWDownloadStateDownloading;
    [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionState];
    _currentCount++;

    // 创建NSURLSessionDownloadTask
    NSURLSessionDownloadTask *downloadTask;
    if (model.resumeData) {
        CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 10.0 && version < 10.2) {
            downloadTask = [_session downloadTaskWithCorrectResumeData:model.resumeData];
        }else {
            downloadTask = [_session downloadTaskWithResumeData:model.resumeData];
        }
        
    }else {
        downloadTask = [_session downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:model.url]]];
    }

    // 添加描述标签
    downloadTask.taskDescription = model.url;
    
    // 更新存储的NSURLSessionDownloadTask对象
    [_dataTaskDic setValue:downloadTask forKey:model.url];

    // 启动（继续下载）
    [downloadTask resume];
}

// 暂停下载
- (void)pauseDownloadTask:(HWDownloadModel *)model
{
    // 取最新数据
    HWDownloadModel *downloadModel = [[HWDataBaseManager shareManager] getModelWithUrl:model.url];

    // 取消任务
    [self cancelTaskWithModel:downloadModel delete:NO];
    
    // 更新数据库状态为暂停
    downloadModel.state = HWDownloadStatePaused;
    [[HWDataBaseManager shareManager] updateWithModel:downloadModel option:HWDBUpdateOptionState];
}

// 删除下载任务及本地缓存
- (void)deleteTaskAndCache:(HWDownloadModel *)model
{
    // 如果正在下载，取消任务
    [self cancelTaskWithModel:model delete:YES];
    
    // 删除本地缓存、数据库数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSFileManager defaultManager] removeItemAtPath:model.localPath error:nil];
        [[HWDataBaseManager shareManager] deleteModelWithUrl:model.url];
    });
}

// 取消任务
- (void)cancelTaskWithModel:(HWDownloadModel *)model delete:(BOOL)delete
{
    if (model.state == HWDownloadStateDownloading) {
        // 获取NSURLSessionDownloadTask
        NSURLSessionDownloadTask *downloadTask = [_dataTaskDic valueForKey:model.url];

        // 取消任务
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            // 更新下载数据
            model.resumeData = resumeData;
            [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionResumeData];

            // 更新当前正在下载的个数
            if (_currentCount > 0) _currentCount--;

            // 开启等待下载任务
            [self startDownloadWaitingTask];
        }];
        
        // 移除字典存储的对象
        if (delete) [_dataTaskDic removeObjectForKey:model.url];
    }
}

// 开启等待下载任务
- (void)startDownloadWaitingTask
{
    if (_currentCount < _maxConcurrentCount && [self networkingAllowsDownloadTask]) {
        // 获取下一条等待的数据
        HWDownloadModel *model = [[HWDataBaseManager shareManager] getWaitingModel];

        if (model) {
            // 下载
            [self downloadwithModel:model];
            
            // 递归，开启下一个等待任务
            [self startDownloadWaitingTask];
        }
    }
}

// 下载时，杀死进程，更新所有正在下载的任务为等待
- (void)updateDownloadingTaskState
{
    NSArray *downloadingData = [[HWDataBaseManager shareManager] getAllDownloadingData];
    for (HWDownloadModel *model in downloadingData) {
        model.state = HWDownloadStateWaiting;
        [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionState];
    }
}

// 重启时开启等待下载的任务
- (void)openDownloadTask
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startDownloadWaitingTask];
    });
}

// 停止正在下载任务为等待状态
- (void)pauseDownloadingTaskWithAll:(BOOL)all
{
    // 获取正在下载的数据
    NSArray *downloadingData = [[HWDataBaseManager shareManager] getAllDownloadingData];
    NSInteger count = all ? downloadingData.count : downloadingData.count - _maxConcurrentCount;
    for (NSInteger i = 0; i < count; i++) {
        // 取消任务
        HWDownloadModel *model = downloadingData[i];
        [self cancelTaskWithModel:model delete:NO];

        // 更新状态为等待
        model.state = HWDownloadStateWaiting;
        [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionState];
    }
}

#pragma mark - NSURLSessionDownloadDelegate
// 接收到服务器返回数据，会被调用多次
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // 获取模型
    HWDownloadModel *model = [[HWDataBaseManager shareManager] getModelWithUrl:downloadTask.taskDescription];

    // 更新当前下载大小
    model.tmpFileSize = totalBytesWritten;
    model.totalFileSize = totalBytesExpectedToWrite;

    // 计算速度时间内下载文件的大小
    model.intervalFileSize += bytesWritten;

    // 获取上次计算时间与当前时间间隔
    NSInteger intervals = [HWToolBox getIntervalsWithTimeStamp:model.lastSpeedTime];
    if (intervals >= 1) {
        // 计算速度
        model.speed = model.intervalFileSize / intervals;

        // 重置变量
        model.intervalFileSize = 0;
        model.lastSpeedTime = [HWToolBox getTimeStampWithDate:[NSDate date]];
    }

    // 计算进度
    model.progress = 1.0 * model.tmpFileSize / model.totalFileSize;

    // 更新数据库中数据
    [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionProgressData];

    // 进度通知
    [[NSNotificationCenter defaultCenter] postNotificationName:HWDownloadProgressNotification object:model];
}

// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // 获取模型
    HWDownloadModel *model = [[HWDataBaseManager shareManager] getModelWithUrl:downloadTask.taskDescription];

    // 移动文件，原路径文件由系统自动删除
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:model.localPath error:&error];
    if (error) HWLog(@"下载完成，移动文件发生错误：%@", error);
}

#pragma mark - NSURLSessionTaskDelegate
// 请求完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // 调用cancel方法直接返回，在相应操作是直接进行处理
    if (error && [error.localizedDescription isEqualToString:@"cancelled"]) return;
    
    // 获取模型
    HWDownloadModel *model = [[HWDataBaseManager shareManager] getModelWithUrl:task.taskDescription];

    // 下载时，进程杀死，重新启动，回调错误
    if (error && [error.userInfo objectForKey:NSURLErrorBackgroundTaskCancelledReasonKey]) {
        model.state = HWDownloadStateWaiting;
        model.resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionState | HWDBUpdateOptionResumeData];
        return;
    }
    
    // 更新下载数据、任务状态
    if (error) {
        model.state = HWDownloadStateError;
        model.resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionResumeData];

    }else {
        model.state = HWDownloadStateFinish;
    }
    
    // 更新数据
    if (_currentCount > 0) _currentCount--;
    [_dataTaskDic removeObjectForKey:model.url];
    
    // 更新数据库状态
    [[HWDataBaseManager shareManager] updateWithModel:model option:HWDBUpdateOptionState];
    
    // 开启等待下载任务
    [self startDownloadWaitingTask];
    HWLog(@"\n    文件：%@，下载完成 \n    本地路径：%@ \n    错误：%@ \n", model.fileName, model.localPath, error);
}

#pragma mark - NSURLSessionDelegate
// 应用处于后台，所有下载任务完成及NSURLSession协议调用之后调用
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundSessionCompletionHandler) {
            void (^completionHandler)(void) = appDelegate.backgroundSessionCompletionHandler;
            appDelegate.backgroundSessionCompletionHandler = nil;
            
            // 执行block，系统后台生成快照，释放阻止应用挂起的断言
            completionHandler();
        }
    });
}

#pragma mark - HWDownloadMaxConcurrentCountChangeNotification
- (void)downloadMaxConcurrentCountChange:(NSNotification *)notification
{
    _maxConcurrentCount = [notification.object integerValue];

    if (_currentCount < _maxConcurrentCount) {
        // 当前下载数小于并发数，开启等待下载任务
        [self startDownloadWaitingTask];
        
    }else if (_currentCount > _maxConcurrentCount) {
        // 变更正在下载任务为等待下载
        [self pauseDownloadingTaskWithAll:NO];
    }
}

#pragma mark - HWDownloadAllowsCellularAccessChangeNotification
- (void)downloadAllowsCellularAccessChange:(NSNotification *)notification
{
    _allowsCellularAccess = [notification.object boolValue];
    
    [self allowsCellularAccessOrNetworkingReachabilityDidChangeAction];
}

#pragma mark - HWNetworkingReachabilityDidChangeNotification
- (void)networkingReachabilityDidChange:(NSNotification *)notification
{
    [self allowsCellularAccessOrNetworkingReachabilityDidChangeAction];
}

// 是否允许蜂窝网络下载或网络状态变更事件
- (void)allowsCellularAccessOrNetworkingReachabilityDidChangeAction
{
    if ([[HWNetworkReachabilityManager shareManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
        // 无网络，暂停正在下载任务
        [self pauseDownloadingTaskWithAll:YES];
        
    }else {
        if ([self networkingAllowsDownloadTask]) {
            // 开启等待任务
            [self startDownloadWaitingTask];
            
        }else {
            // 增加一个友善的提示，蜂窝网络情况下如果有正在下载，提示已暂停
            if ([[HWDataBaseManager shareManager] getLastDownloadingModel]) {
                [HWProgressHUD showMessage:@"当前为蜂窝网络，已停止下载任务，可在设置中开启" duration:4.f];
            }
            
            // 当前为蜂窝网络，不允许下载，暂停正在下载任务
            [self pauseDownloadingTaskWithAll:YES];
        }
    }
}

// 是否允许下载任务
- (BOOL)networkingAllowsDownloadTask
{
    // 当前网络状态
    AFNetworkReachabilityStatus status = [[HWNetworkReachabilityManager shareManager] networkReachabilityStatus];

    // 无网络 或 （当前为蜂窝网络，且不允许蜂窝网络下载）
    if (status == AFNetworkReachabilityStatusNotReachable || (status == AFNetworkReachabilityStatusReachableViaWWAN && !_allowsCellularAccess)) {
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    [_session invalidateAndCancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
