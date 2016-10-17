//
//  JXNotificationPriorityManager.h
//  JXNotificationPriorityManagerDemo
//
//  Created by JiongXing on 2016/10/17.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JXNotificationPriorityManagerActionBlock)(NSNotification * _Nonnull notification);

typedef NS_ENUM(NSUInteger, JXNotificationPriority) {
    JXNotificationPriorityLow = 0,
    JXNotificationPriorityNormal = 1,
    JXNotificationPriorityHigh = 2,
    JXNotificationPriorityVeryHigh = 3,
};

@interface JXNotificationPriorityManager : NSObject

/// 传入通知名，返回实例。通知名对应的实例是全局唯一。
+ (nonnull instancetype)managerWithNotificationName:(nonnull NSString *)notificationName;

/// 添加任务。name任务名唯一；priority指定优先级
- (void)addTaskWithName:(nonnull NSString *)name priority:(JXNotificationPriority)priority action:(nonnull JXNotificationPriorityManagerActionBlock)action;

/// 移除任务
- (void)removeTaskForName:(nonnull NSString *)name;

/// 查询某任务是否已存在
- (BOOL)isExistedForName:(nonnull NSString *)name;

@end
