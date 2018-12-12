//
//  CityChangeViewController.m
//  LianChengTong
//
//  Created by macmini on 15/7/13.
//  Copyright (c) 2015年 ___SJHY___. All rights reserved.
//

#import "CityChangeViewController.h"
#import "cityModel.h"
//#import "DataBaseSimple.h"
#import "ChineseToPinyin.h"
#import "TopSwitchCsqView.h"
NSInteger mycompare(id a,id b,void*ctx)
{
    NSString*x = (NSString*)a;
    NSString*y = (NSString*)b;
    return[x compare:y options:NSCaseInsensitiveSearch];
}

@interface CityChangeViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchResultsUpdating,UISearchControllerDelegate>
{
    UITableView * myTableView;
    NSMutableArray *dataSourceArray;
    NSMutableArray *titles;
    NSMutableArray *statusArray;
    NSString *locationCity;
//    UISearchDisplayController * searchDisplayController;
    NSMutableArray *filterArray;
    UISearchBar *searchBar;
    NSMutableArray *cityArray;
//    DataBaseSimple * _simple;
}

@property (nonatomic, strong) NSMutableDictionary *sortDic;
@property (nonatomic, strong) NSMutableArray *sortkeys;
@property (nonatomic, strong) NSMutableArray *idKeys;
@property (nonatomic, strong) NSMutableDictionary *sortId;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchTVC;
@end

@implementation CityChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    cityArray = [NSMutableArray array];
//    _simple = [DataBaseSimple shareInstance];
    [self setNavigation];
    [self initDataSource];
    [self initTableView];
    [self ifIsFirst];
    
}
-(void)ifIsFirst{
    //是否第一次进入   是第一次进入则网络请求城市列表存储数据库
//    if (![USER_PLIST objectForKey:@"firstCity"]) {
//        [self loadCityDB];
//
//    }else
        // 不是则从数据库加载城市列表
        [self getCite];
}
-(void)setNavigation{
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 160, 40)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.frame = titleView.frame;
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.placeholder = @"城市名";
    [titleView addSubview:searchBar];
    searchBar.backgroundImage = [UIImage imageNamed:@"透明.jpg"];
    self.navigationItem.titleView = titleView;
    
//    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
}
-(void)backButton{
    [self  dismissViewControllerAnimated:YES completion:nil];
    
}
//网络请求城市列表存储数据库
//-(void)loadCityDB{
//    [SVProgressHUD show];
//    [NetHandle POSTDataWithLocatorString: DYLAN_URL_BASE(@"order/getallcity") params: nil requestSucceed:^(NSData *requestData) {
//
//        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableContainers error:nil];
//        ADLog(@"%@", dict);
//        if ([dict[@"code"]intValue] ==200) {
//            NSLog(@"/**/*/*/*/*/*大保健");
//            for (NSDictionary *goodDict in dict[@"listcity"]) {
//                cityModel *model = [[cityModel alloc]init];
//                model.region_id = goodDict[@"region_id"];
//                model.parent_id = goodDict[@"parent_id"];
//                model.region_name = goodDict[@"region_name"];
//                model.region_type = goodDict[@"region_type"];
//                model.agency_id = goodDict[@"agency_id"];
//
//                if (![_simple insertIntoDB:model]) {
//                    NSLog(@"insert error!");
//                }
//                //                            [cityArray addObject:model];
//            }
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//                [USER_PLIST setObject:@"one" forKey:@"firstCity"];
//                [USER_PLIST synchronize];
//                [self getCite];
//            });
//        } else
//            [ SVProgressHUD showImage:nil status:@" "];
//
//
//    } requestFailure:^(NSError *error) {
//        [ SVProgressHUD showImage:nil status:@"失败"];
//
//    }];
//
//}
//数据库加载城市列表
-(void)getCite{
    // [cityArray removeAllObjects];
    
//    NSMutableArray *dataArr = [NSMutableArray array];
    for (NSArray *array in dataSourceArray) {
        for (NSString *str in array) {
            [cityArray addObject:str];
        }
    }
//    [cityArray addObjectsFromArray:[_simple selectFromDB]];
    
//    NSMutableArray *nameArray = [NSMutableArray array];
//    for (int i = 0; i < cityArray.count; i ++) {
//        cityModel *model = cityArray[i];
//        //model.region_name 是城市名称
//        [nameArray addObject:model.region_name];
//    }
    
    [self sortDataByLetter:cityArray];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [myTableView reloadData];
    });
    
}

//城市首字母排序
-(void)sortDataByLetter:(NSArray *)array{
    
    _sortDic = [[NSMutableDictionary alloc] init];
    _sortkeys = [NSMutableArray array];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    
    for (NSString *name in array) {
        
        char fChar=[ChineseToPinyin sortSectionTitle:name];
        NSString *letter=[NSString stringWithFormat:@"%c",fChar];
        NSString *utfLetter = [letter stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSMutableArray *array = [_sortDic objectForKey:utfLetter];
        if (array == nil) {
            array = [NSMutableArray array];
            [_sortDic setObject:array forKey:letter];
            [keys addObject:letter];
        }
        
        [array addObject:name];
    }
    
    _sortkeys = (NSMutableArray *)[keys sortedArrayUsingFunction:mycompare context:NULL];
    
    NSLog(@"111111------- %@",_sortkeys);
    NSLog(@"222222------- %@",_sortDic);
}
//这个只是一开始没有城市列表时测试用  所以 dataSourceArray 没有用。但是生成statusArray时有用到dataSourceArray.count，可以用25代替。
-(void)initDataSource{
    filterArray = [NSMutableArray array];    

    NSArray *hotArray = [NSArray arrayWithObjects:@"深圳",@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"长沙",@"拉萨",nil];
    NSArray *aArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"长沙",@"拉萨", nil];
    NSArray *bArray = [NSArray arrayWithObjects:@"北京", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *cArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"长沙",@"拉萨", nil];
    NSArray *dArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *eArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *fArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *gArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *hArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *iArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *jArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *kArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *lArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *mArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *nArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *oArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *pArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *qArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *rArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *sArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *tArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *uArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *vArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *wArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *xArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *yArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    NSArray *zArray = [NSArray arrayWithObjects:@"北京",@"上海", @"广州",@"深圳",@"天津",@"香港",@"澳门",@"杭州",@"重庆",@"成都",@"武汉",@"南京",@"西安",@"南昌",@"长沙",@"拉萨", nil];
    dataSourceArray = [NSMutableArray arrayWithObjects:hotArray,aArray,bArray,cArray,dArray,eArray,fArray,gArray,hArray,iArray,jArray,kArray,lArray,mArray,nArray,oArray,pArray,qArray,rArray,sArray,tArray,uArray,vArray,wArray,xArray,yArray,zArray, nil];
    titles = [NSMutableArray arrayWithObjects:@"定位",@"热", @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    statusArray = [NSMutableArray array];
    //保存状态(1表示展开，0表示闭合)
    for (int i = 0; i < dataSourceArray.count; i++)
    {
        [statusArray addObject:@"1"];
    }
    
}
-(void)initTableView{
//    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kTopHeight)];
//
//    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(60, 12, kScreenWidth - 80, 40)];
//    searchBar.delegate = self;
//    searchBar.placeholder  = @"城市名";
////     searchBar.backgroundColor = [UIColor clearColor];
//    searchBar.backgroundImage = [UIImage imageNamed:@"透明.jpg"];
//    [headView addSubview:searchBar];
//    //        self.navigationItem.titleView = searchBar;
//    [self.view addSubview:headView];
//
//    searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
//
    
    
    
    
    TopSwitchCsqView *switchView = [[TopSwitchCsqView alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, 49) :@[@"国内",@"国际、港澳台"] categryStr:@"4"];
    [self.view addSubview:switchView];
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,kTopHeight + 49, kScreenWidth, 1)];
    lineLabel.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineLabel];
    
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, kTopHeight + 50, self.view.frame.size.width , kScreenHeight -  (kTopHeight + 50))];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
    

//    UIButton *backBUt = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBUt.frame = CGRectMake(25, 25, 35, 35);
//    [backBUt setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
//    [backBUt addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBUt];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    if (tableView == myTableView) {
        // return dataSourceArray.count  ;
        return _sortkeys.count + 1;
    }else
        return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = dataSourceArray[section];
    if(tableView  == myTableView)
    {
        if (section ==0)
        {
            return 0;
        }
        else{
            NSArray *aZimu = [_sortDic objectForKey:_sortkeys[section - 1]];
            
            if ([statusArray[section] isEqualToString:@"1"])
            {
                return aZimu.count;
            }
            
            else
                
                return 0;
            
        }
    }
    else
        return filterArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (tableView == myTableView) {
        
        //    NSArray * array = dataSourceArray[indexPath.section];
        if (indexPath.section != 0) {
            NSArray *Titles = [_sortDic objectForKey:_sortkeys[indexPath.section-1]];
            
            cell.textLabel.text = Titles[indexPath.row];
        }
        //        if (indexPath.section == 0 && indexPath.row ==0  ) {
        ////            for (UIView *view in cell.subviews) {
        ////                [view removeFromSuperview];
        ////            }
        //
        //            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 20)];
        //            label.text = @"当前定位城市:";
        //            label.font = [UIFont systemFontOfSize:13];
        //            [cell.contentView addSubview:label];
        //            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //            button.frame = CGRectMake(label.right, 10, 40, 20);
        //            [button setTitle:array[indexPath.row] forState:UIControlStateNormal];
        //            [button setTitleColor: [UIColor blueColor] forState:UIControlStateNormal];
        //            [cell.contentView addSubview:button];
        //        }else
        
    }else{
        NSString *model = filterArray[indexPath.row];
        cell.textLabel.text = model;

    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == myTableView) {
        if (section == 0) {
            return 260;
        }else
            return 30;
    }
    else
        return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (tableView ==myTableView) {
        if (section == 0) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, myTableView.width, 70)];
            view.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.2];
            UILabel *cityLocatLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 20)];
            cityLocatLabel.text = @"定位/最近访问";
            cityLocatLabel.font = [UIFont systemFontOfSize:13];
            [view addSubview:cityLocatLabel];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:@"深圳" forState:UIControlStateNormal];
            button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            
            [button  addTarget:self action:@selector(selectCity:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.textAlignment = NSTextAlignmentLeft;
            [view addSubview:button];
            
            UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(0, 80, myTableView.frame.size.width, 30)];
            but.tag = section + 1;
            [but addTarget:self action:@selector(pickordispick:) forControlEvents:UIControlEventTouchUpInside];
//            but.backgroundColor = [UIColor lightGrayColor];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 250, 30)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:14];
            label.text = @"热门城市";
            [but addSubview:label];
            [view addSubview:but];
            
            UIView *butBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 110, kScreenWidth - 20, 135)];
            butBackView.backgroundColor = [UIColor clearColor];
            [view addSubview:butBackView];
            
            NSArray *hotCity = @[@"广州",@"东莞",@"惠州",@"佛山",@"长沙",@"武汉",@"上海",@"珠海",@"北京"];
            CGFloat whdthF = (butBackView.width - 40)/3;
            CGFloat heightF = 35;
            
            //上面的but
            button.frame  = CGRectMake(10, 40, whdthF, heightF);
            
            CGFloat hartF = 10;
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    UIButton *cityBut = [UIButton buttonWithType:UIButtonTypeCustom];
                    cityBut.backgroundColor = [UIColor whiteColor];
                    cityBut.frame = CGRectMake(j *whdthF + (j+1)*hartF, i *heightF + (i+1)*hartF, whdthF, heightF);
                    [cityBut setTitle:hotCity[i*3+j] forState:UIControlStateNormal];
                    [cityBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [cityBut setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
                    [cityBut  addTarget:self action:@selector(selectCity:) forControlEvents:UIControlEventTouchUpInside];
                    cityBut.titleLabel.font = [UIFont systemFontOfSize:13];
                    [butBackView addSubview:cityBut];
                }
            }
            
            return view;
        }
        else{
            UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, myTableView.frame.size.width, 30)];
            but.tag = section + 1;
            [but addTarget:self action:@selector(pickordispick:) forControlEvents:UIControlEventTouchUpInside];
            but.backgroundColor = [UIColor lightGrayColor];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 250, 30)];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont systemFontOfSize:14];
            
            label.text = _sortkeys[section-1];
            
            
            [but addSubview:label];
            return but;
        }
    }else
        return nil;
    
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    if (filterArray.count != 0) {
//        [filterArray removeAllObjects];
//    }
//
//
//    for (NSString *model in cityArray) {
//        if ([model rangeOfString:searchText].location != NSNotFound) {
//            [filterArray addObject:model];
//        }
//    }

    
}
#pragma searchbarDele
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // 创建出搜索使用的表示图控制器
    self.searchTVC = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _searchTVC.tableView.dataSource = self;
    _searchTVC.tableView.delegate = self;
//    _searchTVC.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 使用表示图控制器创建出搜索控制器
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:_searchTVC];
    _searchController.view.backgroundColor = Kcolor(239.0, 239.0, 244.0, 0.7);
    // 搜索框检测代理
    //（这个需要遵守的协议是 <UISearchResultsUpdating> ，这个协议中只有一个方法，当搜索框中的值发生变化的时候，代理方法就会被调用）
    _searchController.searchResultsUpdater = self;
    _searchController.delegate = self;
    
    _searchController.searchBar.placeholder = @"搜索";
    //  _searchController.searchBar.delegate = self;
    [self presentViewController:_searchController animated:YES completion:^{
        // 当模态推出这个searchController的时候,需要把之前的searchBar隐藏,如果希望搜索的时候看不到热门搜索什么的,可以把这个页面给隐藏
        [searchBar resignFirstResponder];
        [self.view  endEditing:YES];
    }];
}
#pragma mark - UISearchResultsUpdating Method
#pragma mark 监听者搜索框中的值的变化
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (filterArray.count != 0) {
        [filterArray removeAllObjects];
    }
    
    for (NSString *model in cityArray) {
        if ([model rangeOfString:searchController.searchBar.text].location != NSNotFound) {
            
            SDLog(@"nsnotfound");
            [filterArray addObject:model];
        }
    }
    [_searchTVC.tableView reloadData];
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    
    _searchController.delegate = nil;
}
-(void)didDismissSearchController:(UISearchController *)searchController{
    //    searchBar.hidden = NO;
    //    self.view.hidden = NO;
    _searchController.delegate = nil;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击搜索");
    [searchBar resignFirstResponder];
    [self.view  endEditing:YES];
}
-(void)pickordispick:(UIView *)view{
    NSLog(@"点击了表头");
    int viewTag = (int)view.tag;
    if ([statusArray[viewTag - 1]isEqualToString:@"1"]) {
        [statusArray replaceObjectAtIndex:viewTag - 1 withObject:@"0"];
    }
    else{
        [statusArray replaceObjectAtIndex:viewTag - 1 withObject:@"1"];
    }
    [myTableView reloadSections:[NSIndexSet indexSetWithIndex:viewTag - 1] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == myTableView) {
    return titles;
    }
    else{
        return nil;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == myTableView) {
        if (indexPath.section == 0) {
            return;
        }else
        {
            NSArray *Titles = [_sortDic objectForKey:_sortkeys[indexPath.section-1]];
            NSString * userName = Titles[indexPath.row];
            [self dismissViewControllerAnimated:YES completion:^{
                self.successBlock(userName);
            }];
        }
    }else{
        NSString *model = filterArray[indexPath.row];
        NSString * userName = model;
        self.successBlock(userName);
        [self dismissViewControllerAnimated:YES completion:^{
            [self backButton];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)selectCity:(id)sender{
    UIButton *but = (UIButton *)sender;
    NSString * userName = but.titleLabel.text;
    [self dismissViewControllerAnimated:YES completion:^{
        self.successBlock(userName);
    }];
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
