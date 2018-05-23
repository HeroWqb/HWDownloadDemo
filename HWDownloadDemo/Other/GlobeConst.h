//
//  GlobeConst.h
//  HWProject
//
//  Created by wangqibin on 2018/4/20.
//  Copyright © 2018年 wangqibin. All rights reserved.
//

/************************* 下载 *************************/
UIKIT_EXTERN NSString * const HWDownloadProgressNotification;                   // 进度回调通知
UIKIT_EXTERN NSString * const HWDownloadStateChangeNotification;                // 状态改变通知
UIKIT_EXTERN NSString * const HWDownloadMaxConcurrentCountKey;                  // 最大同时下载数量key
UIKIT_EXTERN NSString * const HWDownloadMaxConcurrentCountChangeNotification;   // 最大同时下载数量改变通知
UIKIT_EXTERN NSString * const HWDownloadAllowsCellularAccessKey;                // 是否允许蜂窝网络下载key
UIKIT_EXTERN NSString * const HWDownloadAllowsCellularAccessChangeNotification; // 是否允许蜂窝网络下载改变通知

/************************* 网络 *************************/
UIKIT_EXTERN NSString * const HWNetworkingReachabilityDidChangeNotification;    // 网络改变改变通知
