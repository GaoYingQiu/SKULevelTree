//
//  ConditionChooseItemCell.h
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConditionFilter.h"

typedef void(^GYConditionChooseItemCellBlock)(ConditionFilter *item);
typedef void(^GYConditionMutiChooseItemCellBlock)(NSMutableArray *itemArr);

@interface ConditionChooseItemCell : UITableViewCell

@property(nonatomic,assign) ConditionFilter *selectedItem; //选中的(单选)
@property(nonatomic,assign) BOOL bMutiChooseFlag; //是否为多选；
@property(nonatomic,strong) NSMutableArray *selectedItemArr; //选中的（多选）
@property(nonatomic,strong) UICollectionView *dataCollection;
@property(nonatomic,strong) NSArray *dataList; //数据源
@property (nonatomic,copy) GYConditionChooseItemCellBlock selectDoneBlock;
@property (nonatomic,copy) GYConditionMutiChooseItemCellBlock selectMutiDoneBlock;
@end
