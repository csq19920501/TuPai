//
//  TupaiCollectionVC.m
//  FHZL
//
//  Created by hk on 2018/12/11.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "TupaiCollectionVC.h"
#import "Header.h"
#import "TupaiCollectionCell.h"
@interface TupaiCollectionVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic ,strong)UITableView * myTableview;
@end

@implementation TupaiCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"宝贝收藏";
//    self.myTableview.backgroundColor = [UIColor whiteColor];
    self.myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.myTableview registerNib:[UINib nibWithNibName:@"TupaiCollectionCell" bundle:nil] forCellReuseIdentifier:@"TupaiCollectionCell"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  143;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TupaiCollectionCell";
    TupaiCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier ];
    return cell;
}
-(UITableView *)myTableview{
    if (!_myTableview) {
        _myTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight - kTopHeight) style:UITableViewStylePlain];
        _myTableview.delegate = self;
        _myTableview.dataSource = self;
        [self.view addSubview:_myTableview];
    }
    return  _myTableview;
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
