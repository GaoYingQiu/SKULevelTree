//
//  ConditionChooseItemCell.m
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//
#import "ConditionChooseItemCell.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "LabelItemCollectionViewCell.h"


static NSString  *const nineDataID2 = @"LabelItemCollectionViewCell";

@interface ConditionChooseItemCell()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation ConditionChooseItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor whiteColor];
        
        [self addDataCollection];
    }
    return self;
}

-(void)setDataList:(NSArray *)dataList
{
    _dataList = dataList;
    [_dataCollection reloadData];
}


-(void)addDataCollection{
    
    UICollectionViewLeftAlignedLayout* layout = [[UICollectionViewLeftAlignedLayout alloc]init];
    
    layout.footerReferenceSize = CGSizeMake(SCREEN_W, 7);
    layout.minimumInteritemSpacing = 20;
    
    _dataCollection = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _dataCollection.delegate = self;
    _dataCollection.dataSource = self;
    _dataCollection.scrollEnabled = NO;
    _dataCollection.backgroundColor = [UIColor whiteColor];
    _dataCollection.showsVerticalScrollIndicator= NO;
    _dataCollection.tag = 2;
    [self.contentView addSubview:_dataCollection];
    [_dataCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.dataCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"space"];
    
    [self.dataCollection registerClass:[LabelItemCollectionViewCell class] forCellWithReuseIdentifier:nineDataID2];
}

#pragma mark----UICollectionViewDelegate

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter)
    {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"space" forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor whiteColor];
        return footerView;
    }
    return nil;
}

-(NSInteger)numberOfSectionsInCollectionView:(nonnull UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _dataList.count;
}

-(UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    LabelItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:nineDataID2 forIndexPath:indexPath];
    cell.layer.cornerRadius = 3;
    cell.layer.masksToBounds = YES;
    cell.selectCoverImageView.hidden = YES;
    cell.backgroundColor = LJGray5Color;
    cell.titleLabel.textColor = LJBlackColor;
    cell.layer.borderColor = LJYellowLightColor.CGColor;
    cell.layer.borderWidth = 0;
    ConditionFilter *item = [self.dataList objectAtIndex:indexPath.row];
    cell.titleLabel.text = item.name;
    if(self.bMutiChooseFlag){
        
        //多选
        if([self.selectedItemArr containsObject:item]){
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.borderWidth = 1;
            cell.selectCoverImageView.hidden = NO;
            cell.titleLabel.textColor = LJBlackColor;
        }
        
    }else{
        if(item == self.selectedItem){
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.borderWidth = 1;
            cell.selectCoverImageView.hidden = NO;
            cell.titleLabel.textColor = LJBlackColor;
        }
    }
    return cell;
}

//设置元素的大小
-(CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    CGFloat collectionViewWidth = SCREEN_W - 70; //中间间隔20
    return CGSizeMake(collectionViewWidth/3, 38*LJFontWidthScale);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
        ConditionFilter *item = [self.dataList objectAtIndex:indexPath.row];
        self.selectedItem = item;
        
       if(self.bMutiChooseFlag){
           if([self.selectedItemArr containsObject:item]){
               [self.selectedItemArr removeObject:item];
           }else{
               [self.selectedItemArr addObject:item];
           }
       }
       [self.dataCollection reloadData];
       
        if(self.bMutiChooseFlag){
            if(self.selectMutiDoneBlock){
                self.selectMutiDoneBlock(self.selectedItemArr);
            }
        }else{
            if(self.selectDoneBlock){
                self.selectDoneBlock(item);
            }
        }
}



@end
