//
//  HomeVC.m
//  FHZL
//
//  Created by hk on 17/12/5.
//  Copyright © 2017年 hk. All rights reserved.
//
#import "InformationCSQViewController.h"
#define IMAGESTR @"微众世界_头像0.png" //暂时用此图片 后面你自己改
#import "HomeVC.h"
#import "CustomeCsqButton.h"
#import "Header.h"
#import "HomeMusicCell.h"
#import "HomeGT10Cell.h"
#import "DrickingClassCell.h"
#import "TuPaiCell.h"
#import "NewMusicVC.h"
#import "UserCenterVC.h"
#import "UserCenterOldVC.h"
#import "CYTabBarController.h"
#import "LocationVC.h"
#import "CarListViewController.h"
#import "TuPaiViewController.h"

#import "AlarmListVC.h"

#import "DialogueVC.h"
#import "listenSoundVC.h"

#import "BindDeviceVC.h"
@interface HomeVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UIButton *_MusicButton;
    UIButton *_CarmeaButton;
    UIButton *leftBarButton;
}
@property (weak, nonatomic) IBOutlet UITableView *_HomeTableView;
@property (weak, nonatomic) IBOutlet UIView *BottomView;
@end

@implementation HomeVC
- (IBAction)diaLogueClick:(id)sender {
    DialogueVC *vc = [[DialogueVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavi];
    [[UserManager sharedInstance]save];
    
    [__HomeTableView registerNib:[UINib nibWithNibName:@"HomeMusicCell" bundle:nil] forCellReuseIdentifier:@"HomeMusicCell"]; //
    [__HomeTableView registerNib:[UINib nibWithNibName:@"DrickingClassCell" bundle:nil] forCellReuseIdentifier:@"DrickingClassCell"]; //
    [__HomeTableView registerNib:[UINib nibWithNibName:@"HomeGT10Cell" bundle:nil] forCellReuseIdentifier:@"HomeGT10Cell"];
    [__HomeTableView registerNib:[UINib nibWithNibName:@"TuPaiCell" bundle:nil] forCellReuseIdentifier:@"TuPaiCell"];
    __HomeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    _MusicButton = [[CustomeCsqButton alloc]initWithFrame:CGRectMake(0, 0, (kScreenWidth - 81)/2, TabbarHigth) normalImageStr:@"APP_主页_音乐_N" seleImageStr:@"APP_主页_音乐_P" higligthImageStr:@"APP_主页_音乐_P" titleStr:@"音乐" numberStr:nil ClickBlock:nil];
//    [_MusicButton addTarget:self action:@selector(MusicClick) forControlEvents:UIControlEventTouchUpInside];
//    [_BottomView addSubview:_MusicButton];
//
//    _CarmeaButton = [[CustomeCsqButton alloc]initWithFrame:CGRectMake(kScreenWidth - (kScreenWidth - 81)/2, 0, (kScreenWidth - 81)/2, TabbarHigth) normalImageStr:@"APP_主页_随拍_N" seleImageStr:@"APP_主页_随拍_P" higligthImageStr:@"APP_主页_随拍_P" titleStr:@"图拍" numberStr:nil ClickBlock:^(NSInteger number){
//        [self.navigationController pushViewController:[TuPaiViewController new] animated:YES];
//    }];
//    [_BottomView addSubview:_CarmeaButton];
    
    
    
    [newMusic shareInstance];
    //仅能init一次
    
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MusicCell_isAddSetNo" object:nil];
    self.navigationController.navigationBar.translucent = YES;
    [self changeNavi];
    [self changeUserInfo];
}
-(void)changeNavi{
    
    if ([[UserManager sharedInstance].user.iconId integerValue] >= 1 && [[UserManager sharedInstance].user.iconId integerValue] <= 12) {
        [self addNavigationItemWithImageNames
         :@[[NSString stringWithFormat:@"ui2_user_icon%ld.png",(long)[USERMANAGER.user.iconId integerValue]]] isLeft:YES target:self action:@selector(showLeft) tags:@[@1000]];
    }else if([[UserManager sharedInstance].user.iconId integerValue] == 13 ){
        if (!headImageIsEmpty(USERMANAGER.user.headPicPath) ) {
            [self addNavigationItemWithImageNames
             :@[USERMANAGER.user.headPicPath] isLeft:YES target:self action:@selector(showLeft) tags:@[@1000]];
        }else{
            [self addNavigationItemWithImageNames
             :@[@"微众世界_头像0"] isLeft:YES target:self action:@selector(showLeft) tags:@[@1000]];
        }
    }
    else if( [[UserManager sharedInstance].user.iconId integerValue] == 14){
        if (!headImageIsEmpty(USERMANAGER.user.upPicPath) ) {
            [self addNavigationItemWithImageNames
             :@[USERMANAGER.user.upPicPath] isLeft:YES target:self action:@selector(showLeft) tags:@[@1000]];
        }else{
            [self addNavigationItemWithImageNames
             :@[@"微众世界_头像0"] isLeft:YES target:self action:@selector(showLeft) tags:@[@1000]];
        }
    }else
    {
        [self addNavigationItemWithImageNames
         :@[@"微众世界_头像0"] isLeft:YES target:self action:@selector(showLeft) tags:@[@1000]];
    }
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"主页";
}
-(void)viewDidAppear:(BOOL)animated{
    
}
-(void)setNavi{
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"主页";
    [self addNavigationItemWithImageNames
     :@[@"APP_主页_扫码_N.png"] isLeft:NO target:self action:@selector(showRight) tags:@[@1000]];
    [self addNavigationItemWithImageNames
     :@[@"ui2_user_icon0.png"] isLeft:YES target:self action:@selector(showLeft) tags:@[@1001]];
}
-(void)showLeft{
    [self.navigationController pushViewController:[UserCenterOldVC new] animated:YES];
}
-(void)showRight{
   [self.navigationController pushViewController:[BindDeviceVC new] animated:YES];
}
-(void)MusicClick{
    [self.navigationController pushViewController:[NewMusicVC new] animated:YES];
}
-(void)GTClick{
    CYTabBarController *GT_10Tabbar = [[CYTabBarController alloc]init];
    [CYTabBarConfig shared].selectedTextColor = [UIColor colorWithRed:45/255. green:159/255. blue:254/255. alpha:1];
    
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:[LocationVC new]];
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:[CarListViewController new]];
    
    AlarmListVC *listVC = [[AlarmListVC alloc]init];
    listVC.selfType = All;
    UINavigationController *nav3 = [[UINavigationController alloc]initWithRootViewController:listVC];
    
    UINavigationController *nav4 = [[UINavigationController alloc]initWithRootViewController:[listenSoundVC new]];
    
    [GT_10Tabbar addChildController:nav1 title:@"定位" imageName:@"底部_定位_N.png" selectedImageName:@"底部_定位_P.png"];
    [GT_10Tabbar addChildController:nav2 title:@"列表" imageName:@"底部_列表_N.png"  selectedImageName:@"底部_列表_P.png"];
    [GT_10Tabbar addChildController:nav3 title:@"警报信息" imageName:@"底部_警报信息_N.png"  selectedImageName:@"底部_警报信息_P.png"];
    [GT_10Tabbar addChildController:nav4 title:@"声音监听" imageName:@"底部_声音监听_N.png"  selectedImageName:@"底部_声音监听_P.png"];
    //        [self.navigationController pushViewController:GT_10Tabbar animated:YES];
    [self presentViewController:GT_10Tabbar animated:NO completion:nil];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [UserManager sharedInstance].AllDeviceArray.count ) {
        return 30;
    }else{
        return 150;
    }
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 30;
//}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [UserManager sharedInstance].AllDeviceArray.count + 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict;
    if (indexPath.row != [UserManager sharedInstance].AllDeviceArray.count) {
        dict = [UserManager sharedInstance].AllDeviceArray[indexPath.row];
    }
    if ([dict[TYPE]isEqualToString:GT10]) {
        static NSString *identifierID1 = @"HomeGT10Cell";
        HomeGT10Cell *cell = [tableView dequeueReusableCellWithIdentifier:identifierID1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backImage.image = [UIImage imageNamed:@"智能找车.png"];
        cell.cellType = GT10;
        return cell;
    }
    else if([dict[TYPE]isEqualToString:SUIPAI]){
        static NSString *identifierID1 = @"TuPaiCell";
        TuPaiCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierID1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backImage.image = [UIImage imageNamed:@"我在这.png"];
        cell.cellType = SUIPAI;
        return cell;
    }
    else if([dict[TYPE]isEqualToString:DRINKGLASS]){
        static NSString *identifierID3 = @"DrickingClassCell";
        DrickingClassCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierID3];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if([dict[TYPE]isEqualToString:MUSIC]){
        static NSString *identifierID2 = @"HomeMusicCell";
        HomeMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierID2];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSLog(@"cell什么时候调用此方法");
        cell.isAdd = NO;
        cell.isReload = NO;
        return cell;
    }else{
        static NSString *identifierIDCell = @"identifierIDCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierIDCell];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierIDCell];
        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict;
    if (indexPath.row != [UserManager sharedInstance].AllDeviceArray.count) {
        dict = [UserManager sharedInstance].AllDeviceArray[indexPath.row];
    }
    if ([dict[TYPE]isEqualToString:GT10]) {
        [self GTClick];
    }else if([dict[TYPE]isEqualToString:MUSIC]){
        [self MusicClick];
    }
    else if([dict[TYPE]isEqualToString:SUIPAI]){
        [self.navigationController pushViewController:[TuPaiViewController new] animated:YES];
    }
}
-(void)changeUserInfo{
    NSDictionary *dic = @{@"userId":CsqStringIsEmpty(USERMANAGER.user.userID)
                         
                          };
    
    [ZZXDataService HFZLRequest:@"main/view" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
           
             UserManager *userManager = [UserManager sharedInstance];
             userManager.user.isLogined = YES;
         
             NSDictionary *userDict = data[@"data"][@"userInfo"];
             if (!kDictIsEmpty(userDict)) {
                 userManager.user.nickname = GetData(userDict, @"nickName");
                 userManager.user.userID = GetData(userDict, @"id") ;
                 userManager.user.macID = GetData(userDict, @"macId");
                 userManager.user.iconId = GetData(userDict, @"iconId");
                 userManager.user.mobilePhone = GetData(userDict, @"mobilePhone");
                 userManager.user.appCookie = GetData(userDict, @"appCookie");
                 //
                 
                 NSString *str = GetData(userDict, @"headPicPath");
                 if (!kStringIsEmpty(str)) {
                     if ([str hasPrefix:@"http://thirdwx"]) {
                         userManager.user.headPicPath = GetData(userDict, @"headPicPath");
                     }else{
                         userManager.user.upPicPath = GetData(userDict, @"headPicPath");
                     }
                 }
                 
                 
                 
                 userManager.user.mobilePhone = GetData(userDict, @"phone");
             }

             NSArray *cardVeiwArr = data[@"data"][@"cardVeiws"];
             if (!kArrayIsEmpty(cardVeiwArr)) {
                 [userManager.AllDeviceArray removeAllObjects];
                 for (NSDictionary *cardDict in cardVeiwArr) {
                     NSLog(@"desc = %@",cardDict[@"desc"]);
                     NSDictionary *cardD;
                     if ([cardDict[@"viewId"] isEqualToString:@"101"]) {
                         NSLog(@"添加101");
                         cardD  = @{TYPE:GT10,orderNum:cardDict[@"orderNum"]};
                         [userManager.AllDeviceArray addObject:cardD];
                     }else if([cardDict[@"viewId"] isEqualToString:@"102"]){
                         NSLog(@"添加102");
//                         cardD = @{TYPE:MUSIC,orderNum:cardDict[@"orderNum"]};
//                         [userManager.AllDeviceArray addObject:cardD];
                     }else if([cardDict[@"viewId"] isEqualToString:@"103"]){
                         NSLog(@"添加103");
                         cardD = @{TYPE:SUIPAI,orderNum:cardDict[@"orderNum"]};
                         [userManager.AllDeviceArray addObject:cardD];
                     }
                     
                 }
             }
             [[UserManager sharedInstance] save];
             [self changeNavi];
             [__HomeTableView reloadData];
         }else{
//             [UIUtil showToast:@"请重新登录" inView:self.view];
//             switch ([data[@"code"]integerValue]) {
//                 case 101016:
//                 {
//                     [UIUtil showToast:@"账户密码错误" inView:self.view];
//                 }
//                     break;
//                 case 101017:
//                 {
//                     [UIUtil showToast:@"账户未注册" inView:self.view];
//                 }
//                     break;
//                 default:
//                     [UIUtil showToast:@"登录失败" inView:self.view];
//                     break;
//             }
         }
     } fail:^(NSError *error)
     {
//         [UIUtil showToast:@"网络异常" inView:self.view];
         
     }];
    
    
    
    [ZZXDataService HFZLRequest:@"alarm/get-condition" httpMethod:@"POST" params1:dic   file:nil success:^(id data)
     {
         if ([data[@"code"]integerValue] == 0) {
             NSLog(@"condition = %@",data[@"data"]);
         }
     } fail:^(NSError *error)
     {
     }];
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
