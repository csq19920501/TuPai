//
//  CheckLogisticsVC.m
//  FHZL
//
//  Created by hk on 2018/12/11.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "CheckLogisticsVC.h"

@interface CheckLogisticsVC ()

@end

@implementation CheckLogisticsVC
- (IBAction)backClick:(id)sender {
    self.navigationController.navigationBar.hidden = NO;
    [super showLeft];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = YES;
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
