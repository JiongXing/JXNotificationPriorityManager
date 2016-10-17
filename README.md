# JXNotificationPriorityManager
# 问题
在向通知中心注册事件监听时，有两个问题：
- 不会去重，即每一次addObserver都会添加一次监听，当事件发生时，回调方法就会被多次调用(故意多次监听的除外)。
- 回调的顺序不能依赖代码来指定，即没有回调任务执行顺序这类机制存在。

以上，封装一个工具，在注册监听时，传入任务名(ID)和优先级来解决这些问题。

![JXNotificationPriorityHelper.gif][1]

# 核心代码
## JXNotificationPriorityManager.h
```objc
/// 传入通知名，返回实例。通知名对应的实例是全局唯一。
+ (nonnull instancetype)managerWithNotificationName:(nonnull NSString *)notificationName;

/// 添加任务。name任务名唯一；priority指定优先级
- (void)addTaskWithName:(nonnull NSString *)name priority:(JXNotificationPriority)priority action:(nonnull JXNotificationPriorityManagerActionBlock)action;

/// 移除任务
- (void)removeTaskForName:(nonnull NSString *)name;
```
# JXNotificationPriorityManager.m
```objc
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
```
另外，考虑如果引入异步回调的话，那么执行优化级的意义就不大了，所以本工具以同步方式逐个任务回调。

[1]:https://github.com/JiongXing/JXNotificationPriorityManager/raw/master/screenshots/JXNotificationPriorityManager.gif
