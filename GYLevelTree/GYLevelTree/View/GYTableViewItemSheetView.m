//
//  GYTableViewItemSheetView.m
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "GYTableViewItemSheetView.h"
#import "ConditionChooseItemCell.h"

@interface GYTableViewItemSheetView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *doneBtn;
@property (nonatomic,strong) UIView *doneView;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) NSMutableArray *selectedArr; //已选中的；
@property (nonatomic,copy) GYActionDataDoneBlock actionDataDoneBlock;
@property (nonatomic,strong) NSString *titleStr;
@end

@implementation GYTableViewItemSheetView

- (instancetype)initWithTitle:(NSString *)title dataArr:(NSArray *)dataArr actionBlock:(GYActionDataDoneBlock)actionDataDoneBlock
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    
    if (self) {
     
        _selectedArr = [[NSMutableArray alloc]init];
        _titleStr = title;
        _actionDataDoneBlock = actionDataDoneBlock;
        _dataSource = dataArr;
        [self _initSetUp];
    }
    
    return self;
}

-(void)showInView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
 
    [UIView animateWithDuration:0.33 animations:^{
    
        self.containerView.frame = CGRectMake(0, SCREEN_H - (270 + 50) +10 , SCREEN_W ,  270 + 50 );
    }];
}

- (void)_initSetUp {
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.masksToBounds = YES;

    self.backgroundColor = [UIColor colorWithWhite:0.01 alpha:0.75];
    [self addSubview:self.containerView];
    
    [self addDataCollection];
    
    //工具类
    _doneView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    _doneView.backgroundColor = [UIColor whiteColor];
    UIView * _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor colorWithRed:197/255.0 green:197/255.0 blue:197/255.0 alpha:1.0];
    [_doneView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.equalTo(@0.5);
    }];
    [self.containerView addSubview:self.doneView];
    [_doneView addSubview:self.cancelBtn];

    
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.width.height.equalTo(@44);
        make.centerY.mas_equalTo(self.doneView);
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.font = LJFontSemiboldText(16);
    titleLabel.textColor = LJBlackColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.text =  _titleStr;
    
    [_doneView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.doneView);
    }];
    
    UIView  *bottomActionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 70)];
    bottomActionView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:bottomActionView];
    [bottomActionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.height.equalTo(@70);
    }];
    
    [bottomActionView addSubview:self.doneBtn];
    
    self.doneBtn.layer.cornerRadius = 3;
    self.doneBtn.layer.masksToBounds = YES;
    self.doneBtn.backgroundColor = LJYellowColor;
    [self.doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.centerX.mas_equalTo(bottomActionView);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.bottom.mas_equalTo(-20);
    }];
}

-(void)addDataCollection{
    
    _tableView                              = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorInset               = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.estimatedRowHeight           = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.scrollsToTop                 = YES;
    _tableView.tableFooterView              = [[UIView alloc] init];
    _tableView.delegate                     = self;
    _tableView.dataSource                   = self;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.separatorStyle = 0;
    _tableView.rowHeight = 44;
    [self.containerView addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(50);
        make.bottom.mas_equalTo(-70);
    }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.dataSource.count){
        NSInteger rowNum = ceil(self.dataSource.count/3.0);
        return 38*rowNum*LJFontWidthScale + 10*(rowNum-1) + 20;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ConditionChooseItemCell";
    ConditionChooseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[ConditionChooseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = 0;
    }
    
    cell.selectedItemArr = self.selectedArr;
    cell.bMutiChooseFlag = YES;
    cell.dataList = self.dataSource;
    __weak typeof(self) weakSelf = self;
    cell.selectMutiDoneBlock = ^(NSMutableArray *itemArr) {
        weakSelf.selectedArr = itemArr;
        [weakSelf.tableView reloadData];
    };
    
    return cell;
}


#pragma mark response

- (void)cancelAction:(UIButton *)sender {

    [self hide];
}


- (void)doneAction:(UIButton *)sender {
    
    if(self.actionDataDoneBlock){
        self.actionDataDoneBlock(self.selectedArr);
    }
    [self hide];
}

- (void)hide{
    
    [UIView animateWithDuration:0.22
                     animations:^{
                        
                        self.containerView.frame = CGRectMake(0, self.frame.size.height, self.containerView.frame.size.width, self.containerView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
    if(self.actionDataDoneBlock){
        
        self.actionDataDoneBlock(nil);
    }
    
}

#pragma mark setter/getter

- (UIButton *)cancelBtn {
    
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setImage:[UIImage imageNamed:@"pay_nav_close"]
                    forState:UIControlStateNormal];
        _cancelBtn.tag = 100;
        [_cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = LJFontRegularText(14);
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
    
}

- (UIButton *)doneBtn {
    
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc] init];
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        _doneBtn.tag = 200;
        [_doneBtn setTitleColor:LJBlackColor forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = LJFontRegularText(16);
        [_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

@end
