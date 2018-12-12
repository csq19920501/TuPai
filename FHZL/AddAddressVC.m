//
//  AddAddressVC.m
//  FHZL
//
//  Created by hk on 2018/12/11.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "AddAddressVC.h"
#import "FHZL-Swift.h"
@interface AddAddressVC ()<UITextFieldDelegate>

@end

@implementation AddAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.addressTypeC == AddressType_add) {
        self.title = @"添加收货地址";
        self.deleBackVIew.hidden = YES;
    }else{
        self.title = @"编辑收货地址";
    }
    
    [self addNavigationItemWithTitles
     :@[@"保存"] isLeft:NO target:self action:@selector(showRight) tags:@[@1001]];
}
-(void)showRight{}
#pragma mark uitextfile

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.view  endEditing:YES];
    [textField resignFirstResponder];
    EWAddressViewController *searchVC = [[EWAddressViewController alloc]init];
    searchVC.backLocationStringController = ^(NSString* address,NSString* province,NSString* city,NSString* area){
        textField.text = [NSString stringWithFormat:@"%@",address];
    };
    

    [self presentViewController:searchVC animated:YES completion:nil];
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
