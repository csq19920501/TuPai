//
//  InformationCSQViewController.m
//  FHZL
//
//  Created by hk on 17/11/24.
//  Copyright © 2017年 hk. All rights reserved.
//
#define goodsTableviewHeigth kScreenWidth *500/320 + 144 + 52 * 5 + 10 *5


#define bottomHeigth 60
#define intervalWidth 10
#define url1 @"https://www.baidu.com/"
#define url2 @"https://docs.jiguang.cn/"
#define url3 @"https://open.weixin.qq.com/"
#define IMAGESTR @"微众世界_头像0.png" //暂时用此图片 后面你自己改
#import "InformationCSQViewController.h"
#import "TopSwitchCsqView.h"
#import "Header.h"
#import "CustomeCsqButton.h"
#import "GoodsOneTableViewCell.h"
#import "GoodsTwoTableViewCell.h"
#import "GoodsFourTableViewCell.h"
#import "XYImageScrollView.h"
@interface InformationCSQViewController ()<TopSwitchDele,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    TopSwitchCsqView *topView;
    TopSwitchCsqView *topView2;
    UIScrollView *musciScroll; //全部滚动
    UIScrollView *commodityView; //商品全部滚动
    UIScrollView *webBackScroll; //网页详情滚动 暂时没做第二第三页滚动 只修改第一页的网页加载url
    UIView *detailView;  //详情
    UIView *evaluationView; //评价
    CustomeCsqButton *concernButton;//关注
    CustomeCsqButton *ShoppingCartButton;//购物车
    UITableView *goosTableView;
//    UIWebView *GraphicDetailWebView;
//    UIWebView *SpesificantionsWebview;
//    UIWebView *PackineSaleWebview;
}
@property(nonatomic,strong)UIWebView * GraphicDetailWebView; //图形详情 暂时没做下面两页滚动 只修改第一页的网页加载url
@property(nonatomic,strong)UIWebView * SpesificantionsWebview; //规格参数
@property(nonatomic,strong)UIWebView * PackineSaleWebview; //包装售后
@property (weak, nonatomic) IBOutlet UIView *BottomButtonVIew;//关注购物车 加入购物车 结算
@end

@implementation InformationCSQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavi];
    [self setButtonVIew];
    [self setMiddleView];
    
    NSCharacterSet* nonDigits =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    int remainSecond =[[@"第十一个" stringByTrimmingCharactersInSet:nonDigits] intValue];
    int remainSecond2 =[[@"第11个" stringByTrimmingCharactersInSet:nonDigits] intValue];
    NSLog(@" remainSecond %d  remainSecond2 %d",remainSecond,remainSecond2);
}
-(void)setNavi{
//    self.navigationController.navigationBar.translucent = YES;
    [self.navigationItem setLeftBarButtonItem:({
        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setBackgroundImage:[UIImage imageNamed:BackImageNormal] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:BackImageP] forState:UIControlStateHighlighted];
         //   [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(0, 0, 25, 25);
            button;
        })];
        barButton;//APP_登录确定1_返回.png
    })];
    [self.navigationItem setRightBarButtonItem:({
        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:({
            UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setBackgroundImage:[UIImage imageNamed:@"MAIN2_位置_状态栏_轨迹_N.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"MAIN2_位置_状态栏_轨迹_N.png"] forState:UIControlStateHighlighted];
      //      [button addTarget:self action:@selector(showReft) forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(0, 0, 25, 25);
            button;
        })];
        barButton;//APP_登录确定1_返回.png
    })];

    topView = [[TopSwitchCsqView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth/2, 45) :@[@"商品",@"详情",@"评价"] categryStr:@"first"];
    topView.topSwitchDele = self;
    self.navigationItem.titleView = topView;
}
//设置底部关注和购物车button
-(void)setButtonVIew{
    //关注
    concernButton = [[CustomeCsqButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth/4, bottomHeigth) normalImageStr:IMAGESTR seleImageStr:@"标题栏_返回_P.png" titleStr:@"关注" numberStr:nil];
    [concernButton addTarget:self action:@selector(concern) forControlEvents:UIControlEventTouchUpInside];
    [_BottomButtonVIew addSubview:concernButton];
    //购物车
    ShoppingCartButton = [[CustomeCsqButton alloc]initWithFrame:CGRectMake(kScreenWidth/4, 0, kScreenWidth/4, bottomHeigth) normalImageStr:IMAGESTR seleImageStr:@"标题栏_返回_P.png" titleStr:@"购物车" numberStr:@"2"];
    [ShoppingCartButton addTarget:self action:@selector(shopCar) forControlEvents:UIControlEventTouchUpInside];
    [_BottomButtonVIew addSubview:ShoppingCartButton];
}
//点击关注
-(void)concern{
    concernButton.selected = !concernButton.selected;
    //示范修改购物车数量 后面删除
    if (concernButton.selected) {
        [ShoppingCartButton setNumber:@"0"];
    }else{
        [ShoppingCartButton setNumber:@"3"];

    }
    
}
//添加购物车
- (IBAction)addShopCar:(id)sender {
    [ShoppingCartButton setNumber:@"4"];
}
//立即购买
- (IBAction)buyNow:(id)sender {
}
//点击购物车
-(void)shopCar{
    
}
//设置中间滚动视图
-(void)setMiddleView{
   

    musciScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, kTopHeight, kScreenWidth, kScreenHeight - kTopHeight - bottomHeigth)];
    float width = musciScroll.frame.size.width;
    float heigth = musciScroll.frame.size.height;
    musciScroll.contentSize = CGSizeMake(width * 3, heigth);
    musciScroll.showsHorizontalScrollIndicator = NO;
    musciScroll.pagingEnabled = YES;
    musciScroll.delegate = self;
    musciScroll.bounces = NO;
    [self.view addSubview:musciScroll];
    
    commodityView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, heigth)];
    [musciScroll addSubview:commodityView];
    commodityView.contentSize = CGSizeMake(width, heigth  + intervalWidth + goodsTableviewHeigth);
    commodityView.showsVerticalScrollIndicator = NO;
    commodityView.delegate = self;
    commodityView.backgroundColor = [UIColor clearColor];
    
    goosTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, goodsTableviewHeigth) style:UITableViewStyleGrouped];
    [goosTableView registerNib:[UINib nibWithNibName:@"GoodsOneTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsOneTableViewCell"];
    [goosTableView registerNib:[UINib nibWithNibName:@"GoodsTwoTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsTwoTableViewCell"];
    [goosTableView registerNib:[UINib nibWithNibName:@"GoodsFourTableViewCell" bundle:nil] forCellReuseIdentifier:@"GoodsFourTableViewCell"];
    goosTableView.delegate = self;
    goosTableView.dataSource = self;
    goosTableView.bounces = NO;
    [commodityView addSubview:goosTableView];

//下面的webView最好懒加载可参考京东 否则影响网速
    
    UIView *meunView = [[UIView alloc]initWithFrame:CGRectMake(0, goosTableView.frame.size.height + goosTableView.frame.origin.y + intervalWidth, kScreenWidth, 50)];
    meunView.backgroundColor = [UIColor whiteColor];
    [commodityView addSubview:meunView];
    
    topView2 = [[TopSwitchCsqView alloc]initWithFrame:CGRectMake(30, 0, kScreenWidth - 60, 50) :@[@"图文详情",@"规格参数",@"包装售后"] categryStr:@"two"];
    topView2.topSwitchDele = self;
    [meunView addSubview:topView2];
    
    webBackScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, meunView.frame.size.height + meunView.frame.origin.y, kScreenWidth, heigth - 50)];
    webBackScroll.contentSize = CGSizeMake(width * 3, webBackScroll.frame.size.width);
    webBackScroll.showsHorizontalScrollIndicator = NO;
//    webBackScroll.delegate = self;
    webBackScroll.scrollEnabled = NO;
    [commodityView addSubview:webBackScroll];
    [self GraphicDetailWebView];
    
    detailView = [[UIView alloc]initWithFrame:CGRectMake(width, 0, width, heigth)];
    detailView.backgroundColor = [UIColor orangeColor];
    [musciScroll addSubview:detailView];
    
    evaluationView = [[UIView alloc]initWithFrame:CGRectMake(width * 2, 0, width, heigth)];
    evaluationView.backgroundColor = [UIColor lightGrayColor];
    [musciScroll addSubview:evaluationView];
}
-(UIWebView*)GraphicDetailWebView{
    if (_GraphicDetailWebView == nil) {
        _GraphicDetailWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, webBackScroll.frame.size.width,webBackScroll.frame.size.height)];
        NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:url1]];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];

            [_GraphicDetailWebView loadRequest:req];

        _GraphicDetailWebView.scalesPageToFit = YES;
//        _GraphicDetailWebView.scrollView.bounces = NO;
        [webBackScroll addSubview:_GraphicDetailWebView];
    }
    return _GraphicDetailWebView;
}
-(void)topButtonClick:(int)tag categryStr:(NSString *)categryStr{
    NSLog(@"点击按钮%d",tag + 1);
    if ([categryStr isEqualToString:@"first"]) {
        [UIView animateWithDuration:0.3 animations:^{
            [musciScroll scrollRectToVisible:CGRectMake(kScreenWidth*tag, kTopHeight, kScreenWidth, kScreenHeight - kTopHeight - bottomHeigth) animated:YES];
        } completion:^(BOOL finished) {
            
        }];
    }else  if ([categryStr isEqualToString:@"two"]) {
//        CGFloat heigth = goosTableView.frame.size.height + goosTableView.frame.origin.y + intervalWidth;
        [UIView animateWithDuration:0.3 animations:^{
            switch (tag) {
                case 0:
                {
                    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:url1]];
                    NSURLRequest *req = [NSURLRequest requestWithURL:url];
                    [_GraphicDetailWebView loadRequest:req];
                }
                    break;
                case 1:
                {
                    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:url2]];
                    NSURLRequest *req = [NSURLRequest requestWithURL:url];
                    [_GraphicDetailWebView loadRequest:req];
                }
                    break;
                case 2:
                {
                    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:url3]];
                    NSURLRequest *req = [NSURLRequest requestWithURL:url];
                    [_GraphicDetailWebView loadRequest:req];
                }
                    break;
                    
                default:
                    break;
            }

        } completion:^(BOOL finished) {
            
        }];
    }
}
#pragma mark - uitableviewDele
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else {
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 9;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == goosTableView) {
        return 5;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == goosTableView) {
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
                return 2;
                break;
            case 4:
                return 1;
                break;
            default:
                break;
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     if (tableView == goosTableView) {
         if (indexPath.section == 0) {
             return kScreenWidth *500/320;
         }else if(indexPath.section == 4){
             return 144;
         }else{
             return 52;
         }
     }
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *cellIdentifier3 = @"GoodsFourTableViewCell";
//    GoodsThreeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
//    return cell;

    if (tableView == goosTableView) {
    static NSString *cellIdentifier1 = @"GoodsOneTableViewCell";
    static NSString *cellIdentifier2 = @"GoodsTwoTableViewCell";
    static NSString *cellIdentifier3 = @"GoodsFourTableViewCell";
        if (indexPath.section == 0) {
            GoodsOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            double delayInSeconds = 0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               
                               
                           
            XYImageScrollView *imageView = [[XYImageScrollView alloc]initWithFrame:CGRectMake(0, 0, cell.backVIew.frame.size.width, cell.backVIew.frame.size.height)];
            imageView.TapActionBlock = ^(NSInteger pageIndex){
                NSLog(@"点击了第%ld",pageIndex);
            };
            imageView.aoutScroll = YES;
            imageView.time = 5;
            NSArray *imageArray = @[@"yifu.png",@"yifu.png",@"yifu.png",@"yifu.png",@"yifu.png"];
            imageView.images = imageArray;
            [cell.backVIew addSubview:imageView];
            
            });
                               
            return cell;
        }else if (indexPath.section ==4) {
            GoodsFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            GoodsTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (indexPath.section == 1) {
                if (indexPath.row == 0) {
                    cell.nameLabel.text = @"促销";
                }
                if (indexPath.row == 1) {
                    cell.nameLabel.text = @"领券";
                    cell.bodyLabel.text = @"满85减少5 满85减少5";
                    cell.bodyLabel.textColor = [UIColor redColor];
                }
            }
            if(indexPath.section == 2){
                cell.nameLabel.text = @"已选";
                cell.bodyLabel.text = @"纯棉宽T恤 + 百搭休闲裤";
            }
            if(indexPath.section == 3){
                
                if (indexPath.row == 0) {
                    cell.nameLabel.text = @"送至";
                    cell.bodyLabel.text = @"广东省 深圳市 龙岗区 大厦901";
                }
                if (indexPath.row == 1) {
                    cell.nameLabel.text = @"运费";
                    cell.bodyLabel.text = @"在线支付12元";
                }

            }
            return cell;
        }
    }
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 当前视图中有N多UIScrollView
    if (scrollView == musciScroll) {
        int  scrollViewPage  = scrollView.contentOffset.x / kScreenWidth;
        
        [topView setSelectButton:scrollViewPage];
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
