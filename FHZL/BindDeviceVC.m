//
//  BindDeviceVC.m
//  FHZL
//
//  Created by hk on 2018/1/19.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "BindDeviceVC.h"
#import "Header.h"
//扫描
#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"
#import "ScanViewController.h"
@interface BindDeviceVC ()<ScanDele>
@property (weak, nonatomic) IBOutlet UITextField *IMEI_tf;

@end

@implementation BindDeviceVC
- (IBAction)BindClick:(id)sender {
    ScanViewController *scanVC = [[ScanViewController alloc] init];
    scanVC.delegate = self;
    [self.navigationController pushViewController:scanVC animated:NO];
}
-(void)changeCode:(NSString *)code{
    _IMEI_tf.text = code;
}
- (IBAction)confirmClick:(id)sender {
    if (!kStringIsEmpty(_IMEI_tf.text)) {
        [self bindNewDevice];
    }else{
        [UIUtil showToast:@"输入不能为空" inView:self.view];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设备绑定";
}


-(void)bindNewDevice{
    NSDictionary *dic = @{@"userId":CsqStringIsEmpty(USERMANAGER.user.userID),
                          @"macId":CsqStringIsEmpty(_IMEI_tf.text)
                          };
    [ZZXDataService HFZLRequest:@"user/dev-bind" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         
         if ([data[@"code"]integerValue] == 0) {
             [UIUtil showToast:@"绑定成功" inView:self.view];
             CSQ_DISPATCH_AFTER(1.5, ^{
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"UnBindSuccess" object:nil];
                 [self showLeft];
             })
             
             
         }else{
             switch ([data[@"code"]integerValue]) {
                 case 102011:
                     {
                         [UIUtil showToast:@"设备未找到" inView:self.view];
                     }
                     break;
                 case 101031:
                 {
                     [UIUtil showToast:@"设备已被绑定" inView:self.view];
                 }
                     break;
                 default:
                     break;
             }
             
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"网络异常" inView:self.view];
     }];
}


-(void)showLeft{
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
   
        if (string.length > 0 && _IMEI_tf.text.length > 14)
        {
            [UIUtil showToast:L(@"IMEI cannot exceed 14") inView:self.view];
            return NO;
        }
    
    return YES;
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
