//
//  ConditionFilter.h
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ConditionFilter;

@interface ConditionFilter : NSObject<NSCopying,NSMutableCopying>

@property(nonatomic,assign) NSInteger value;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,copy) NSArray *statusItem;

@property(nonatomic,strong) ConditionFilter *parent; //父节点（父只有一个）
@property(nonatomic,strong) NSString *pid; //父节点编号 (随机生成)
@property(nonatomic,strong) NSString *nodeId; //节点编号 (随机生成)
@property(nonatomic,strong) NSDictionary *ext; //扩展字段
@property(nonatomic,assign) BOOL extend; //是否展开
@property(nonatomic,assign) NSInteger  level;//当前层级
@end
