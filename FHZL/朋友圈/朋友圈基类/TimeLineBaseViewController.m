//
//  TimeLineBaseViewController.m
//  WeChat
//
//  Created by zhengwenming on 2017/9/18.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//


//-----------------------此类为朋友圈基类-------------------------
#import "Masonry.h"
#import "Header.h"
#import "TimeLineBaseViewController.h"
#import "LookPeople.h"

@interface TimeLineBaseViewController ()
@property(nonatomic,strong)NSDictionary *jsonDic;
@end

@implementation TimeLineBaseViewController
///本地的json测试数据
-(NSDictionary *)jsonDic{
    if (_jsonDic==nil) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"]]];
        _jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    }
    return _jsonDic;
}
#pragma mark
#pragma mark 从本地获取朋友圈1的测试数据
-(void)getTestData1{
        for (NSDictionary *eachDic in self.jsonDic[@"data"][@"rows"]) {
            MessageInfoModel1 *messageModel = [[MessageInfoModel1 alloc] initWithDic:eachDic];
            [self.dataSource addObject:messageModel];
        }
}
#pragma mark
#pragma mark 从本地获取朋友圈2的测试数据
-(void)getTestData2{
    for (NSDictionary *eachDic in self.jsonDic[@"data"][@"rows"]) {
        MessageInfoModel2 *messageModel = [[MessageInfoModel2 alloc] initWithDic:eachDic];
        [self.dataSource addObject:messageModel];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"朋友圈";
    [self.view addSubview:self.tableView];
    
//    UIImageView * backgroundImageView= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
//    backgroundImageView.image = [UIImage imageNamed:@"个人中心_好友互动_壁纸.png"];
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"LookPeople" owner:nil options:nil];
    CSQTableHeadView *headerViwe = [views objectAtIndex:1];
    headerViwe.frame = CGRectMake(0, 0, kScreenWidth, 300);
    [headerViwe setBackClick:^{
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.tableView.tableHeaderView = headerViwe;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).with.offset(kTopHeight);
    }];
}
//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = NO;
//}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
@end
