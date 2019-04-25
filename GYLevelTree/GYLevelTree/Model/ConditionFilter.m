//
//  ConditionFilter.m
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "ConditionFilter.h"

@implementation ConditionFilter


+(NSDictionary*)mj_objectClassInArray
{
    return @{@"statusItem":[ConditionFilter class]};
}

#pragma mark copying协议的方法 ------ 实现对象可变
- (id)copyWithZone:(NSZone *)zone {
    /*
    (NSZone *)zone的含义就是为要建副本对象已经准备好了新开辟的内存空间
    所有copy出来的对象是一个新的对象,修改它的属性不会影响源对象
    */
//     NSLog(@"对象浅拷贝");
    // 拷贝名字给副本对象
    ConditionFilter * copy = [[[self class] allocWithZone:zone] init];
    copy.name = self.name;
    copy.pid = self.pid;
    copy.nodeId = self.nodeId;
    copy.value = self.value;
    copy.statusItem = [[NSMutableArray alloc]initWithArray:self.statusItem copyItems:YES]; //把下一层级也进行拷贝；
    copy.ext =  self.ext;
    copy.level = self.level;
    copy.extend = self.extend;
    return copy;
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
//    NSLog(@"对象深拷贝");
    ConditionFilter * copy = [[[self class] alloc] init];
    copy.name = self.name;
    copy.pid = self.pid;
    copy.nodeId = self.nodeId;
    copy.value = self.value;
    copy.statusItem = self.statusItem;
    copy.ext =  self.ext;
    copy.level = self.level;
    copy.extend = self.extend;
    return copy;
}

@end
