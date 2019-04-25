//
//  GYTableViewItemSheetView.h
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
  多选item
 */

typedef void(^GYActionDataDoneBlock)(NSArray *selectedDataArr);

@interface GYTableViewItemSheetView : UIView

- (instancetype)initWithTitle:(NSString *)title dataArr:(NSArray *)dataArr actionBlock:(GYActionDataDoneBlock)actionDataDoneBlock;

-(void)showInView;

@end
