//
//  LevelItemCell.m
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "LevelItemCell.h"

@implementation LevelItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        self.nameLabel=[UILabel new];
        [self.contentView addSubview:_nameLabel];
        _nameLabel.font = LJFontRegularText(14);
        [_nameLabel sizeToFit];
        _nameLabel.textColor = LJBlackColor;
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
