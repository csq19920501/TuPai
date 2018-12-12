//
//  NewMyVC.m
//  FHZL
//
//  Created by hk on 2018/12/10.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "NewMyVC.h"
#import "FSScrollContentView.h"
#import "FSBaseTableView.h"
#import "FSBottomTableViewCell.h"
#import "NewMyCell.h"
#import "FSScrollContentViewController.h"
#import "Header.h"
#import "TupaiCollectionVC.h"
#import "SaleOrderVC.h"
//#import <YYKit.h>
#import "CheckLogisticsVC.h"
#import "UserCenterOldVC.h"
@interface NewMyVC ()<UITableViewDelegate,UITableViewDataSource,FSPageContentViewDelegate,FSSegmentTitleViewDelegate>
@property (nonatomic, strong) FSBaseTableView *myTableview;
@property (nonatomic, strong) FSBottomTableViewCell *contentCell;
@property (nonatomic, strong) FSSegmentTitleView *titleView;
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation NewMyVC
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.navigationController.navigationBar.translucent = YES;
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor blueColor]];
    MPWeakSelf(self)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeScrollStatus) name:@"leaveTop" object:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"GotoCheckLogistics" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakself.navigationController pushViewController:[CheckLogisticsVC new] animated:YES];
    } ];
    
    self.title = @"我的图拍";
    [self addNavigationItemWithImageNames:@[@"back_icon"] isLeft:YES target:self action:@selector(showLeft) tags:nil];
    [self addNavigationItemWithTitles
     :@[@"设置"] isLeft:NO target:self action:@selector(showRight) tags:@[@1001]];
    
    
    self.myTableview = [[FSBaseTableView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
    _myTableview.delegate = self;
    _myTableview.dataSource = self;
    [self.view addSubview:_myTableview];
    [self.myTableview registerNib:[UINib nibWithNibName:@"NewMyCell" bundle:nil] forCellReuseIdentifier:@"NewMyCell"];
    self.canScroll = YES;
    NSArray *sortTitles = @[@"全部",@"待付款",@"待发货",@"待收货"];
    self.contentCell.currentTagStr = sortTitles[self.titleView.selectIndex];
    self.contentCell.isRefresh = YES;
}
-(void)showLeft{
    [APPDELEGATE.homeNavi popToRootViewControllerAnimated:YES];
}
-(void)showRight{
    UserCenterOldVC *VC = [UserCenterOldVC new];
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark notify
- (void)changeScrollStatus//改变主视图的状态
{
    self.canScroll = YES;
    self.contentCell.cellCanScroll = NO;
}
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 140 + kTopHeight;
    }
    return CGRectGetHeight(self.view.bounds) - 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.titleView = [[FSSegmentTitleView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50) titles:@[@"全部",@"待付款",@"待发货",@"待收货"] delegate:self indicatorType:FSIndicatorTypeEqualTitle];
    self.titleView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.7];
    return self.titleView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TopCellIdentifier = @"NewMyCell";
    if (indexPath.section == 0) {
        NewMyCell *topCell = [tableView dequeueReusableCellWithIdentifier:TopCellIdentifier];
        MPWeakSelf(self)
        topCell.collectionVC = ^{
            [weakself.navigationController pushViewController:[TupaiCollectionVC new] animated:YES];
        };
        topCell.saleClick = ^{
            [weakself.navigationController pushViewController:[SaleOrderVC new] animated:YES];
        };
        return topCell;
    }else{
        _contentCell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!_contentCell) {
            _contentCell = [[FSBottomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            NSArray *titles = @[@"全部",@"待付款",@"待发货",@"待收货"];
            NSMutableArray *contentVCs = [NSMutableArray array];
            int iTag = 0;
            for (NSString *title in titles) {
                
                FSScrollContentViewController *vc = [[FSScrollContentViewController alloc]init];
                vc.title = title;
                vc.iTag = iTag;
                [contentVCs addObject:vc];
                iTag++;
            }
            _contentCell.viewControllers = contentVCs;
            _contentCell.pageContentView = [[FSPageContentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) childVCs:contentVCs parentVC:self delegate:self];
            [_contentCell.contentView addSubview:_contentCell.pageContentView];
        }
        return _contentCell;
    }
}
#pragma mark FSSegmentTitleViewDelegate
- (void)FSContenViewDidEndDecelerating:(FSPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.titleView.selectIndex = endIndex;
    _myTableview.scrollEnabled = YES;//此处其实是监测scrollview滚动，pageView滚动结束主tableview可以滑动，或者通过手势监听或者kvo，这里只是提供一种实现方式
}

- (void)FSSegmentTitleView:(FSSegmentTitleView *)titleView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.contentCell.pageContentView.contentViewCurrentIndex = endIndex;
}

- (void)FSContentViewDidScroll:(FSPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex progress:(CGFloat)progress
{
    _myTableview.scrollEnabled = NO;//pageView开始滚动主tableview禁止滑动
}

#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat bottomCellOffset = [_myTableview rectForSection:1].origin.y;
    SDLog(@"scrollView.contentOffset.y = %f",scrollView.contentOffset.y);
    self.navigationController.navigationBar.alpha = (kTopHeight - scrollView.contentOffset.y)/kTopHeight;
    if (scrollView.contentOffset.y >= bottomCellOffset) {
        scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
        if (self.canScroll) {
            self.canScroll = NO;
            
            self.contentCell.cellCanScroll = YES;
        }
    }else{
        if (!self.canScroll) {//子视图没到顶部
            scrollView.contentOffset = CGPointMake(0, bottomCellOffset);
        }
    }
    self.tableView.showsVerticalScrollIndicator = _canScroll?YES:NO;
}

//-(FSBaseTableView *)tableView{
//    if (!_myTableview) {
//        _myTableview = [[FSBaseTableView alloc]initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight)];
//        _myTableview.delegate = self;
//        _myTableview.dataSource = self;
//        [self.view addSubview:_myTableview  ];
//    }
//    return _myTableview;
//}
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
