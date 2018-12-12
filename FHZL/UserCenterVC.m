//
//  UserCenterVC.m
//  FHZL
//
//  Created by hk on 17/12/14.
//  Copyright © 2017年 hk. All rights reserved.
//

#import "UserCenterVC.h"
#import "Header.h"
#import "UserCenterItemCell.h"
#import "UserCenterHeadCell.h"
#import "GoodsTwoTableViewCell.h"
@interface UserCenterVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *MyTablewView;

@end

@implementation UserCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_MyTablewView registerNib:[UINib nibWithNibName:@"GoodsTwoTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsTwoTableViewCell"];
    [_MyTablewView registerNib:[UINib nibWithNibName:@"UserCenterHeadCell" bundle:nil] forCellReuseIdentifier:@"UserCenterHeadCell"];
    [self setNavi];
}
-(void)setNavi{
    self.navigationController.navigationBar.hidden = NO;
    self.view.backgroundColor = HBackColor;
    self.title = @"设置";
    
//    [self.navigationItem setLeftBarButtonItem:({
//        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:({
//            UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
//            [button setBackgroundImage:[UIImage imageNamed:BackImageNormal] forState:UIControlStateNormal];
//            [button setBackgroundImage:[UIImage imageNamed:BackImageP] forState:UIControlStateHighlighted];
//            [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
//            button.frame = CGRectMake(0, 0, 25, 25);
//            button;
//        })];
//        barButton;//APP_登录确定1_返回.png
//    })];
}
-(void)showLeft{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - uitableviewDele
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 10;
            break;
        default:
            return 1;
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 9;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
       return 5;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return 2;
                break;
            case 2:
                return 1;
                break;
            case 3:
                return 3;
                break;
            case 4:
                return 1;
                break;
            default:
                return 0;
                break;
        }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 100;
    }else{
        return 50;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{//
    if (indexPath.section == 0) {
        static NSString *indentifierID1 = @"UserCenterHeadCell";
        UserCenterHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifierID1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *indentifierID2 = @"GoodsTwoTableViewCell";
        GoodsTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifierID2];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.section) {
            case 1:
            {
                if (indexPath.row == 0) {
                    cell.imageView.image = [UIImage imageNamed:@"4.jiepin.png"];
                    cell.bodyLabel.text = @"修改密码";
                }
                if (indexPath.row == 1) {
                    cell.imageView.image = [UIImage imageNamed:@"4.jiepin.png"];
                    cell.bodyLabel.text = @"修改密码";
                }
            }
                break;
            case 2:
            {
                if (indexPath.row == 0) {
                    cell.imageView.image = [UIImage imageNamed:@"4.jiepin.png"];
                    cell.bodyLabel.text = @"修改密码";
                }
            }
                break;
            case 3:
            {
                if (indexPath.row == 0) {
                    cell.imageView.image = [UIImage imageNamed:@"4.jiepin.png"];
                    cell.bodyLabel.text = @"修改密码";
                }
            }
                break;
            case 4:
            {
                if (indexPath.row == 0) {
                    cell.imageView.image = [UIImage imageNamed:@"4.jiepin.png"];
                    cell.bodyLabel.text = @"修改密码";
                }
            }
                break;
            default:
                break;
        }
        return cell;
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
