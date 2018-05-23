//
//  HWDataBaseManager.m
//  HWProject
//
//  Created by wangqibin on 2018/4/25.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

#import "HWDataBaseManager.h"

typedef NS_ENUM(NSInteger, HWDBGetDateOption) {
    HWDBGetDateOptionAllCacheData = 0,      // 所有缓存数据
    HWDBGetDateOptionAllDownloadingData,    // 所有正在下载的数据
    HWDBGetDateOptionAllDownloadedData,     // 所有下载完成的数据
    HWDBGetDateOptionAllUnDownloadedData,   // 所有未下载完成的数据
    HWDBGetDateOptionAllWaitingData,        // 所有等待下载的数据
    HWDBGetDateOptionModelWithUrl,          // 通过url获取单条数据
    HWDBGetDateOptionWaitingModel,          // 第一条等待的数据
    HWDBGetDateOptionLastDownloadingModel,  // 最后一条正在下载的数据
};

@interface HWDataBaseManager ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation HWDataBaseManager

+ (instancetype)shareManager
{
    static HWDataBaseManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self creatVideoCachesTable];
    }
    
    return self;
}

// 创表
- (void)creatVideoCachesTable
{
    // 数据库文件路径
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HWDownloadVideoCaches.sqlite"];
    
    // 创建队列对象，内部会自动创建一个数据库, 并且自动打开
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];

    [_dbQueue inDatabase:^(FMDatabase *db) {
        // 创表
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_videoCaches (id integer PRIMARY KEY AUTOINCREMENT, vid text, fileName text, url text, resumeData blob, totalFileSize integer, tmpFileSize integer, state integer, progress float, lastSpeedTime integer, intervalFileSize integer, lastStateTime integer)"];
        if (result) {
//            HWLog(@"视频缓存数据表创建成功");
        }else {
            HWLog(@"视频缓存数据表创建失败");
        }
    }];
}

// 插入数据
- (void)insertModel:(HWDownloadModel *)model
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"INSERT INTO t_videoCaches (vid, fileName, url, resumeData, totalFileSize, tmpFileSize, state, progress, lastSpeedTime, intervalFileSize, lastStateTime) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model.vid, model.fileName, model.url, model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithInteger:model.state], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]];
        if (result) {
//            HWLog(@"插入成功：%@", model.fileName);
        }else {
            HWLog(@"插入失败：%@", model.fileName);
        }
    }];
}

// 获取单条数据
- (HWDownloadModel *)getModelWithUrl:(NSString *)url
{
    return [self getModelWithOption:HWDBGetDateOptionModelWithUrl url:url];
}

// 获取第一条等待的数据
- (HWDownloadModel *)getWaitingModel
{
    return [self getModelWithOption:HWDBGetDateOptionWaitingModel url:nil];
}

// 获取最后一条正在下载的数据
- (HWDownloadModel *)getLastDownloadingModel
{
    return [self getModelWithOption:HWDBGetDateOptionLastDownloadingModel url:nil];
}

// 获取所有数据
- (NSArray<HWDownloadModel *> *)getAllCacheData
{
    return [self getDateWithOption:HWDBGetDateOptionAllCacheData];
}

// 根据lastStateTime倒叙获取所有正在下载的数据
- (NSArray<HWDownloadModel *> *)getAllDownloadingData
{
    return [self getDateWithOption:HWDBGetDateOptionAllDownloadingData];
}

// 获取所有下载完成的数据
- (NSArray<HWDownloadModel *> *)getAllDownloadedData
{
    return [self getDateWithOption:HWDBGetDateOptionAllDownloadedData];
}

// 获取所有未下载完成的数据
- (NSArray<HWDownloadModel *> *)getAllUnDownloadedData
{
    return [self getDateWithOption:HWDBGetDateOptionAllUnDownloadedData];
}

// 获取所有等待下载的数据
- (NSArray<HWDownloadModel *> *)getAllWaitingData
{
   return [self getDateWithOption:HWDBGetDateOptionAllWaitingData];
}

// 获取单条数据
- (HWDownloadModel *)getModelWithOption:(HWDBGetDateOption)option url:(NSString *)url
{
    __block HWDownloadModel *model = nil;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet;
        switch (option) {
            case HWDBGetDateOptionModelWithUrl:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE url = ?", url];
                break;
                
            case HWDBGetDateOptionWaitingModel:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime asc limit 0,1", [NSNumber numberWithInteger:HWDownloadStateWaiting]];
                break;
                
            case HWDBGetDateOptionLastDownloadingModel:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime desc limit 0,1", [NSNumber numberWithInteger:HWDownloadStateDownloading]];
                break;
                
            default:
                break;
        }
        
        while ([resultSet next]) {
            model = [[HWDownloadModel alloc] initWithFMResultSet:resultSet];
        }
    }];
    
    return model;
}

// 获取数据集合
- (NSArray<HWDownloadModel *> *)getDateWithOption:(HWDBGetDateOption)option
{
    __block NSArray<HWDownloadModel *> *array = nil;
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet;
        switch (option) {
            case HWDBGetDateOptionAllCacheData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches"];
                break;
                
            case HWDBGetDateOptionAllDownloadingData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ? order by lastStateTime desc", [NSNumber numberWithInteger:HWDownloadStateDownloading]];
                break;
                
            case HWDBGetDateOptionAllDownloadedData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ?", [NSNumber numberWithInteger:HWDownloadStateFinish]];
                break;
                
            case HWDBGetDateOptionAllUnDownloadedData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state != ?", [NSNumber numberWithInteger:HWDownloadStateFinish]];
                break;
                
            case HWDBGetDateOptionAllWaitingData:
                resultSet = [db executeQuery:@"SELECT * FROM t_videoCaches WHERE state = ?", [NSNumber numberWithInteger:HWDownloadStateWaiting]];
                break;
                
            default:
                break;
        }
        
        NSMutableArray *tmpArr = [NSMutableArray array];
        while ([resultSet next]) {
            [tmpArr addObject:[[HWDownloadModel alloc] initWithFMResultSet:resultSet]];
        }
        array = tmpArr;
    }];
    
    return array;
}

// 更新数据
- (void)updateWithModel:(HWDownloadModel *)model option:(HWDBUpdateOption)option
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        if (option & HWDBUpdateOptionState) {
            [self postStateChangeNotificationWithFMDatabase:db model:model];
            [db executeUpdate:@"UPDATE t_videoCaches SET state = ? WHERE url = ?", [NSNumber numberWithInteger:model.state], model.url];
        }
        if (option & HWDBUpdateOptionLastStateTime) {
            [db executeUpdate:@"UPDATE t_videoCaches SET lastStateTime = ? WHERE url = ?", [NSNumber numberWithInteger:[HWToolBox getTimeStampWithDate:[NSDate date]]], model.url];
        }
        if (option & HWDBUpdateOptionResumeData) {
            [db executeUpdate:@"UPDATE t_videoCaches SET resumeData = ? WHERE url = ?", model.resumeData, model.url];
        }
        if (option & HWDBUpdateOptionProgressData) {
            [db executeUpdate:@"UPDATE t_videoCaches SET tmpFileSize = ?, totalFileSize = ?, progress = ?, lastSpeedTime = ?, intervalFileSize = ? WHERE url = ?", [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithFloat:model.totalFileSize], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithInteger:model.lastSpeedTime], [NSNumber numberWithInteger:model.intervalFileSize], model.url];
        }
        if (option & HWDBUpdateOptionAllParam) {
            [self postStateChangeNotificationWithFMDatabase:db model:model];
            [db executeUpdate:@"UPDATE t_videoCaches SET resumeData = ?, totalFileSize = ?, tmpFileSize = ?, progress = ?, state = ?, lastSpeedTime = ?, intervalFileSize = ?, lastStateTime = ? WHERE url = ?", model.resumeData, [NSNumber numberWithInteger:model.totalFileSize], [NSNumber numberWithInteger:model.tmpFileSize], [NSNumber numberWithFloat:model.progress], [NSNumber numberWithInteger:model.state], [NSNumber numberWithInteger:model.lastSpeedTime], [NSNumber numberWithInteger:model.intervalFileSize], [NSNumber numberWithInteger:[HWToolBox getTimeStampWithDate:[NSDate date]]], model.url];
        }
    }];
}

// 状态变更通知
- (void)postStateChangeNotificationWithFMDatabase:(FMDatabase *)db model:(HWDownloadModel *)model
{
    // 原状态
    NSInteger oldState = [db intForQuery:@"SELECT state FROM t_videoCaches WHERE url = ?", model.url];
    if (oldState != model.state) {
        // 状态变更通知
        [[NSNotificationCenter defaultCenter] postNotificationName:HWDownloadStateChangeNotification object:model];
    }
}

// 删除数据
- (void)deleteModelWithUrl:(NSString *)url
{
    [_dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"DELETE FROM t_videoCaches WHERE url = ?", url];
        if (result) {
//            HWLog(@"删除成功：%@", url);
        }else {
            HWLog(@"删除失败：%@", url);
        }
    }];
}

@end
