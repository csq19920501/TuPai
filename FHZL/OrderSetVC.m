//
//  OrderSetVC.m
//  FHZL
//
//  Created by hk on 2018/11/27.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "OrderSetVC.h"
#import "PayMoneyVC.h"
@interface OrderSetVC ()

@end

@implementation OrderSetVC
- (IBAction)payNow:(id)sender {
    PayMoneyVC *VC = [PayMoneyVC new];
    [self.navigationController   pushViewController:VC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"确认订单";
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
