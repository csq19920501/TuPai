//
//  FSScrollContentViewController.m
//  FSScrollViewNestTableViewDemo
//
//  Created by huim on 2017/5/23.
//  Copyright © 2017年 fengshun. All rights reserved.
//
#import "CheckLogisticsVC.h"
#import "FSScrollContentViewController.h"
//#import <SVPullToRefresh.h>
#import "NewMyContentCell.h"
/**
 * 随机数据
 */
//#define RandomData [NSString stringWithFormat:@"随机数据---%d", arc4random_uniform(1000000)]
static const NSString *GotoCheckLogistics = @"GotoCheckLogistics";
@interface FSScrollContentViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign) BOOL fingerIsTouch;
/** 用来显示的假数据 */
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation FSScrollContentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"---%@",self.title);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [FSScrollContentViewController randomColor];
    [self setupSubViews];
}

- (void)setupSubViews
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView  registerNib:[UINib nibWithNibName:@"NewMyContentCell" bundle:nil] forCellReuseIdentifier:@"NewMyContentCell"];
    [self.view addSubview:_tableView];

   
}

- (void)insertRowAtTop
{
//    for (int i = 0; i<5; i++) {
//        [self.data insertObject:RandomData atIndex:0];
//    }
//    __weak UITableView *tableView = self.tableView;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [tableView reloadData];
//    });
}

- (void)insertRowAtBottom
{
//    for (int i = 0; i<5; i++) {
//        [self.data addObject:RandomData];
//    }
//    __weak UITableView *tableView = self.tableView;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [tableView reloadData];
//        [tableView.infiniteScrollingView stopAnimating];
//    });
}

#pragma mark Setter
- (void)setIsRefresh:(BOOL)isRefresh
{
    _isRefresh = isRefresh;
    [self insertRowAtTop];
}

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;//self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 176;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewMyContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewMyContentCell"];
    cell.checkLogisticsClick = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoCheckLogistics" object:nil];
    };
    switch (self.iTag) {
        case 0:
            {
                if (indexPath.row % 3 == 0) {
                    [cell.stateLabel setTitle:@"待付款" forState:UIControlStateNormal];
                }else if (indexPath.row % 3 == 1) {
                    [cell.stateLabel setTitle:@"待发货" forState:UIControlStateNormal];
                }else if (indexPath.row % 3 == 2) {
                    [cell.stateLabel setTitle:@"待收货" forState:UIControlStateNormal];
                }
                
            }
            break;
        case 1:
        {
            [cell.stateLabel setTitle:@"待付款" forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            [cell.stateLabel setTitle:@"待发货" forState:UIControlStateNormal];
        }
            break;
        case 3:
        {
            [cell.stateLabel setTitle:@"待收货" forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark UIScrollView
//判断屏幕触碰状态
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.fingerIsTouch = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{

    self.fingerIsTouch = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.vcCanScroll) {
        scrollView.contentOffset = CGPointZero;
    }
    if (scrollView.contentOffset.y <= 0) {
//        if (!self.fingerIsTouch) {//这里的作用是在手指离开屏幕后也不让显示主视图，具体可以自己看看效果
//            return;
//        }
        
        self.vcCanScroll = NO;
        scrollView.contentOffset = CGPointZero;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"leaveTop" object:nil];//到顶通知父视图改变状态
    }
    self.tableView.showsVerticalScrollIndicator = _vcCanScroll?YES:NO;
}

#pragma mark LazyLoad


- (NSMutableArray *)data
{
    if (!_data) {
        self.data = [NSMutableArray array];
        for (int i = 0; i<5; i++) {
//            [self.data addObject:RandomData];
        }
    }
    return _data;
}

@end
