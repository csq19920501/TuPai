//
//  ShopCarVC.m
//  FHZL
//
//  Created by hk on 2018/12/8.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "ShopCarVC.h"
#import "ShopCarCell.h"
#import "Header.h"
@interface ShopCarVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ShopCarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"购物车";
    if (self.hasTarbar) {
        self.bottomConstraint.constant = TabbarHigth;
    }
    [self addNavigationItemWithImageNames:@[@"back_icon"] isLeft:YES target:self action:@selector(showLeft) tags:nil];
    self.myTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.myTableview registerNib:[UINib nibWithNibName:@"ShopCarCell" bundle:nil] forCellReuseIdentifier:@"ShopCarCell"];
    self.myTableview.backgroundColor = [UIColor clearColor];
}
-(void)showLeft{
    if (self.hasTarbar) {
        [APPDELEGATE.homeNavi popToRootViewControllerAnimated:YES];
    }else{
        [super showLeft];
    }
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"ShopCarCell";
    ShopCarCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (!cell) {
//        cell = [[ShopCarCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 138;
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
