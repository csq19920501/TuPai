//
//  Withdrawal.m
//  FHZL
//
//  Created by hk on 2018/12/12.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "Withdrawal.h"
#import "WithdrawalEndVC.h"
@interface Withdrawal ()

@end

@implementation Withdrawal
- (IBAction)confirmCLick:(id)sender {
    WithdrawalEndVC *VC = [WithdrawalEndVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"提现";
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
