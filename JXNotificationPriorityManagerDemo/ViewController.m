//
//  ViewController.m
//  JXNotificationPriorityManagerDemo
//
//  Created by JiongXing on 2016/10/17.
//  Copyright © 2016年 JiongXing. All rights reserved.
//

#import "ViewController.h"
#import "JXNotificationPriorityManager.h"

NSString * const kCustomNoficationName = @"kCustomNoficationName";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)dealloc {
    JXNotificationPriorityManager *manager = [JXNotificationPriorityManager managerWithNotificationName:kCustomNoficationName];
    [manager removeTaskForName:@"TaskOne"];
    [manager removeTaskForName:@"TaskTwo"];
    [manager removeTaskForName:@"TaskThree"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)registerTaskOne:(UIButton *)sender {
    [self registerTaskName:@"TaskOne" priority:JXNotificationPriorityNormal];
}

- (IBAction)registerTaskTwo:(UIButton *)sender {
    [self registerTaskName:@"TaskTwo" priority:JXNotificationPriorityVeryHigh];
}

- (IBAction)registerTaskThree:(UIButton *)sender {
    [self registerTaskName:@"TaskThree" priority:JXNotificationPriorityLow];
}

- (IBAction)postNotification:(UIButton *)sender {
    self.textView.text = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCustomNoficationName object:nil];
}

- (void)registerTaskName:(NSString *)taskName priority:(JXNotificationPriority)priority {
    JXNotificationPriorityManager *manager = [JXNotificationPriorityManager managerWithNotificationName:kCustomNoficationName];
    [manager addTaskWithName:taskName priority:priority action:^(NSNotification * _Nonnull notification) {
        self.textView.text = [self.textView.text stringByAppendingFormat:@"执行%@...\n", taskName];
    }];
    self.textView.text = [NSString stringWithFormat:@"注册%@", taskName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
