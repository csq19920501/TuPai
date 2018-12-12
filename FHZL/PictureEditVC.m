//
//  PictureEditVC.m
//  FHZL
//
//  Created by hk on 2018/1/31.
//  Copyright © 2018年 hk. All rights reserved.
//
#import "LPDQuoteImagesView.h"
#import "PictureEditVC.h"
#import "Header.h"
#import "Masonry.h"
#import "AddressAroundMeVC.h"
@interface PictureEditVC ()<LPDQuoteImagesViewDelegate,UITextViewDelegate>
{
    LPDQuoteImagesView *pictureView;
    AddressSingelModel *seleAddress;
}
@end

@implementation PictureEditVC
- (IBAction)locationClick:(id)sender {
    AddressAroundMeVC *VC = [[AddressAroundMeVC alloc]init];
    [VC setDidFinishPickingAddressHandle:^(AddressSingelModel *model){
        seleAddress = model;
//        [_locationButton setTitle:seleAddress.addressName forState:UIControlStateNormal];
        _locationLabel.text = seleAddress.addressName;
        _locationButtonWidth.constant = autoWidthFrame(_locationLabel.text, 21, 12).size.width + 50;
        
    }];
    if (seleAddress) {
        VC.seleModel = seleAddress;
    }
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
    [self presentViewController:nav animated:YES completion:^{}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavi];
    [self setViews];
    _contentLabel.delegate = self;
}
-(void)setNavi{
    self.view.backgroundColor = HBackColor;
    [self addNavigationItemWithTitles
     :@[@"分享"] isLeft:NO target:self action:@selector(showRight) tags:@[@1001]];
    self.title = @"编辑";
}
-(void)showRight{
    if (kStringIsEmpty(_biaoQianLabel.text)) {
        [UIUtil showToast:@"请输入标签" inView:self.view];
        return;
    }
    [UIUtil showProgressHUD:@"正在上传..." inView:self.view];
    NSDictionary *dic = @{@"userId":CsqStringIsEmpty(USERMANAGER.user.userID),
                          @"title":CsqStringIsEmpty(_biaoQianLabel.text),
                          @"x":[NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.longitude] ,
                          @"y":[NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.latitude],
                          @"note":CsqStringIsEmpty(_contentLabel.text),
                          @"address":CsqStringIsEmpty(_locationLabel.text)
                          };
    
    NSMutableArray *PhotoDataArray = [NSMutableArray array];
    if (!kArrayIsEmpty(pictureView.selectedPhotos)) {
        for (UIImage *image in pictureView.selectedPhotos) {
            NSData *data = UIImageJPEGRepresentation(image,1);
            [PhotoDataArray addObject:data];
        }
    }
    
    [ZZXDataService HFZLRequest:@"photo/upload" httpMethod:@"POST" params1:dic   file:@{@"files":PhotoDataArray,@"apiName":@"files"} success:^(id data)
     {
         
         if ([data[@"code"]integerValue] == 0) {
             [UIUtil showToast:@"上传成功" inView:self.view];
             CSQ_DISPATCH_AFTER(1.5, ^{
                 if (self.updatePictureSuccess) {
                     self.updatePictureSuccess();
                 }
                 [self.navigationController popViewControllerAnimated:YES];
             })
         }else{
             [UIUtil showToast:@"上传失败" inView:self.view];
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"网络异常" inView:self.view];
     }];
}
-(void)setViews{
    DISPATCH_ON_MAIN_THREAD((^{
        CGRect rect = _pictureBackView.bounds;
        pictureView = [[LPDQuoteImagesView alloc] initWithFrame:rect withCountPerRowInView:4 cellMargin:15];
        pictureView.navcDelegate = self;
        [pictureView getCameraWithImage:_photeImage];
        pictureView.maxSelectedCount = 9;
        [_pictureBackView addSubview:pictureView];
    }));
//    [_locationButton setTitle:USERMANAGER.mapDetial.addressStr forState:UIControlStateNormal];
    _locationLabel.text = USERMANAGER.mapDetial.addressStr;
    _locationButtonWidth.constant = autoWidthFrame(USERMANAGER.mapDetial.addressStr, 21, 12).size.width + 50;
    _timeLabel.text = [NSString stringWithFormat:@"时间:%@",[UserManager getDateStrFormNow]];
}
//修改定位按钮高度
-(void)changeConstant{
    int num = (int)pictureView.selectedPhotos.count/4 + 1;
    num = num <= 3?num:3;
    CGFloat heigthF = _pictureBackView.bounds.size.height/4 * num;//selectedPhotos
    _locationButtonConstant.constant = 20 + heigthF;
}
#pragma mark
- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"textView 开始编辑了");
    if ([textView.text isEqualToString:@"分享新鲜事..."]) {
        textView.text = @"";
    }
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
