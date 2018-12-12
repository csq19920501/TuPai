//
//  PictureEditVC.m
//  FHZL
//
//  Created by hk on 2018/1/31.
//  Copyright © 2018年 hk. All rights reserved.
//
#import "LPDQuoteImagesView.h"
#import "PictureEditVC_TwoFirst.h"
#import "Header.h"
#import "Masonry.h"
#import "AddressAroundMeVC.h"
#import "NewBiaoTiVC.h"
#import "MapPhoneModel.h"
#import "NSData+HexAdditions.h"

#define textViewText @"对事物进行描述"
@interface PictureEditVC_TwoFirst ()<LPDQuoteImagesViewDelegate,UITextViewDelegate,UITextFieldDelegate>
{
    LPDQuoteImagesView *pictureView;
    AddressSingelModel *seleAddress;
    UIButton * rightButton;
}
@property(nonatomic,strong)ShareView *shareView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoImageViewBottomConstant;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContrast;
@end

@implementation PictureEditVC_TwoFirst
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
    self.topContrast.constant = kTopHeight + 10;
    // Do any additional setup after loading the view from its nib.
    if (self.photoImage) {
        self.photoImageView.image = self.photoImage;
    }
   
    [self setNavi];
    [self setViews];
    _contentLabel.delegate = self;
}
-(void)setNavi{
    self.view.backgroundColor = HBackColor;

    
    if (self.pictureEditV_Type == PictureEditV_New) {
        self.title = @"预览";
    }else if(self.pictureEditV_Type == PictureEditV_Add){
        self.title = @"预览";
    }else if(self.pictureEditV_Type == PictureEditV_Edit){
        self.title = @"编辑";
        _contentLabel.text = self.contentStr;
    }

    
    rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightButton setTitle:@"发表" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightButton setTintColor:[UIColor clearColor]];
    [rightButton addTarget:self action:@selector(showRight) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (IS_OS_11_OR_LATER) {
        NSLayoutConstraint *widthConstraint =  [rightButton.widthAnchor constraintEqualToConstant:55];
        NSLayoutConstraint *heightConstraint =   [rightButton.heightAnchor constraintEqualToConstant:25];
        [widthConstraint setActive:YES];
        [heightConstraint setActive:YES];
    }else {
        rightButton.frame = CGRectMake(0, 0, 55, 25);
    }
    rightButton.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = 0;
    
    if (self.photoImage) {
        UIButton *shareBut = [UIButton buttonWithType:UIButtonTypeSystem];
        [shareBut setTitle:@"分享" forState:UIControlStateNormal];
        [shareBut setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [shareBut setTintColor:[UIColor clearColor]];
        shareBut.block = ^(UIButton *bu){
            [_shareView removeFromSuperview];
            _shareView = nil;
            NSData *imagedata = [NSData zipNSDataWithImage:self.photoImage];
            NSDictionary *dict = @{@"imageData":imagedata};
            _shareView = [ShareView getFactoryShareViewWithCsqDiction:dict];
            [_shareView showInView:self.view];
            [_shareView showWithContentType:JSHAREImage];
        };
        
        if (IS_OS_11_OR_LATER) {
            NSLayoutConstraint *widthConstraint =  [shareBut.widthAnchor constraintEqualToConstant:55];
            NSLayoutConstraint *heightConstraint =   [shareBut.heightAnchor constraintEqualToConstant:25];
            [widthConstraint setActive:YES];
            [heightConstraint setActive:YES];
        }else {
            shareBut.frame = CGRectMake(0, 0, 55, 25);
        }
        shareBut.backgroundColor = [UIColor whiteColor];
        UIBarButtonItem *item3 = [[UIBarButtonItem alloc]initWithCustomView:shareBut];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,item2,item3, nil];
    }else{
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,item2, nil];
    }
    
}
-(void)showRight{
    [self.view endEditing:YES];
    if ([AppData stringContainsEmoji:_contentLabel.text] || [AppData stringContainsEmoji:_biaoQianLabel.text] ) { //|| [AppData JudgeTheillegalCharacter:_contentStr] || [AppData JudgeTheillegalCharacter:_titleStr]
        [UIUtil showToast:@"请不要输入非法字符" inView:self.view];
        return;
    }
 
    rightButton.enabled = NO;
    NSString *contentLabelStr ;
    if ([_contentLabel.text isEqualToString:textViewText]) {
        contentLabelStr = @"";
    }else{
        contentLabelStr = _contentLabel.text;
    }
    
    if (self.pictureEditV_Type == PictureEditV_New) {
        if (kStringIsEmpty(_biaoQianLabel.text)) {
            [UIUtil showToast:@"请输入标题" inView:self.view];
            rightButton.enabled = YES;
            return;
        }
        [UIUtil showProgressHUD:[NSString stringWithFormat:@"正在上传，请稍候...%.0f%%",0] inView:self.view];
        NSDictionary *dic = @{
                              //                          @"userId":CsqStringIsEmpty(USERMANAGER.user.userID),
                              @"title":CsqStringIsEmpty(_biaoQianLabel.text),
                              @"x":[NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.longitude] ,
                              @"y":[NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.latitude],
                              @"desc":CsqStringIsEmpty(contentLabelStr),
                              @"address":CsqStringIsEmpty(_locationLabel.text)
                              };
        
        NSMutableArray *PhotoDataArray = [NSMutableArray array];
        //    if (!kArrayIsEmpty(pictureView.selectedPhotos)) {
        //        for (UIImage *image in pictureView.selectedPhotos) {
        //            NSData *data = UIImageJPEGRepresentation(image,1);
        //            [PhotoDataArray addObject:data];
        //        }
        //    }
        if(self.photoImage){
            NSData *data = UIImageJPEGRepresentation(self.photoImage,1);
            while (data.length > 1024 *1024) {
                data = [NSData zipNSDataWithImage:[UIImage imageWithData:data]];
            }
            [PhotoDataArray addObject:data];
        }else{
            [UIUtil showToast:@"请返回重新拍照" inView:self.view];
            rightButton.enabled = YES;
            return;
        }
        
        [ZZXDataService TuPaiURL:AppTuPaiUrl Request:@"photo/upload" httpMethod:@"POST" params1:dic   file:@{@"files":PhotoDataArray,@"apiName":@"files"}
          upProgress:^(NSProgress * _Nonnull upProgress){
              
              [UIUtil changeProgressHUDText:[NSString stringWithFormat:@"正在上传，请稍候...%.0f%%",upProgress.fractionCompleted*100]];
//              [UIUtil showProgressHUD:[NSString stringWithFormat:@"正在上传，请稍候...%.0f%%",upProgress.fractionCompleted*100] inView:self.view];
          }
                         success:^(id data)
         {

             
             if ([data[@"code"]integerValue] == 0) {
                 [UIUtil showToast:@"上传成功" inView:self.view];
//                 rightButton.enabled = YES;
                 
//                 SDLog(@"data dict= %@",data[@"data"]);
//                 NSString* why = data[@"data"];
//                 SDLog(@"data dict groupId class= %@",NSStringFromClass([why class]));
//                 NSData *JSONData = [why dataUsingEncoding:NSUTF8StringEncoding];
//                 NSDictionary *groupIdJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
//                 SDLog(@"groupIdJSON= %@",groupIdJSON);
//                 SDLog(@"data dict groupId= %@",groupIdJSON[@"groupId"]);

                
                 
                 
                 CSQ_DISPATCH_AFTER(1.5, (^{
                     if (self.updatePictureSuccess) {
                         self.updatePictureSuccess();
                     }
                     
                     NewBiaoTiVC *VC = [[NewBiaoTiVC alloc]init];
                     MapPhoneModel *model = [[MapPhoneModel alloc]init];
                     model.ID = data[@"data"][@"groupId"];
                     model.title = _biaoQianLabel.text;
                     model.x = [NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.longitude];
                     model.y = [NSString stringWithFormat:@"%f",USERMANAGER.mapDetial.userCoordinate.latitude];
                     model.address = _locationLabel.text;
                     NSDate* dat = [NSDate date];
                     NSTimeInterval a= [dat timeIntervalSince1970];
                     model.groupDate = [NSString stringWithFormat:@"%f",a * 1000];
                     model.userID = USERMANAGER.user.userID;
                     model.headPicPath = USERMANAGER.user.headPicPath;
                     model.icconid = USERMANAGER.user.iconId;
                     model.nickName = USERMANAGER.user.nickname;
                     model.note = _contentLabel.text;
                     VC.mapPhoneModel = model;
                     VC.enumType = AddType;
                     [self.navigationController pushViewController:VC animated:YES];
                     //[self.navigationController popViewControllerAnimated:YES];
                 }))
             }else{
                 [UIUtil showToast:@"上传失败" inView:self.view];
                 rightButton.enabled = YES;
             }
         } fail:^(NSError *error)
         {
             [UIUtil showToast:@"网络异常" inView:self.view];
             rightButton.enabled = YES;
         }];
    }else if(self.pictureEditV_Type == PictureEditV_Add){
        [UIUtil showProgressHUD:[NSString stringWithFormat:@"正在上传，请稍候...%.0f%%",0] inView:self.view];
        
        NSDictionary *dic = @{
                              @"desc":CsqStringIsEmpty(contentLabelStr),
                              @"groupId":CsqStringIsEmpty(self.groupId)
                              };
        NSMutableArray *PhotoDataArray = [NSMutableArray array];
        if(self.photoImage){
            NSData *data = UIImageJPEGRepresentation(self.photoImage,1);
            while (data.length > 1024 *1024) {
                data = [NSData zipNSDataWithImage:[UIImage imageWithData:data]];
            }
            [PhotoDataArray addObject:data];
        }else{
            [UIUtil showToast:@"请返回重新拍照" inView:self.view];
            rightButton.enabled = YES;
            return;
        }

         [ZZXDataService TuPaiURL:AppTuPaiUrl Request:@"photo/upload" httpMethod:@"POST" params1:dic   file:@{@"files":PhotoDataArray,@"apiName":@"files"}
                         upProgress:^(NSProgress * _Nonnull upProgress){
                             [UIUtil changeProgressHUDText:[NSString stringWithFormat:@"正在上传，请稍候...%.0f%%",upProgress.fractionCompleted*100]];
                         }
                            success:^(id data)
         {
             
             if ([data[@"code"]integerValue] == 0) {
                 [UIUtil showToast:@"发表成功" inView:self.view];

                 CSQ_DISPATCH_AFTER(1.5, ^{
                     if (self.updatePictureSuccess) {
                         self.updatePictureSuccess();
                     }
//                     NewBiaoTiVC *VC = [[NewBiaoTiVC alloc]init];
//                     VC.enumType = AddType;
//                     [self.navigationController pushViewController:VC animated:YES];
                     [self.navigationController popViewControllerAnimated:YES];
                 })
             }else{
                 [UIUtil showToast:@"发表失败" inView:self.view];
                 rightButton.enabled = YES;
             }
         } fail:^(NSError *error)
         {
             [UIUtil showToast:@"网络异常" inView:self.view];
             rightButton.enabled = YES;
         }];
    }else if(self.pictureEditV_Type == PictureEditV_Edit){
        [UIUtil showProgressHUD:@"正在编辑..." inView:self.view];
        NSDictionary *dic = @{
                              @"desc":CsqStringIsEmpty(contentLabelStr),
                              @"id":self.itemId
                              };

        [ZZXDataService HFZLRequest:@"photo/edit-photo" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
         {
             
             if ([data[@"code"]integerValue] == 0) {
                 [UIUtil showToast:@"编辑成功" inView:self.view];
//                 rightButton.enabled = YES;
                 CSQ_DISPATCH_AFTER(1.5, ^{
                     if (self.updatePictureSuccess) {
                         self.updatePictureSuccess();
                     }
                     for (UIViewController *controller in self.navigationController.viewControllers) {
                         if ([controller isKindOfClass:[NewBiaoTiVC class]]) {
                             NewBiaoTiVC *A =(NewBiaoTiVC *)controller;
                             [self.navigationController popToViewController:A animated:YES];
                         }
                     }

                 })
             }else{
                 [UIUtil showToast:@"编辑失败" inView:self.view];
                 rightButton.enabled = YES;
             }
         } fail:^(NSError *error)
         {
             [UIUtil showToast:@"网络异常" inView:self.view];
             rightButton.enabled = YES;
         }];
    }
}
-(void)setViews{
//    DISPATCH_ON_MAIN_THREAD((^{
//        CGRect rect = _pictureBackView.bounds;
//        pictureView = [[LPDQuoteImagesView alloc] initWithFrame:rect withCountPerRowInView:4 cellMargin:15];
//        pictureView.navcDelegate = self;
//        [pictureView getCameraWithImage:_photeImage];
//        pictureView.maxSelectedCount = 9;
//        [_pictureBackView addSubview:pictureView];
//    }));
//    [_locationButton setTitle:USERMANAGER.mapDetial.addressStr forState:UIControlStateNormal];
    _locationLabel.text = USERMANAGER.mapDetial.addressStr;
    _locationButtonWidth.constant = autoWidthFrame(USERMANAGER.mapDetial.addressStr, 21, 12).size.width + 50;
    _timeLabel.text = [NSString stringWithFormat:@"时间:%@",[UserManager getDateStrFormNow]];
    
    
    [_biaoQianLabel addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    
    
    if (self.pictureEditV_Type == PictureEditV_Add || self.pictureEditV_Type == PictureEditV_Edit) {
        for (int i = 100; i <= 105; i++) {
            UIView* view = [self.view viewWithTag:i];
            view.hidden = YES;
            _biaoQianLabel.hidden = YES;
        }
//        DISPATCH_ON_MAIN_THREAD(^{
        self.titleTopConstant.constant = -40;
        self.biaoQianLabel.text = self.titleStr;
        self.biaoQianLabel.enabled = NO;
//        })
        if (isIphone4) {
            self.photoImageViewBottomConstant.constant = -70;
//            [self.photoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.bottom.mas_equalTo(self.lineLabel).offset(-30);
//            }];
        }
    }
    
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
    if ([textView.text isEqualToString:textViewText]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (kStringIsEmpty(textView.text )) {
        textView.text = textViewText;
        textView.textColor = [UIColor darkGrayColor];
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 500) {
        showLimit(500)
        [self.view endEditing:YES];
        textView.text = [textView.text substringToIndex:500];
    }
}
//-(void)textFieldDidEndEditing:(UITextField *)textField{
//    if (textField.text.length >= 32) {
//        showLimit(32)
//        [self.view endEditing:YES];
//        textField.text = [textField.text substringToIndex:31];
//    }
//}
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if (text.length > 0 && textView.text.length >= 10)
//    {
//        showLimit(10)
//        [self.view endEditing:YES];
//        return NO;
//    }
//    return YES;
//}
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (string.length > 0 && textField.text.length >= 32)
//    {
//        showLimit(32)
//        textField.text = [textField.text substringToIndex:31];
//        [self.view endEditing:YES];
//        return NO;
//    }
//    return YES;
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)textFieldDidChange:(UITextView *)textField
{
    CGFloat kMaxLength = 32;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
                [UIUtil showToast:@"长度不能超过32位" inView:self.view];
                //                [nameTF resignFirstResponder];
                double delayInSeconds = 0.5f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                               {
                                   textField.text = [toBeString substringToIndex:kMaxLength];
                               });
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{

        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];

            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{

        }
    }
}



@end
