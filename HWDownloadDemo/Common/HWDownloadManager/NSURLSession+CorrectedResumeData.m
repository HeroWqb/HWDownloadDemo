//
//  NSURLSession+CorrectedResumeData.m
//  HWDownloadDemo
//
//  Created by wangqibin on 2018/5/25.
//  Copyright © 2018年 hero. All rights reserved.
//

#import "NSURLSession+CorrectedResumeData.h"

static NSString *const resumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
static NSString *const resumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";

@implementation NSURLSession (CorrectedResumeData)

- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData
{
    NSData *data = [self getCorrectResumeDataWithData:resumeData];
    data = data ? data : resumeData;
    NSURLSessionDownloadTask *task = [self downloadTaskWithResumeData:data];
    NSMutableDictionary *resumeDic = [self getResumeDictionaryWithData:data];
    
    if (resumeDic) {
        if (!task.originalRequest) {
            NSData *originalReqData = resumeDic[resumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData];
            if (originalRequest) [task setValue:originalRequest forKey:@"originalRequest"];
        }
        if (!task.currentRequest) {
            NSData *currentReqData = resumeDic[resumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
            if (currentRequest) [task setValue:currentRequest forKey:@"currentRequest"];
        }
    }
    
    return task;
}

- (NSData *)getCorrectResumeDataWithData:(NSData *)data
{
    if (!data) return nil;

    NSMutableDictionary *resumeDictionary = [self getResumeDictionaryWithData:data];
    if (!resumeDictionary) return nil;

    resumeDictionary[resumeCurrentRequest] = [self getCorrectRequestDataWithData:resumeDictionary[resumeCurrentRequest]];
    resumeDictionary[resumeOriginalRequest] = [self getCorrectRequestDataWithData:resumeDictionary[resumeOriginalRequest]];

    return [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
}

- (NSMutableDictionary *)getResumeDictionaryWithData:(NSData *)data
{
    return [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
}

- (NSData *)getCorrectRequestDataWithData:(NSData *)data
{
    if (!data) return nil;
    
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data]) return data;

    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    if (!archive) return nil;

    NSInteger i = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld", i]]) {
        i++;
    }
    
    NSInteger j = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]]) {
        NSMutableArray *array = archive[@"$objects"];
        NSMutableDictionary *dic = array[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld", i + j]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld", j]];
            [array replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = array;
        }
        j++;
    }
    
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"]) {
        NSMutableArray *array = archive[@"$objects"];
        NSMutableDictionary *dic = array[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld", i + j]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [array replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = array;
        }
    }

    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"]) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }

    return [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
}

@end
