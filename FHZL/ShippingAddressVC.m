//
//  ShippingAddressVC.m
//  FHZL
//
//  Created by hk on 2018/12/12.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "ShippingAddressVC.h"
#import "Header.h"
#import "ShippingAddressCell.h"
#import "AddAddressVC.h"
@interface ShippingAddressVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableview;
@end

@implementation ShippingAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"收货地址";
    self.myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.myTableview registerNib:[UINib nibWithNibName:@"ShippingAddressCell" bundle:nil] forCellReuseIdentifier:@"ShippingAddressCell"];
    [self addNavigationItemWithTitles
     :@[@"添加收货地址"] isLeft:NO target:self action:@selector(showRight) tags:@[@1001]];
}
-(void)showRight{
    AddAddressVC *VC = [[AddAddressVC alloc]init];
    VC.addressTypeC = AddressType_add;
    [self.navigationController   pushViewController:VC animated:YES];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ShippingAddressCell";
    ShippingAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //    if (!cell) {
    //        cell = [[ShopCarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    //    }
    cell.editClick = ^{
        AddAddressVC *VC = [[AddAddressVC alloc]init];
        [self.navigationController   pushViewController:VC animated:YES];
    };
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84;
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
