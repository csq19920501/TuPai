//
//  WithdrawalEndVC.m
//  FHZL
//
//  Created by hk on 2018/12/12.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "WithdrawalEndVC.h"
#import "BillingVC.h"
@interface WithdrawalEndVC ()

@end

@implementation WithdrawalEndVC
- (IBAction)endClick:(id)sender {
}
- (IBAction)checkbillClick:(id)sender {
    BillingVC *VC = [BillingVC new];
    [self.navigationController   pushViewController:VC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"结果详情";
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
