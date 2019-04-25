//
//  GYLevelTreeViewController.m
//  GYLevelTree
//
//  Created by qiugaoying on 2019/4/25.
//  Copyright © 2019年 qiugaoying. All rights reserved.
//

#import "GYLevelTreeViewController.h"
#import "ConditionFilter.h"
#import "LevelItemCell.h"
#import "ConditionChooseItemCell.h"
#import "GYTableViewItemSheetView.h"

typedef enum : NSInteger {
    FilterSection_Color = 0, //颜色
    FilterSection_Size = 1, //尺寸
    FilterSection_Address = 2 //产地
} FilterSection;

typedef enum : NSInteger {
    Layout_TreeLevelStyle = 0, //树层级
    Layout_ComposeStyle = 1, //排列组合
} DataSectionShowStyle;



@interface GYLevelTreeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *datas;
@property(nonatomic,strong) NSMutableArray *sectionMenuArr; //规格筛选分组标识tag（FilterSection）
@property(nonatomic,strong) NSMutableDictionary *itemArrDic; //已选规格对象
@property(nonatomic,strong) NSMutableDictionary *itemSelectedArrDic; //已选择的规格项目数组
@property(nonatomic,strong) NSArray *mProductTypeList; //所有规格项目；

@property(nonatomic,strong) NSMutableArray *extendDelObjsArr; //收缩时候要移除的对象；
@property(nonatomic,strong) NSMutableArray *extendDelIndexPaths;

@property(nonatomic,assign) DataSectionShowStyle dataShowLayoutStyle; //数据展示样式；
@end

@implementation GYLevelTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"动态多层级树&排列组合";
    [self addTableView];
    
    _datas = [[NSMutableArray alloc]init];
    _dataShowLayoutStyle = Layout_ComposeStyle;
    _sectionMenuArr = [[NSMutableArray alloc]init];
    _extendDelObjsArr = [[NSMutableArray alloc]init];
    _extendDelIndexPaths = [[NSMutableArray alloc]init];
    _itemArrDic = [[NSMutableDictionary alloc]init];
    _itemSelectedArrDic = [[NSMutableDictionary alloc]init];
    
    [self prePareTestData_ProductTypeList];
    
    [self createFooterDescView];
}

- (void)addTableView{
    
    _tableView                              = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
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
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-20);
    }];
}

-(void)createFooterDescView
{
    UILabel *descLabel = [[UILabel alloc]init];
    descLabel.font = LJFontRegularText(12);
    descLabel.textColor = LJBlackColor;
    [self.view addSubview:descLabel];
    descLabel.text = @"@ http://gaoying.art";
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - 准备规格数据；
-(void)prePareTestData_ProductTypeList
{
    ConditionFilter *c0 = [[ConditionFilter alloc]init];
    c0.name = @"颜色";
    c0.value = FilterSection_Color;
    
    ConditionFilter *color1 = [[ConditionFilter alloc]init];
    color1.name = @"红色";
    ConditionFilter *color2 = [[ConditionFilter alloc]init];
    color2.name = @"蓝色";
    ConditionFilter *color3 = [[ConditionFilter alloc]init];
    color3.name = @"黑色";
    ConditionFilter *color4 = [[ConditionFilter alloc]init];
    color4.name = @"白色";
    c0.statusItem = @[color1,color2,color3,color4];
    
    
    ConditionFilter *size1 = [[ConditionFilter alloc]init];
    size1.name = @"X";
    ConditionFilter *size2 = [[ConditionFilter alloc]init];
    size2.name = @"L";
    ConditionFilter *size3 = [[ConditionFilter alloc]init];
    size3.name = @"XL";
    
    ConditionFilter *c1 = [[ConditionFilter alloc]init];
    c1.name = @"尺寸";
    c1.value = FilterSection_Size;
    c1.statusItem = @[size1,size2,size3];
    
    
    ConditionFilter *address1 = [[ConditionFilter alloc]init];
    address1.name = @"深圳";
    ConditionFilter *address2 = [[ConditionFilter alloc]init];
    address2.name = @"广州";
    ConditionFilter *c2 = [[ConditionFilter alloc]init];
    c2.name = @"产地";
    c2.value = FilterSection_Address;
    c2.statusItem = @[address1,address2];
    
    //这个值 业务上应该从服务器获取，这里只做本地模拟；
    self.mProductTypeList = @[c0,c1,c2];
}



#pragma mark - TabelViewDelegate  & TableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return self.sectionMenuArr.count + 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == self.sectionMenuArr.count){
        return self.datas.count;
    }
    return  1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == self.sectionMenuArr.count){
        ConditionFilter *filter = [self.datas objectAtIndex:indexPath.row];
         NSArray *statuItems = filter.statusItem;
        if(statuItems.count){
            //展开或收起 树层级；
            [self expandOrCloseLevelTreeAtIndexPath:indexPath];
        }else{
            
            if(self.dataShowLayoutStyle == Layout_TreeLevelStyle){
                //树层级样式，需找父类的name 一起拼接得到弹出提示
                NSMutableArray  *msgArr = [[NSMutableArray alloc]init];
                [msgArr addObject:filter.name];
                ConditionFilter *parent = filter.parent;
                while (parent) {
                    [msgArr insertObject:parent.name atIndex:0];
                    parent = parent.parent;
                }
                NSString *msg = [msgArr componentsJoinedByString:@"-"];
                [self gy_showHud:msg];
                
            }else{
                //排列组合样式；
                [self gy_showHud:filter.name];
            }
        }
    }
}

-(void)gy_showHud:(NSString *)showText
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.textColor = LJBlackColor;
    hud.animationType = MBProgressHUDAnimationZoomOut;
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.label.text = showText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.2];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == self.sectionMenuArr.count){
        
        LevelItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if(cell == nil){
            cell = [[LevelItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        
        cell.selectionStyle = 0;
        ConditionFilter *filter = [self.datas objectAtIndex:indexPath.row];
        cell.nameLabel.text = filter.name;
        cell.nameLabel.textColor = LJBlackColor;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        
        if(filter.statusItem.count){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if(filter.extend){
                cell.backgroundColor = LJGray4Color;
                cell.contentView.backgroundColor = LJGray4Color;
            }
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        [cell.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15*filter.level);
        }];
        
        return cell;
    }else{
        
        static NSString *identifier = @"ConditionChooseItemCell";
        ConditionChooseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil){
            cell = [[ConditionChooseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = 0;
        }
        
        NSInteger cellSectionTag  = [[self.sectionMenuArr objectAtIndex:indexPath.section] integerValue];
        NSMutableArray *selectArr = [_itemSelectedArrDic objectForKey:@(cellSectionTag)];
        cell.selectedItemArr = selectArr;
        ConditionFilter *sectionFilter = [_itemArrDic objectForKey:@(cellSectionTag)];
        cell.bMutiChooseFlag = YES;
        cell.dataList = sectionFilter.statusItem;
        
        __weak typeof(self) weakSelf = self;
        cell.selectMutiDoneBlock = ^(NSMutableArray *itemArr) {
            [weakSelf.itemSelectedArrDic setObject:itemArr forKey:@(cellSectionTag)];
            [weakSelf configDataSectionReload];
            [weakSelf.tableView reloadData];
        };
       
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == self.sectionMenuArr.count){
        return 50;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    UIView *viewForHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    viewForHeader.backgroundColor = [UIColor whiteColor];
    
    if(section == self.sectionMenuArr.count){
      
        CGRect rect = viewForHeader.frame;
        rect.size.height = 50;
        viewForHeader.frame = rect;
        
        UIButton * _treeStyleButton = [[UIButton alloc]init];
        [_treeStyleButton setTitle:@"树层级展示" forState:UIControlStateNormal];
        _treeStyleButton.tag = 1000;
        _treeStyleButton.selected = _dataShowLayoutStyle == Layout_TreeLevelStyle;
        [_treeStyleButton setTitleColor:LJBlackColor forState:0];
        _treeStyleButton.titleLabel.font = LJFontRegularText(14);
        [_treeStyleButton setImage:[UIImage imageNamed:@"circle_normal"] forState:UIControlStateNormal];
        [_treeStyleButton setImage:[UIImage imageNamed:@"circle_selected"] forState:UIControlStateSelected];
        [_treeStyleButton addTarget:self action:@selector(chooseDataLayoutStyleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewForHeader addSubview:_treeStyleButton];
        [_treeStyleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.bottom.mas_equalTo(0);
        }];
        [_treeStyleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
        
       UIButton *  _composeStyleButton = [[UIButton alloc]init];
        [_composeStyleButton setTitle:@"排列组合" forState:0];
        if(_dataShowLayoutStyle == Layout_ComposeStyle){
            [_composeStyleButton setTitle:[NSString stringWithFormat:@"排列组合(%ld种)",self.datas.count] forState:UIControlStateNormal];
        }
        _composeStyleButton.tag = 1001;
        _composeStyleButton.selected = _dataShowLayoutStyle == Layout_ComposeStyle;
        [_composeStyleButton setImage:[UIImage imageNamed:@"circle_normal"] forState:UIControlStateNormal];
        [_composeStyleButton setImage:[UIImage imageNamed:@"circle_selected"] forState:UIControlStateSelected];
        [_composeStyleButton setTitleColor:LJBlackColor forState:0];
        _composeStyleButton.titleLabel.font = LJFontRegularText(14);
        [_composeStyleButton addTarget:self action:@selector(chooseDataLayoutStyleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewForHeader addSubview:_composeStyleButton];
        [_composeStyleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_treeStyleButton.mas_right).offset(35);
            make.top.bottom.mas_equalTo(0);
        }];
        [_composeStyleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
        
        UIButton *clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickBtn setTitleColor:LJBlackColor forState:0];
        [viewForHeader addSubview:clickBtn];
        [clickBtn setImage:[UIImage imageNamed:@"item_add"] forState:0];
        [clickBtn setTitle:@"添加规格" forState:0];
        clickBtn.layer.cornerRadius = 3;
        clickBtn.layer.masksToBounds = YES;
        [clickBtn addTarget:self action:@selector(clickShowAddMenuListAction) forControlEvents:UIControlEventTouchUpInside];
        [clickBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        clickBtn.titleLabel.font = LJFontRegularText(14);
        [clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@32);
            make.centerY.mas_equalTo(viewForHeader);
            make.right.mas_equalTo(-20);
            make.width.equalTo(@100);
        }];
        //添加button
    }else{
        
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 2, 10)];
        iconView.backgroundColor = LJYellowColor;
        [viewForHeader addSubview:iconView];
        
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setTitleColor:LJRedColor forState:0];
        [viewForHeader addSubview:delBtn];
        [delBtn setTitle:@"删除" forState:0];
        delBtn.layer.cornerRadius = 3;
        delBtn.layer.masksToBounds = YES;
        [delBtn addTarget:self action:@selector(clickDelMenuSectionAction:) forControlEvents:UIControlEventTouchUpInside];
        delBtn.titleLabel.font = LJFontRegularText(14);
        [delBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@30);
            make.width.equalTo(@55);
            make.centerY.mas_equalTo(viewForHeader);
            make.right.mas_equalTo(-15);
        }];
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + 5, 5, SCREEN_W - 30, 30)];
        titleLbl.font = [UIFont systemFontOfSize:15];
        titleLbl.textColor = LJBlackColor;
        [viewForHeader addSubview:titleLbl];
        titleLbl.font = LJFontRegularText(15);
        
        NSInteger sectionTag = [[self.sectionMenuArr objectAtIndex:section] integerValue];
        delBtn.tag = 1000+sectionTag;
        switch (sectionTag) {
            case FilterSection_Size:
                  titleLbl.text = @"尺寸";
                break;
            case FilterSection_Color:
                titleLbl.text = @"颜色";
                break;
            case FilterSection_Address:
                titleLbl.text = @"产地";
                break;
            default:
                break;
        }
    }
    
    return viewForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == self.sectionMenuArr.count){
        return 50;
    }else{
        
        NSInteger cellSectionTag = [[self.sectionMenuArr objectAtIndex:indexPath.section] integerValue];
        ConditionFilter *sectionFilter = [_itemArrDic objectForKey:@(cellSectionTag)];
        if(sectionFilter.statusItem.count){
            NSInteger rowNum = ceil(sectionFilter.statusItem.count/3.0);
            return 38*rowNum*LJFontWidthScale + 10*(rowNum-1) + 20;
        }
    }
    return 0;
}

#pragma mark -展开 或 收起 树层级；
-(void)expandOrCloseLevelTreeAtIndexPath:(NSIndexPath *)indexPath{
    
    ConditionFilter *filter = [self.datas objectAtIndex:indexPath.row];
    NSArray * statuItems = filter.statusItem;
    if(filter.extend == NO){
        //展开下级；
        filter.extend = YES;
        
        for (ConditionFilter *f1 in statuItems) {
            f1.extend = NO;
        }
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:((NSRange){indexPath.row + 1, statuItems.count})];
        [self.datas insertObjects:statuItems atIndexes:indexes];
        
        // 动画
        NSMutableArray *indexPaths = [NSMutableArray new];
        [statuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 + idx inSection:indexPath.section];
            [indexPaths addObject:tmpIndexPath];
        }];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.backgroundColor = LJGray4Color;
        cell.contentView.backgroundColor = LJGray4Color;
        
    }else{
        
        //收缩所有下级；
        
        //移除对象 ，对象有可能重复；而实际是只需移除下级；需精确移除某位置的对象；
        //                [self.datas removeObjectsInArray:statuItems];
        
        //只能移除一级；不能移除子集已展开的子集
        //                 NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:((NSRange){indexPath.row + 1, statuItems.count})];
        //                [self.datas removeObjectsAtIndexes:indexes];
        
        // 动画
        //                NSMutableArray *indexPaths = [NSMutableArray new];
        //                [statuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //
        //                    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 + idx inSection:indexPath.section];
        //                    [indexPaths addObject:tmpIndexPath];
        //                }];
        
        
        //移除改节点下的所有子集；（递归）
        [self.extendDelObjsArr removeAllObjects];
        [self.extendDelIndexPaths removeAllObjects];
        [self findDelLevelObjByPid:filter.nodeId];
        [self.datas removeObjectsInArray:self.extendDelObjsArr];
        
        [self.tableView deleteRowsAtIndexPaths:self.extendDelIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.extendDelObjsArr removeAllObjects];
        [self.extendDelIndexPaths removeAllObjects];
        
        // model关闭后不可获取submodels
        filter.extend = NO;
        
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - 点击删除组
-(void)clickDelMenuSectionAction:(UIButton *)delBtn
{
    NSInteger cellSectionTag = delBtn.tag - 1000;
    
    [self.itemArrDic removeObjectForKey:@(cellSectionTag)];
    [self.itemSelectedArrDic removeObjectForKey:@(cellSectionTag)];
    
    NSInteger  sectionIndex = [self.sectionMenuArr indexOfObject:[NSNumber numberWithInteger:cellSectionTag]];
    [self.sectionMenuArr removeObject:@(cellSectionTag)];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:(UITableViewRowAnimationFade)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self configDataSectionReload];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.sectionMenuArr.count] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - 点击添加规格
-(void)clickShowAddMenuListAction
{
    NSMutableArray *mAddTypeList = [[NSMutableArray alloc]initWithArray:self.mProductTypeList];
    NSMutableArray *removeArr = [[NSMutableArray alloc]init];
    for (NSNumber *cellSectionTag  in self.sectionMenuArr) {
        for (ConditionFilter *filter in mAddTypeList) {
            if(filter.value == cellSectionTag.integerValue){
                [removeArr addObject:filter];
            }
        }
    }
    [mAddTypeList removeObjectsInArray:removeArr];
    
    if(mAddTypeList.count == 0){
        [self gy_showHud:@"暂无更多规格可添加"];
        return;
    }
    
    GYTableViewItemSheetView *sheetView = [[GYTableViewItemSheetView alloc]initWithTitle:@"选择规格项目"  dataArr:mAddTypeList  actionBlock:^(NSArray *selectedDataArr) {
        
        if(selectedDataArr.count){
            
            for(ConditionFilter *item in selectedDataArr){
                
                //添加section
                [self.sectionMenuArr addObject:@(item.value)];
                [self.itemArrDic setObject:item forKey:@(item.value)];
                [self.itemSelectedArrDic setObject:[[NSMutableArray alloc]init] forKey:@(item.value)];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.sectionMenuArr.count-1] withRowAnimation:(UITableViewRowAnimationFade)];
            }
        }
    }];
    [sheetView showInView];
}

#pragma mark -选择数据展示样式；
-(void)chooseDataLayoutStyleBtnAction:(UIButton *)button
{
    if(button.tag == 1000){
        _dataShowLayoutStyle = Layout_TreeLevelStyle;
    }else{
        _dataShowLayoutStyle = Layout_ComposeStyle;
    }
    
    [self configDataSectionReload];
    [self.tableView reloadData];
}


#pragma mark - 从最后一个层级算起；往父类赋值；(核心: 给statusItem赋值)
-(void)configDataSectionReload
{
    //可变集合的copy 和 mutableCopy 是一样；深拷贝，地址不一样；
    //这里需用copy ,如果不用copy会造成多个地方引用地址对象；值会随着关联；
    //    NSMutableDictionary *selectDic = [self.itemSelectedArrDic mutableCopy];
    
    //先过滤出已选择的menuSection
    NSMutableArray *hasChooseSectionMenuArr = [[NSMutableArray alloc]init];
    for(NSNumber *cellSectionTag in self.sectionMenuArr){
        NSArray * itemChooseArr = [self.itemSelectedArrDic objectForKey:cellSectionTag];
        if(itemChooseArr.count){
            [hasChooseSectionMenuArr addObject:cellSectionTag];
        }
    }
    
    
    NSMutableArray *childArr = nil;
    for (NSInteger level = hasChooseSectionMenuArr.count; level>0; level -- ) {
        
        NSNumber *cellSectionTag = [hasChooseSectionMenuArr objectAtIndex:level-1];
        
        //标记等级
        NSMutableArray *itemSelectArr = [[self.itemSelectedArrDic objectForKey:cellSectionTag] mutableCopy];
        for(NSInteger i=0; i< itemSelectArr.count; i++){
            ConditionFilter *item = [itemSelectArr objectAtIndex:i];
            item.level = level;
            item.extend = NO;
            item.nodeId = nil;
            item.pid = nil;
            
            //方式一
            // item.statusItem = [childArr mutableCopy]; //并没有实现真正意义上的深拷贝
            
            //让每个section持有的对象都是唯一性
//              NSMutableArray *childItemArr = [[NSMutableArray alloc]init];
//              for (ConditionFilter *filterItem in  childArr) {
//                [childItemArr addObject:[filterItem mutableCopy]];
//              }
            
            //方式二 （这里使用拷贝原因是为了 展开收缩所有子层级元素）
            item.statusItem = [[NSMutableArray alloc]initWithArray:childArr copyItems:YES]; //触发自定义对象copy消息方法
        }
        childArr = [itemSelectArr mutableCopy]; //（防止对childArr的来源数据源污染,这里使用拷贝）（fillParentNodeId 会对数据源childArr 进行污染；如改变对象的name等设置）
    }
    
    //清空
    [self.datas removeAllObjects];
    
    //填充子节点绑定父节点id  ；
    [self fillParentNodeId:childArr parentNode:nil];
}



#pragma mark - 从前往后赋值 :（ 给子节点绑定标识父类；设置展开样式;）
-(void)fillParentNodeId:(NSArray *)itemArr parentNode:(ConditionFilter *)parent
{
    
    for(NSInteger i =0 ;i < itemArr.count; i++){
        
        ConditionFilter *filter = [itemArr objectAtIndex:i];
        filter.pid = parent.nodeId;
        filter.parent = parent;
        NSString *nodeStr = [GYLevelTreeViewController uniqueStringForMessage];
        filter.nodeId = nodeStr;
        filter.extend = filter.statusItem.count;
        
        if(self.dataShowLayoutStyle == Layout_ComposeStyle){
            //排列组合样式；
            if(filter.statusItem.count == 0){
                
                NSMutableArray  *allJoinNamesArr = [[NSMutableArray alloc]init];
                [allJoinNamesArr addObject:filter.name];
                ConditionFilter *parent = filter.parent;
                while (parent) {
                    [allJoinNamesArr insertObject:parent.name atIndex:0];
                    parent = parent.parent;
                }
                NSString *allJoinName = [allJoinNamesArr componentsJoinedByString:@"-"];
                filter.name = allJoinName; //拼接UI显示的name
                filter.level = 1; //设置等级层次1 （label显示时候的左边距）
                [self.datas addObject:filter]; //只添加最后一个层级；
            }
        }else{
            
            //树层级 样式（全部添加）
            [self.datas addObject:filter];
        }
        
        //递归
        [self fillParentNodeId:filter.statusItem  parentNode:filter];
    }
}


#pragma mark - 找到将要收缩的子集；包含多层分级的子集；递归寻找；
-(void)findDelLevelObjByPid:(NSString *)pId
{
    //因分组展开后的数据也是存在于datas ，所以全部集合都在datas 中查找Pid
    for(NSInteger i =0 ;i < self.datas.count; i++){
        ConditionFilter *filter = [self.datas objectAtIndex:i];
        if([filter.pid isEqualToString:pId]){
            
            //对象
            [self.extendDelObjsArr addObject:filter];
            
            //位置
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i inSection:self.sectionMenuArr.count];
            [self.extendDelIndexPaths addObject:tmpIndexPath];
            
            //递归寻找
            [self findDelLevelObjByPid:filter.nodeId];
        }
    }
}


+(NSString *)uniqueStringForMessage
{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    
    CFRelease(uuidRef);
    
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    
    return uniqueId;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
