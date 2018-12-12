//
//  PayMoneyVC.m
//  FHZL
//
//  Created by hk on 2018/12/10.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "PayMoneyVC.h"
#import "PayStyleCell.h"
#import "PayStyleFootView.h"
@interface PayMoneyVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation PayMoneyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"支付页面";
    [self.myTableview registerNib:[UINib nibWithNibName:@"PayStyleCell" bundle:nil] forCellReuseIdentifier:@"PayStyleCell"];
    [self.myTableview registerNib:[UINib nibWithNibName:@"PayStyleFootView" bundle:nil] forCellReuseIdentifier:@"PayStyleFootView"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PayStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PayStyleCell"];
    if (indexPath.row == 0) {
        cell.typeLabel.text = @"微信支付";
    }else if (indexPath.row == 0) {
        cell.typeLabel.text = @"QQ钱包";
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 88;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [tableView dequeueReusableCellWithIdentifier:@"PayStyleFootView"];
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
