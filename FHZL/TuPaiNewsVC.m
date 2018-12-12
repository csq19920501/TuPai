//
//  TuPaiNewsVC.m
//  FHZL
//
//  Created by hk on 2018/12/12.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "TuPaiNewsVC.h"
#import "TupaiNewCell.h"
#import "Header.h"
#import "TupaiChatVC.h"
@interface TuPaiNewsVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *myTableview;
@end

@implementation TuPaiNewsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消息";
    [self addNavigationItemWithImageNames:@[@"back_icon"] isLeft:YES target:self action:@selector(showLeft) tags:nil];
    self.myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.myTableview registerNib:[UINib nibWithNibName:@"TupaiNewCell" bundle:nil] forCellReuseIdentifier:@"TupaiNewCell"];
}
-(void)showLeft{
    [APPDELEGATE.homeNavi popToRootViewControllerAnimated:YES];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TupaiNewCell";
    TupaiNewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //    if (!cell) {
    //        cell = [[ShopCarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    //    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TupaiChatVC  *VC = [TupaiChatVC new];
    [self.navigationController pushViewController:VC animated:YES];
}
-(UITableView *)myTableview{
    if (!_myTableview) {
        _myTableview = [[UITableView  alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight - kTopHeight) style:UITableViewStylePlain];
        _myTableview.delegate = self;
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
