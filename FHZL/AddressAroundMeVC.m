//
//  AddressAroundMeVC.m
//  FHZL
//
//  Created by hk on 2018/2/1.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "AddressAroundMeVC.h"
#import "Header.h"
#import "AddressSingelModel.h"
#import "UserManager.h"

@interface AddressAroundMeVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,BMKPoiSearchDelegate,UISearchResultsUpdating,UISearchControllerDelegate,BMKSuggestionSearchDelegate>
{
    UISearchBar*  searchBar;
    NSMutableArray *addressArray;
    NSMutableArray *otherAddressArray;
    BMKPoiSearch *poiSearch;//周边搜索
    BMKSuggestionSearch *suggestionSearch;//任一搜索
    AddressSingelModel *seleModel;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstant;
// 搜索控制器
@property (nonatomic, strong) UISearchController *searchController;
// 搜索使用的表示图控制器
@property (nonatomic, strong) UITableViewController *searchTVC;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AddressAroundMeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topConstant.constant = kTopHeight;
    // Do any additional setup after loading the view from its nib.
    [self loadData];
    [self setNavi];
    [self setVies];
}
-(void)loadData{
    addressArray = [NSMutableArray array];
    otherAddressArray = [NSMutableArray array];
        AddressSingelModel *userAddress = [[AddressSingelModel alloc]init];
        userAddress.addressName = USERMANAGER.mapDetial.addressStr;
        [addressArray addObject:userAddress];
    if (_seleModel) {
        [addressArray addObject:_seleModel];
        seleModel = _seleModel;
    }else{
        seleModel = userAddress;
    }
}
-(void)setVies{
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.placeholder = @"搜索位置";
    searchBar.frame = CGRectMake(0, 0, kScreenWidth, 40);
    _myTableView.tableHeaderView = searchBar;
    
    [UIUtil showProgressHUD:nil inView:self.view];
    poiSearch =[[BMKPoiSearch alloc]init];
    poiSearch.delegate = self;
    suggestionSearch = [[BMKSuggestionSearch alloc] init];
    suggestionSearch.delegate = self;
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 1;  //当前索引页
    option.pageCapacity = 10; //分页量
    option.location = USERMANAGER.mapDetial.userCoordinate;
    option.keyword = USERMANAGER.mapDetial.addressStr;
    option.radius = 3000;
    BOOL flag = [poiSearch poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        [UIUtil showToast:@"周边检索失败" inView:self.view];
        NSLog(@"周边检索发送失败");
    }
}

-(void)setNavi{
    self.view.backgroundColor = HBackColor;
    [self addNavigationItemWithTitles
     :@[@"完成"] isLeft:NO target:self action:@selector(showRight) tags:@[@1001]];
    self.title = @"所在位置";
}
-(void)showRight{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.didFinishPickingAddressHandle) {
            self.didFinishPickingAddressHandle(seleModel);
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma tableDele
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _myTableView) {
        return addressArray.count;
    }else{
        return otherAddressArray.count;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _myTableView) {
        static NSString * identifier1 = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier1];
        }
        AddressSingelModel *model = addressArray[indexPath.row];
        cell.textLabel.text = model.addressName;
        cell.detailTextLabel.text = model.addressDetailName;
        if (model == seleModel) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }else{
        static NSString * identifier2 = @"cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier2];
        }
        AddressSingelModel *model = otherAddressArray[indexPath.row];
        cell.textLabel.text = model.addressName;
        cell.detailTextLabel.text = model.addressDetailName;
//        if (model == seleModel) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }else{
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _myTableView) {
        seleModel = addressArray[indexPath.row];
        [_myTableView reloadData];
    }else{
        AddressSingelModel *model = otherAddressArray[indexPath.row];
        if (_seleModel) {
            _seleModel.addressName = model.addressName;
            _seleModel.addressDetailName = model.addressDetailName;
            seleModel = _seleModel;
            [_myTableView reloadData];
            [_searchController dismissViewControllerAnimated:YES completion:^{}];
        }else{
            if (addressArray.count >0) {
                [addressArray insertObject:model atIndex:1];
                _seleModel = model;
                seleModel = _seleModel;
                [_myTableView reloadData];
                [_searchController dismissViewControllerAnimated:YES completion:^{}];
            }else{
                [_searchController dismissViewControllerAnimated:YES completion:^{}];
            }
        }
    }
}
#pragma searchbarDele
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // 创建出搜索使用的表示图控制器
    self.searchTVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _searchTVC.tableView.dataSource = self;
    _searchTVC.tableView.delegate = self;
    _searchTVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 使用表示图控制器创建出搜索控制器
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_searchTVC];
    _searchController.view.backgroundColor = Kcolor(239.0, 239.0, 244.0, 0.7);
    // 搜索框检测代理
    //（这个需要遵守的协议是 <UISearchResultsUpdating> ，这个协议中只有一个方法，当搜索框中的值发生变化的时候，代理方法就会被调用）
    _searchController.searchResultsUpdater = self;
    _searchController.delegate = self;
    
    _searchController.searchBar.placeholder = @"搜索位置";
    //  _searchController.searchBar.delegate = self;
    [self presentViewController:_searchController animated:YES completion:^{
        // 当模态推出这个searchController的时候,需要把之前的searchBar隐藏,如果希望搜索的时候看不到热门搜索什么的,可以把这个页面给隐藏
//        searchBar.hidden = YES;
//        self.view.hidden = YES;
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击搜索");
    [searchBar resignFirstResponder];
    [self.view  endEditing:YES];
}
#pragma mark - UISearchResultsUpdating Method
#pragma mark 监听者搜索框中的值的变化
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSLog(@"updateSearchResultsForSearchController");
    BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = USERMANAGER.mapDetial.cityStr;;
    option.keyword = searchController.searchBar.text;
    if (!kStringIsEmpty(searchController.searchBar.text)) {
        [UIUtil showProgressHUD:@"搜索..." inView:self.view];
        BOOL flag = [suggestionSearch suggestionSearch:option]; //触发BMKSuggestionSearchDelegate方法
        if(flag)
        {
            NSLog(@"语音:建议检索发送成功");
        }
        else
        {
            [UIUtil showToast:@"搜索失败" inView:self.view];
            NSLog(@"语音:建议检索发送失败");
        }
    }
}
#pragma mark --- BMKSuggestionSearchDelegate

//返回suggestion搜索结果
- (void)onGetSuggestionResult:(BMKSuggestionSearch *)searcher result:(BMKSuggestionResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) //搜索结果正常
    {
        [UIUtil hideProgressHUD];
        [otherAddressArray removeAllObjects];
        for (int i = 0;  i < result.ptList.count; i++)
        {
            AddressSingelModel *model = [[AddressSingelModel alloc] init];
            model.addressName = result.keyList[i];
            model.addressDetailName = [NSString stringWithFormat:@"%@%@",result.cityList[i],result.districtList[i]];
            NSValue *va = result.ptList[i];
            CLLocationCoordinate2D coordinate;
            [va getValue:&coordinate];
            model.modelCoordinate = coordinate;
            [otherAddressArray addObject:model];
        }
        [_searchTVC.tableView reloadData];
    }else{
        [UIUtil showToast:@"搜索失败" inView:self.view];
    }
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    _searchController.delegate = nil;
}
-(void)didDismissSearchController:(UISearchController *)searchController{
//    searchBar.hidden = NO;
//    self.view.hidden = NO;
    _searchController.delegate = nil;
}
//(2)当View将要出现的时候, view显示
- (void)viewWillAppear:(BOOL)animated
{
//    self.view.hidden = NO;
}
//(3) 取消按钮触发方法, 点击取消后,self.bar和self.view显示出来
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
//    searchBar.hidden = NO;
//    self.view.hidden = NO;
}
#pragma poiSearch
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        if (!kArrayIsEmpty(poiResultList.poiInfoList)) {
            for (BMKPoiInfo *poi in poiResultList.poiInfoList) {
                AddressSingelModel *model = [[AddressSingelModel alloc]init];
                model.addressName = poi.name;
                model.addressDetailName = poi.address;
                [addressArray addObject:model];
            }
            [_myTableView reloadData];
        }
        [UIUtil hideProgressHUD];
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        NSLog(@"起始点有歧义");
        [UIUtil showToast:@"起始点有歧义" inView:self.view];
    } else {
        NSLog(@"抱歉，未找到结果");
        [UIUtil showToast:@"未找到结果" inView:self.view];
    }
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
