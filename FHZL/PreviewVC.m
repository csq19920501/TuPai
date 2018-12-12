//
//  PreviewVC.m
//  FHZL
//
//  Created by hk on 2018/2/8.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "PreviewVC.h"
#import "Header.h"
#import "Masonry.h"
#import "imageViewPreCell.h"
#import "ImageSingelModel.h"
#import "LookPeople.h"
#import "FFDropDownMenuView.h"
#import "ShareChooseViewController.h"
#import "CSQPhotoPreviewController.h"
#import "KDXFvoiceManager.h"
#import "PictureEditVC_TwoFirst.h"
@interface PreviewVC ()<UITableViewDataSource,UITableViewDelegate,FFDropDownMenuViewDelegate>
{
    UIImage *cellOneImage;
}
@property (nonatomic, strong) ShareView * shareView;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstant;
@property (nonatomic, strong) FFDropDownMenuView *dropdownMenu;
@end

@implementation PreviewVC
-(instancetype)init{
    if (self = [ super init]) {
        _photoArray = [NSMutableArray array];
        return self;
    }
    return nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.topConstant.constant = kTopHeight;
    // Do any additional setup after loading the view from its nib.

    
//    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"LookPeople" owner:nil options:nil];
    CSQPreHeadView *headerViwe = [[CSQPreHeadView alloc]init];
    headerViwe.frame = CGRectMake(0, 0, kScreenWidth, 126);//autoHeigthFrame(_detailModel.note,kScreenWidth - 32,17).size.height + 163  固定高度屏蔽标题也内容
    [headerViwe setNavClick:^{
        showNewAlert(@"是否导航到该位置", nil, nil, ^(UIAlertAction*act){
            NSLog(@"导航到目的地");
            TIPmodel *modelTIP = [[TIPmodel alloc]init];
            modelTIP.latitude = [_detailModel.y floatValue];
            modelTIP.longitude = [_detailModel.x floatValue];
            modelTIP.addressString =  _detailModel.address;
            [[KDXFvoiceManager shareInstance]sendNai:modelTIP];
        })
    }];
    if([_detailModel.icconid integerValue] == 13 || [_detailModel.icconid integerValue] == 14){
        [headerViwe.headImage sd_setImageWithURL:[NSURL URLWithString:_detailModel.headPicPath] placeholderImage:[UIImage imageNamed:@"微众世界_头像0"]];
    }else{
        headerViwe.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ui2_user_icon%ld.png",(long)[_detailModel.icconid integerValue]]];
    }
    headerViwe.timeLabel.text = [UserManager getDateDisplayString:[_detailModel.groupDate longLongValue]];
    headerViwe.noteLabel.text = _detailModel.address;
    headerViwe.nameLabel.text = _detailModel.nickName;
//    headerViwe.contentLabel.text = _detailModel.note;
//    headerViwe.biaotiLabel.text = _detailModel.title;
    _myTableview.tableHeaderView = headerViwe;
    _myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableview.delegate = self;
    _myTableview.dataSource = self;
    [_myTableview registerNib:[UINib nibWithNibName:@"imageViewPreCell" bundle:nil] forCellReuseIdentifier:@"imageViewPreCell"];
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(0, 0, kScreenWidth, autoHeigthFrame(_detailModel.note,kScreenWidth - 32,17).size.height + 10);
    UILabel *label = [[UILabel alloc]init];
    label.numberOfLines = 0;
    [view addSubview:label];
    label.font = [UIFont systemFontOfSize:17];
    label.text = _detailModel.note;
    label.textColor = [UIColor blackColor];
    //    label.backgroundColor = [UIColor greenColor];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(view);
        make.left.equalTo(view).offset(20);
    }];
    _myTableview.tableFooterView = view;
    
    [self setNavi];
}
-(void)setNavi{
    self.title = @"详情";
//    [self setupDropDownMenu];
//    [self addNavigationItemWithImageNames
//     :@[@"列表_7.png"] isLeft:NO target:self action:@selector(showDropDownMenu) tags:@[@1001]];
}

/** 初始化下拉菜单 */
-(void)setupDropDownMenu{
    NSArray *modelsArray = [self getMenuModelsArray];
    
    [self.dropdownMenu removeFromSuperview];
    self.dropdownMenu = nil;
    
    self.dropdownMenu = [FFDropDownMenuView ff_DefaultStyleDropDownMenuWithMenuModelsArray:modelsArray menuWidth:90 eachItemHeight:FFDefaultFloat menuRightMargin:FFDefaultFloat triangleRightMargin:FFDefaultFloat csqIsRight:YES];
    
    //如果有需要，可以设置代理（非必须）
    self.dropdownMenu.delegate = self;
    self.dropdownMenu.ifShouldScroll = YES;
    [self.dropdownMenu setupRight];
}
- (void)showDropDownMenu {
    [self.dropdownMenu showMenu];
}
-(void)ffDropDownMenuViewWillAppear{
    NSLog(@"菜单出现");
   
}
-(void)ffDropDownMenuViewWillDisappear{
    NSLog(@"菜单消失");
    
}
- (NSArray *)getMenuModelsArray {
    NSMutableArray *menuArray = [NSMutableArray array];
    FFDropDownMenuModel *menuModel0 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"分享" menuItemIconName:nil  menuBlock:^{
            [self share];
        
    }];
    [menuArray addObject:menuModel0];
    if ([_detailModel.userID isEqualToString: USERMANAGER.user.userID]) {
        FFDropDownMenuModel *menuModel1 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"删除" menuItemIconName:nil  menuBlock:^{
            if (self.isOnlyOne) {
                showNewAlert(@"是否删除该标题", nil, nil, ^(UIAlertAction*action){
                    [self dele];
                })
            }else{
                showNewAlert(@"是否删除", nil, nil, ^(UIAlertAction*action){
                    [self dele];
                })
            }
            
        }];
        [menuArray addObject:menuModel1];
        
        FFDropDownMenuModel *menuModel2 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"编辑" menuItemIconName:nil  menuBlock:^{
            [self editDesc];
        }];
        [menuArray addObject:menuModel2];
    }
    return menuArray;
}
-(void)share{
    [UIUtil showProgressHUD:@"获取分享链接..." inView:self.view];
    NSDictionary *dic = @{@"groupId":CsqStringIsEmpty(_detailModel.ID)};
    [ZZXDataService HFZLRequest:@"photo/share" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             if ([data[@"data"] isKindOfClass:[NSString class]]) {
                 if (!kStringIsEmpty(data[@"data"])) {
                     [UIUtil hideProgressHUD];
//                     ShareChooseViewController* viewController = [[ShareChooseViewController alloc] init];
//                     viewController.text = [NSString stringWithFormat:@"%@%@",@"您的好友分享给您的图文信息:",data[@"data"]];
//                     [self.navigationController presentSemiViewController:viewController withOptions:@{ KNSemiModalOptionKeys.pushParentBack:@(NO), KNSemiModalOptionKeys.animationDuration:@(0.35f), KNSemiModalOptionKeys.shadowOpacity:@(0.0f),}];
                     
                     NSString *shareImageUrl ;
                     if (kArrayIsEmpty(_photoArray)) {
                         shareImageUrl = IconImageUrl;
                     }else{
                         ImageSingelModel *model = _photoArray[0];
                         shareImageUrl = model.path;
                     }
                     
                     [_shareView removeFromSuperview];
                     _shareView = nil;

                     NSDictionary *dict = @{@"shareUrl":data[@"data"],@"shareText":_detailModel.note,@"shareTitle":@"智联图拍",@"shareImageUrl":shareImageUrl};
                     _shareView = [ShareView getFactoryShareViewWithCsqDiction:dict];
                     [_shareView showInView:self.view];
                     [_shareView showWithContentType:JSHARELink];
                 }else{
                     
                     [UIUtil showToast:@"获取失败" inView:self.view];
                 }
             }else{
                 
                 [UIUtil showToast:@"获取失败" inView:self.view];
             }
         }else{
             [UIUtil showToast:@"获取失败" inView:self.view];
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"网络异常" inView:self.view];
     }];
}
-(void)dele{

    
    if (!kArrayIsEmpty(_photoArray)) {
        ImageSingelModel *model = _photoArray[0];
        [UIUtil showProgressHUD:@"正在删除" inView:self.view];
        NSDictionary *dic = @{@"id":CsqStringIsEmpty(model.ID)};
        [ZZXDataService HFZLRequest:@"photo/delete-single" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
         {
             if ([data[@"code"]integerValue] == 0) {
                 [UIUtil showToast:@"删除成功" inView:self.view];
                 CSQ_DISPATCH_AFTER(1.5, ^{
                     if (_deleSuccess) {
                         _deleSuccess();
                     }
                     if (!self.isOnlyOne) {
                         [self.navigationController popViewControllerAnimated:YES];
                     }else{
                         [self.navigationController popToRootViewControllerAnimated:YES];
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
}
-(void)deleBiaoTi{
    
    
    [UIUtil showProgressHUD:@"正在删除" inView:self.view];
    NSDictionary *dic = @{@"id":CsqStringIsEmpty(self.detailModel.ID)};
    [ZZXDataService HFZLRequest:@"photo/delete-group" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             [UIUtil showToast:@"删除成功" inView:self.view];
             CSQ_DISPATCH_AFTER(1.5, ^{
                 if (_deleSuccess) {
                     _deleSuccess();
                 }
                 [self.navigationController popToRootViewControllerAnimated:YES];
             })
         }else{
             [UIUtil showToast:@"删除失败" inView:self.view];
         }
     } fail:^(NSError *error)
     {
         [UIUtil showToast:@"删除异常" inView:self.view];
     }];
}
-(void)editDesc{
    if (!kArrayIsEmpty(_photoArray)) {
        ImageSingelModel *model = _photoArray[0];
    
    PictureEditVC_TwoFirst  *pictVC = [[PictureEditVC_TwoFirst alloc]init];
    pictVC.photoImage = cellOneImage;
    pictVC.itemId = model.ID;
    pictVC.pictureEditV_Type = PictureEditV_Edit;
    pictVC.titleStr = self.detailModel.title;
    pictVC.contentStr = model.desc;
    [pictVC setUpdatePictureSuccess:^{
        NSLog(@"上传图片成功返回图拍主页面刷新图片");
        //            _searchBar.text = nil;
        //            [self getPhotoArray];
    }];
    [self.navigationController pushViewController:pictVC animated:YES];
        
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _photoArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageSingelModel *model = _photoArray[indexPath.row];
    return model.imageHeigth;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageSingelModel *model = _photoArray[indexPath.row];
    NSLog(@"ImageSingelModel *model paht %@",model.path);
    static NSString *identifier = @"imageViewPreCell";
    imageViewPreCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
//        cell = [[imageViewPreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"imageViewPreCell" owner:nil options:nil];
        cell = [views objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    MPWeakSelf(self)
    [cell.phonoImage sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:[UIImage imageNamed:@"testPicture.png"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image != nil) {
            CGFloat width = (kScreenWidth - 16) * (image.size.height / image.size.width) + 12;
            model.imageHeigth = width;
            [cell setHeight:model.imageHeigth];
            if (indexPath.row == 0) {
                cellOneImage = image;
            }
        }
    }];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *imageUrlArr = [NSMutableArray array];
    for (ImageSingelModel *model in _photoArray) {
        [imageUrlArr addObject:model.path];
    }
    
    CSQPhotoPreviewController *previewVC = [[CSQPhotoPreviewController alloc]init];
    previewVC.photos = imageUrlArr;
    previewVC.currentIndex = indexPath.row;
    [previewVC setDidDismiss:^{
                             
    }];
    [self.navigationController pushViewController:previewVC animated:YES];
}
//-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc]init];
//    UILabel *label = [[UILabel alloc]init];
//    label.numberOfLines = 0;
//    [view addSubview:label];
//    label.font = [UIFont systemFontOfSize:17];
//    label.text = _detailModel.note;
//    label.textColor = [UIColor blackColor];
////    label.backgroundColor = [UIColor greenColor];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.right.equalTo(view);
//        make.left.equalTo(view).offset(20);
//    }];
//    return view;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return autoHeigthFrame(_detailModel.note,kScreenWidth - 32,17).size.height + 10;
//}

-(void)setViews{
//    UIScrollView *backScrollView = [[UIScrollView alloc]init];
//    backScrollView.backgroundColor = [UIColor colorWithRed:(235)/255.0 green:(235)/255.0 blue:(241)/255.0 alpha:(1)];
//    backScrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight *2);
//    [self.view addSubview:backScrollView];
//    [backScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(self.view);
//        make.top.equalTo(self.view).offset(kTopHeight);
//    }];
//
//
//    UIImageView *headImageView = [[UIImageView alloc]init];
//    headImageView.image = [UIImage imageNamed:@"拍摄记录1_内容区_行走_N"];
//    [backScrollView addSubview:headImageView];
//    [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.mas_equalTo(20);
//        make.width.height.mas_equalTo(60);
//    }];
//
//    UILabel *nameLabel = [[UILabel alloc]init];
//    nameLabel.text = @"忽悠米粉_9011";
//    [backScrollView addSubview:nameLabel];
//    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(headImageView.mas_top);
//        make.width.height.mas_equalTo(23);
//        make.left.equalTo(headImageView.mas_right).offset(10);
//    }];
//
//    UILabel *lineLabel = [[UILabel alloc]init];
//    lineLabel.backgroundColor = [UIColor lightGrayColor];
//    [backScrollView addSubview:lineLabel];
//    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(headImageView.mas_bottom).offset(30);
//        make.width.height.mas_equalTo(1);
//        make.left.right.mas_equalTo(10);
//    }];
//
//    UILabel* contentLabel = [[UILabel alloc]init];
//    contentLabel.text = @"经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息经过大半年的生养休息";
//    contentLabel.numberOfLines = 0;
//    contentLabel.font = [UIFont systemFontOfSize:14];
//    [backScrollView addSubview:contentLabel];
//    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(lineLabel.mas_bottom).offset(5);
//        make.left.right.mas_equalTo(15);
//        make.width.height.mas_equalTo(autoHeigthFrame(contentLabel.text,, <#sysFont#>));
//    }];
    
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
