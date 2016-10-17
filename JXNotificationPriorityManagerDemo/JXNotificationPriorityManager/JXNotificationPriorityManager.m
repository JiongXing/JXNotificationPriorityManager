//
//  JXNotificationPriorityManager.m
//  JXNotificationPriorityManagerDemo
//
//  Created by JiongXing on 2016/10/17.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "JXNotificationPriorityManager.h"

@interface JXNotificationPriorityManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<NSString *> *> *queueData;
@property (nonatomic, strong) NSMutableDictionary<NSString *, JXNotificationPriorityManagerActionBlock> *blocks;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *priorities;

@end

@implementation JXNotificationPriorityManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)managerWithNotificationName:(NSString *)notificationName {
    NSAssert(notificationName, @"通知名不能为空");
    
    static NSMutableDictionary *managers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        managers = [NSMutableDictionary dictionary];
    });
    JXNotificationPriorityManager *manager = managers[notificationName];
    if (!manager) {
        manager = [[JXNotificationPriorityManager alloc] init];
        managers[notificationName] = manager;
        
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(didReceivedNotification:) name:notificationName object:nil];
    }
    return manager;
}

- (void)didReceivedNotification:(NSNotification *)notification {
    NSArray<NSNumber *> *descendSorted = [[self.queueData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber *num1 = obj1;
        NSNumber *num2 = obj2;
        if (num1 == num2) {
            return NSOrderedSame;
        }
        return [num1 integerValue] < [num2 integerValue] ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    [descendSorted enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NSString *> *blockNameArray = self.queueData[obj];
        [blockNameArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            JXNotificationPriorityManagerActionBlock block = self.blocks[obj];
            block(notification);
        }];
    }];
}

- (void)addTaskWithName:(NSString *)name priority:(JXNotificationPriority)priority action:(nonnull JXNotificationPriorityManagerActionBlock)action {
    if (!name || !action) {
        return;
    }
    name = [name copy];
    
    self.blocks[name] = action;
    self.priorities[name] = @(priority);
    
    NSMutableArray<NSString *> *blockNameArray = self.queueData[@(priority)];
    if (!blockNameArray) {
        blockNameArray = [NSMutableArray array];
        self.queueData[@(priority)] = blockNameArray;
    }
    
    if ([blockNameArray containsObject:name]) {
        [blockNameArray removeObject:name];
    }
    [blockNameArray addObject:name];
}

- (void)removeTaskForName:(NSString *)name {
    if (!name) {
        return;
    }
    name = [name copy];
    
    NSNumber *priority = self.priorities[name];
    NSMutableArray<NSString *> *blockNameArray = self.queueData[priority];
    [blockNameArray removeObject:name];
    
    [self.blocks removeObjectForKey:name];
    [self.priorities removeObjectForKey:name];
}

- (BOOL)isExistedForName:(NSString *)name {
    name = [name copy];
    return self.blocks[name] ? YES : NO;
}

#pragma mark - Data
- (NSMutableDictionary<NSNumber *,NSMutableArray<NSString *> *> *)queueData {
    if (!_queueData) {
        _queueData = [NSMutableDictionary dictionary];
    }
    return _queueData;
}

- (NSMutableDictionary<NSString *,JXNotificationPriorityManagerActionBlock> *)blocks {
    if (!_blocks) {
        _blocks = [NSMutableDictionary dictionary];
    }
    return _blocks;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)priorities {
    if (!_priorities) {
        _priorities = [NSMutableDictionary dictionary];
    }
    return _priorities;
}

@end
