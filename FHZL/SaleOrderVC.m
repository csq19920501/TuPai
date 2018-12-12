//
//  SaleOrderVC.m
//  FHZL
//
//  Created by hk on 2018/12/11.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "SaleOrderVC.h"
#import "FSSegmentTitleView.h"
#import "Header.h"
#import "SaleOrderCell.h"
#import "LogisticsVC.h"
@interface SaleOrderVC ()<FSSegmentTitleViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) FSSegmentTitleView *titleView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *myTableview;
@end

@implementation SaleOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"销售订单";
    self.dataArray = [NSMutableArray arrayWithArray:@[@"1",@"1",@"1",@"1",@"1"]];
    self.titleView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.7];
    [self.myTableview registerNib:[UINib nibWithNibName:@"SaleOrderCell"    bundle:nil] forCellReuseIdentifier:@"SaleOrderCell"];
}
#pragma mark UItableviewdele
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 196;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SaleOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SaleOrderCell"];
    MPWeakSelf(self)
    cell.uploadNumber = ^{
        LogisticsVC *VC = [LogisticsVC new];
        [weakself.navigationController pushViewController:VC animated:YES];
    };
    return cell;
}
#pragma mark FSSegmentTitleViewDelegate
- (void)FSSegmentTitleView:(FSSegmentTitleView *)titleView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    if (startIndex == endIndex) {
        return;
    }
    switch (endIndex) {
        case 0:
        {
            self.dataArray = [NSMutableArray arrayWithArray:@[@"1",@"1",@"1",@"1",@"1"]];
        }
            break;
        case 1:
        {
            self.dataArray = [NSMutableArray arrayWithArray:@[@"1"]];
        }
            break;
        case 2:
        {
            self.dataArray = [NSMutableArray arrayWithArray:@[@"1",@"1"]];
        }
            break;
            
        default:
            break;
    }
    [_myTableview reloadData];
}



-(FSSegmentTitleView*)titleView{
    if (!_titleView) {
        _titleView = [[FSSegmentTitleView alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, 50) titles:@[@"全部",@"待发货",@"已收货"] delegate:self indicatorType:FSIndicatorTypeEqualTitle];
        
        [self.view addSubview:_titleView];
    }
    return  _titleView;
}
-(UITableView *)myTableview{
    if (!_myTableview) {
        _myTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, kTopHeight + 55, kScreenWidth , kScreenHeight - (kTopHeight + 55)) style:UITableViewStylePlain];
        _myTableview.delegate =self;
        _myTableview.dataSource = self;
        [self.view addSubview:_myTableview];
    }
    return _myTableview;
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
