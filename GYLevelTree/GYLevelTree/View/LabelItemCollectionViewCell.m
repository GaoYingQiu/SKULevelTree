//
//  LabelItemCollectionViewCell.m
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "LabelItemCollectionViewCell.h"

@implementation LabelItemCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor blackColor];
        //标题
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = LJFontRegularText(14);
        self.titleLabel.textColor = LJBlackColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(-10);
        }];
        
        self.selectCoverImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"item_select"]];
        self.selectCoverImageView.hidden = YES;
        [self addSubview:_selectCoverImageView];
        [_selectCoverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(0);
            make.height.width.equalTo(@28);
        }];
    }

    return self;

}

@end
