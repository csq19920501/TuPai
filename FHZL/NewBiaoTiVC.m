//
//  NewBiaoTiVC.m
//  FHZL
//
//  Created by hk on 2018/8/29.
//  Copyright © 2018年 hk. All rights reserved.
//
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "MJRefresh.h"
#import "NewBiaoTiVC.h"
#import "Header.h"
#import "LookPeople.h"
#import "KDXFvoiceManager.h"
#import "NewBiaoTiCell.h"
#import "NewBiaoTiModel.h"
#import "PictureEditVC2.h"
#import "PictureEditVC_TwoFirst.h"
#import "CSQPhotoPreviewController.h"
#import "PreviewVC.h"
#import "CustomeCsqButton.h"
#import "GoodSetVC.h"
#import "OrderSetVC.h"
#import "ShopCarVC.h"
#import "TupaiChatVC.h"

@interface NewBiaoTiVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITextField* nameTF;
    CSQNewBiaoTiHeadView *headerViwe;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstant;
@property (weak, nonatomic) IBOutlet UITableView *myTableview;
@property (weak, nonatomic) IBOutlet UIView *bottomButBackView;
@property (weak, nonatomic) IBOutlet UIButton *yellowBut;

@end

@implementation NewBiaoTiVC
- (IBAction)buyNow:(id)sender {
     if (![self.mapPhoneModel.userID isEqualToString: USERMANAGER.user.userID]) {
    OrderSetVC *VC = [OrderSetVC new];
    [self.navigationController pushViewController:VC animated:YES];
     }
}
- (IBAction)addShopCar:(id)sender {
    ShopCarVC *VC = [ShopCarVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)camreaClcil:(id)sender {
    [self getCamera];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataArray = [NSMutableArray array];
    self.topConstant.constant = kTopHeight;
    if (isIphoneX) {
        self.bottomConstant.constant = 34;
    }
    if (self.enumType == Look || self.enumType == Edit) {
//        self.tableBottomConstant.constant = 0;
    }

    MPWeakSelf(self)
    headerViwe = [[CSQNewBiaoTiHeadView alloc]init];
    headerViwe.frame = CGRectMake(0, 0, kScreenWidth, 150);
    headerViwe.biaoTiLabel.text = self.mapPhoneModel.title;
    headerViwe.addressLabel.text = self.mapPhoneModel.address;
    headerViwe.priseLabel.text = kStringIsEmpty(self.mapPhoneModel.goodPrise)?@"￥123":self.mapPhoneModel.goodPrise;
    headerViwe.parameterLabel.text = kStringIsEmpty(self.mapPhoneModel.goodParameter)?@"5斤":self.mapPhoneModel.goodParameter;
    
    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([self.mapPhoneModel.y floatValue], [self.mapPhoneModel.x floatValue]));
    BMKMapPoint point2 = BMKMapPointForCoordinate(USERMANAGER.mapDetial.userCoordinate);
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    headerViwe.distanceLabel.text = [NSString stringWithFormat:@"距离%.0f米",distance];
    
    
    [headerViwe setNavClick:^{
        showNewAlert(@"是否导航到该位置", nil, nil, ^(UIAlertAction*act){
            NSLog(@"导航到目的地");
            TIPmodel *modelTIP = [[TIPmodel alloc]init];
            modelTIP.latitude = [weakself.mapPhoneModel.y floatValue];
            modelTIP.longitude = [weakself.mapPhoneModel.x floatValue];
            modelTIP.addressString =  weakself.mapPhoneModel.address;
            [[KDXFvoiceManager shareInstance]sendNai:modelTIP];
        })
    }];
    
    [headerViwe setShareClick:^{
        if (!kArrayIsEmpty(_dataArray)) {
            [weakself UMshare:weakself.mapPhoneModel ImageSingelModel:_dataArray[0]];
        }else{
            [self UMshare:self.mapPhoneModel ImageSingelModel:nil];
        }
    }];
    if (![self.mapPhoneModel.userID isEqualToString: USERMANAGER.user.userID]) {
        headerViwe.editButton.hidden = YES;
        
        CustomeCsqButton* customerServiceButton = [[CustomeCsqButton alloc]initWithFrame:CGRectMake(0, 0, self.bottomButBackView.width/2, self.bottomButBackView.height) normalImageStr:ModifiImage seleImageStr:@"标题栏_返回_P.png" titleStr:@"客服" numberStr:nil];
        MPWeakSelf(customerServiceButton);
         customerServiceButton.ClickActionBlock = ^(NSInteger buttonTag) {
            weakcustomerServiceButton.selected = !weakcustomerServiceButton.selected;
             
             TupaiChatVC *VC = [TupaiChatVC new];
             [self.navigationController pushViewController:VC animated:YES];
        };
        [self.bottomButBackView addSubview:customerServiceButton];
        
        CustomeCsqButton* collectionButton = [[CustomeCsqButton alloc]initWithFrame:CGRectMake(self.bottomButBackView.width/2, 0, self.bottomButBackView.width/2, self.bottomButBackView.height) normalImageStr:ModifiImage seleImageStr:@"标题栏_返回_P.png" titleStr:@"收藏" numberStr:nil];
        MPWeakSelf(collectionButton);
        collectionButton.ClickActionBlock = ^(NSInteger buttonTag) {
            weakcollectionButton.selected = !weakcollectionButton.selected;
        };
        [self.bottomButBackView addSubview:collectionButton];
        
//        CustomeCsqButton* shoppingCartButton = [[CustomeCsqButton alloc]initWithFrame:CGRectMake(self.bottomButBackView.width/3*2, 0, self.bottomButBackView.width/3, self.bottomButBackView.height) normalImageStr:ModifiImage seleImageStr:@"标题栏_返回_P.png" titleStr:@"购物车" numberStr:nil];
//        MPWeakSelf(shoppingCartButton);
//        shoppingCartButton.ClickActionBlock = ^(NSInteger buttonTag) {
//            weakshoppingCartButton.selected = !weakshoppingCartButton.selected;
//        };
//        [self.bottomButBackView addSubview:shoppingCartButton];
        
//        DISPATCH_ON_MAIN_THREAD(^{
//
//
//
//        })
    }else{
        [self.yellowBut setTitle:@"商品定价" forState:UIControlStateNormal];
        self.yellowBut.block = ^(UIButton *sender) {
            if ([self.mapPhoneModel.userID isEqualToString: USERMANAGER.user.userID]) {
                GoodSetVC * VC = [GoodSetVC new];
                VC.mapModel = self.mapPhoneModel;
                MPWeakSelf(self)
                [VC setSetModelBlock:^(MapPhoneModel*mapModel){
                    weakself.mapPhoneModel = mapModel;
                    headerViwe.priseLabel.text = weakself.mapPhoneModel.goodPrise;
                    headerViwe.parameterLabel.text = weakself.mapPhoneModel.goodParameter;
                }];
                [self.navigationController pushViewController:VC animated:YES];
            }
        };
        self.bottomButBackView.hidden = YES;
        self.addShopBut.hidden  = YES;
    }
    [headerViwe setEditBlock:^{
        UIAlertView* nameAlertView  = [[UIAlertView alloc] initWithTitle:nil message:@"请输入标题" delegate:weakself cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        nameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        nameTF = [nameAlertView textFieldAtIndex:0];
        nameTF.text = headerViwe.biaoTiLabel.text;

        nameAlertView.tag = 52;
        nameTF.delegate = weakself;
        nameAlertView.delegate = self;
        [nameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [nameAlertView show];
    }];
    _myTableview.tableHeaderView = headerViwe;
    _myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableview.delegate = self;
    _myTableview.dataSource = self;
    [_myTableview registerNib:[UINib nibWithNibName:@"NewBiaoTiCell" bundle:nil] forCellReuseIdentifier:@"NewBiaoTiCell"];
    
    //头部刷新 addAlarmListRefresh
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getAlarmListRefresh)];
    header.automaticallyChangeAlpha = YES;
    header.lastUpdatedTimeLabel.hidden = YES;
    _myTableview.mj_header = header;
    [self setNavi];
}
-(void)viewWillAppear:(BOOL)animated{
    [_myTableview.mj_header beginRefreshing];
}
-(void)getAlarmListRefresh{
    [_dataArray removeAllObjects];
    NSDictionary *dic = @{@"groupId":CsqStringIsEmpty(self.mapPhoneModel.ID)};
    [ZZXDataService HFZLRequest:@"photo/show-photo" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             NSArray *imageArr = data[@"data"];
             if (!kArrayIsEmpty(imageArr)) {
                 for (NSDictionary *imageDict in imageArr) {
                     ImageSingelModel *model1 = [ImageSingelModel provinceWithDictionary:imageDict];
                     [_dataArray addObject:model1];
                 }
                 [_myTableview.mj_header endRefreshing];
                 [_myTableview reloadData];
             }else{
                 [UIUtil showToast:@"未有图片" inView:self.view];
                 [_myTableview.mj_header endRefreshing];
                 [_myTableview reloadData];
             }
         }else{
             [UIUtil showToast:@"加载失败" inView:self.view];
             [_myTableview.mj_header endRefreshing];
             [_myTableview reloadData];
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"网络异常" inView:self.view];
         [_myTableview.mj_header endRefreshing];
         [_myTableview reloadData];
     }];
}
-(void)setNavi{
    self.title = @"照片预览";
//    [self addNavigationItemWithImageNames
//     :@[@"列表_7.png"] isLeft:NO target:self action:@selector(showDropDownMenu) tags:@[@1001]];
//    [self addNavigationItemWithTitles:@[@"发表"] isLeft:NO target:self action:@selector(showRight) tags:@[@1000]];
    
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightButton setTitle:@"商业活动" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightButton setTintColor:[UIColor clearColor]];
    [rightButton addTarget:self action:@selector(showRight) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (IS_OS_11_OR_LATER) {
        NSLayoutConstraint *widthConstraint =  [rightButton.widthAnchor constraintEqualToConstant:70];
        NSLayoutConstraint *heightConstraint =   [rightButton.heightAnchor constraintEqualToConstant:25];
        [widthConstraint setActive:YES];
        [heightConstraint setActive:YES];
    }else {
        rightButton.frame = CGRectMake(0, 0, 70, 25);
    }
    rightButton.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = 0;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,item2, nil];
}
-(void)showRight{
    
}
-(void)showLeft{
        [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark 拍摄完成后要执行的方法
//Changed by boris on 2016.10.25
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSData *finalData = nil;
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"拍摄%@",image);
        UIImageWriteToSavedPhotosAlbum(image,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
        
        //得到图片
        //        [_headImage setBackgroundImage:info[@"UIImagePickerControllerEditedImage"] forState:UIControlStateNormal];
        //        finalData = UIImageJPEGRepresentation(info[@"UIImagePickerControllerEditedImage"], 0.5);
        
        PictureEditVC_TwoFirst  *pictVC = [[PictureEditVC_TwoFirst alloc]init];
        pictVC.photoImage = image;
        pictVC.titleStr = self.mapPhoneModel.title;
        pictVC.pictureEditV_Type = PictureEditV_Add;
        pictVC.groupId = self.mapPhoneModel.ID;
        [pictVC setUpdatePictureSuccess:^{
            NSLog(@"上传图片成功返回图拍主页面刷新图片");
//            _searchBar.text = nil;
//            [self getPhotoArray];
        }];
        [self.navigationController pushViewController:pictVC animated:YES];
        
        [self dismissViewControllerAnimated:YES completion:^{
            ////            [UIUtil showProgressHUD:nil inView:self.view];
            //
        }];
        
    } else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSLog(@"拍摄%@", info[@"UIImagePickerControllerEditedImage"]);
        //        [_headImage setBackgroundImage:info[@"UIImagePickerControllerEditedImage"] forState:UIControlStateNormal];
        //        finalData = UIImageJPEGRepresentation(info[@"UIImagePickerControllerEditedImage"], 0.5);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //Upload head image
    if (finalData) {
        //        NSDictionary *dict = @{@"nickname":self.cdm.userInfoEntity.nickName,@"access_token":self.cdm.userInfoEntity.accessToken};
        //        [self uploadHeadImage:finalData withParams:dict];
    }
    //退出相册
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    SDLog(@"_dataArray.count = %d",_dataArray.count);
    return _dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 104;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageSingelModel *model = _dataArray[indexPath.row];

    static NSString *identifier = @"NewBiaoTiCell";
    NewBiaoTiCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (!cell) {
//        //        cell = [[imageViewPreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewBiaoTiCell" owner:nil options:nil];
//        cell = [views objectAtIndex:0];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (![self.mapPhoneModel.userID isEqualToString: USERMANAGER.user.userID]) {
        cell.editButton.hidden = YES;
        cell.deleButton.hidden = YES;
    }
    MPWeakSelf(self)
    MPWeakSelf(cell)
    [cell setModel:model ImageBlock:^{
        NSMutableArray *imageUrlArr = [NSMutableArray array];
        for (ImageSingelModel *model in _dataArray) {
            [imageUrlArr addObject:model.path];
        }
        CSQPhotoPreviewController *previewVC = [[CSQPhotoPreviewController alloc]init];
        previewVC.photos = imageUrlArr;
        previewVC.currentIndex = indexPath.row;
        [previewVC setDidDismiss:^{
        }];
        [weakself.navigationController pushViewController:previewVC animated:YES];
    }editBlock:^{
        PictureEditVC_TwoFirst  *pictVC = [[PictureEditVC_TwoFirst alloc]init];
        pictVC.photoImage = weakcell.pictureView.image;
        pictVC.itemId = model.ID;
        pictVC.pictureEditV_Type = PictureEditV_Edit;
        pictVC.titleStr = weakself.mapPhoneModel.title;
        pictVC.contentStr = model.desc;
        [pictVC setUpdatePictureSuccess:^{
        }];
        [self.navigationController pushViewController:pictVC animated:YES];
    } deleBlock:^{
        if (_dataArray.count == 1) {
            showNewAlert(@"是否删除该标题", nil, nil, ^(UIAlertAction*action){
                [self dele:model];
            })
        }else if (_dataArray.count > 1){
            showNewAlert(@"是否删除", nil, nil, ^(UIAlertAction*action){
                [self dele:model];
            })
        }
    }];
    return cell;
}
-(void)dele:(ImageSingelModel*)model{
    [UIUtil showProgressHUD:@"正在删除" inView:self.view];
    NSDictionary *dic = @{@"id":CsqStringIsEmpty(model.ID)};
    [ZZXDataService HFZLRequest:@"photo/delete-single" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             [UIUtil showToast:@"删除成功" inView:self.view];
             CSQ_DISPATCH_AFTER(1.5, ^{
                 
                 if (_dataArray.count == 1) {
                     [self.navigationController popToRootViewControllerAnimated:YES];
                 }else if (_dataArray.count > 1){
                     [_myTableview.mj_header beginRefreshing];
                 }
             })
         }else{
             [UIUtil showToast:@"删除失败" inView:self.view];
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"删除异常" inView:self.view];
     }];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageSingelModel *model = _dataArray[indexPath.row];
    
    PreviewVC *preVC = [[PreviewVC alloc]init];
    if (_dataArray.count == 1) {
        preVC.isOnlyOne = YES;
    }
    [preVC.photoArray addObject:model];
    self.mapPhoneModel.note = model.desc;
    preVC.detailModel = self.mapPhoneModel;
    [preVC setDeleSuccess:^{
//        NSLog(@"删除成功返回图拍主页面刷新图片");
//        weakself.searchBar.text = nil;
//        [weakself getPhotoArray];
    }];
    [self.navigationController pushViewController:preVC animated:YES];
}
-(NSMutableArray*)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)textFieldDidChange:(UITextField *)textField
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
                showLimit(32)
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex == 1) {
            if (kStringIsEmpty(nameTF.text)) {
                [UIUtil showToast:L(@"标题不能为空") inView:self.view];
            }else{
                [UIUtil showProgressHUD:@"请稍候..." inView:self.view];
                NSDictionary *dic = @{@"id":CsqStringIsEmpty(self.mapPhoneModel.ID),
                                      @"title":CsqStringIsEmpty(nameTF.text)
                                      };
                [ZZXDataService HFZLRequest:@"photo/edit-group" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
                 {
                     if ([data[@"code"]integerValue] == 0) {
                         [UIUtil showToast:@"修改成功" inView:self.view];
                         headerViwe.biaoTiLabel.text = nameTF.text;
                         self.mapPhoneModel.title = nameTF.text;
                     }else{
                         [UIUtil showToast:@"修改失败" inView:self.view];
                     }
                 } fail:^(NSError *error)
                 {
                     [UIUtil showToast:@"网络异常" inView:self.view];
                 }];
            }
        }
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
