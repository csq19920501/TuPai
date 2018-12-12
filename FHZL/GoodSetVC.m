//
//  GoodSetVC.m
//  FHZL
//
//  Created by hk on 2018/11/26.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "GoodSetVC.h"

@interface GoodSetVC ()

@end

@implementation GoodSetVC
- (IBAction)confirmCLick:(id)sender {
    if (self.setModelBlock) {
        self.mapModel.goodPrise = self.priceTF.text;
        self.mapModel.goodParameter = self.numTF.text;
        self.setModelBlock(self.mapModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商品定价";
    // Do any additional setup after loading the view from its nib.
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
