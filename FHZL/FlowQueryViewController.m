//
//  FlowQueryViewController.m
//  WeiZhong_ios
//
//  Created by haoke on 17/4/6.
//
//

#import "FlowQueryViewController.h"
#import "Header.h"
#define NAVCOLOR [UIColor colorWithRed:21/255. green:22/255. blue:24/255. alpha:1]

#define flowURL1 @"http://open.m-m10010.com/Html/Terminal/simcard_lt_new.aspx?userId=0&simNo=1064889414711&num=%@&num_type=iccid&simId=3697318&apptype=null&wechatId=null&mchId=&accessname=null&fromapp=h5"
#define flowURL2 @"http://open.m-m10010.com/Html/Terminal/searchsims.aspx?fromapp=h5&num=&num_type=iccid&onlyRealName=false"
#define flowURL3 @"http://open.m-m10010.com/Html/Terminal/searchsims.aspx?fromapp=h5&num=%@&num_type=iccid&onlyRealName=false"

@interface FlowQueryViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;

@end

@implementation FlowQueryViewController

static FlowQueryViewController *instance;

/*单例*/
+ (FlowQueryViewController *)shareInstance
{
    if (instance == nil)
    {
        instance = [[FlowQueryViewController alloc] init];
    }
    return instance;
}

+ (void)destroyInstance
{
    if (instance != nil)
    {
        instance = nil;
    }
}

-(UIWebView *)webView
{
    if (_webView == nil)
    {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kTopHeight, SCREENWIDTH, SCREENHEIGHT - kTopHeight)];
    }
    return _webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavi];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kTopHeight, SCREENWIDTH, SCREENHEIGHT - kTopHeight)];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    NSURL *url = nil;
    if (kStringIsEmpty(_macIdStr)) {
        url = [NSURL URLWithString:flowURL2];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:flowURL3,_macIdStr]];
    }
    NSLog(@"url = %@",url);
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [UIUtil showProgressHUD:nil inView:self.view];
    [self.webView loadRequest:req];
    self.webView.scalesPageToFit = YES;
}

//设置导航栏
-(void)setNavi
{
    self.title = @"流量查询";
    self.view.backgroundColor = HBackColor;

    [self addNavigationItemWithTitles
     :@[@"后退"] isLeft:NO target:self action:@selector(goBackButton) tags:@[@1000]];
//    self.navigationController.navigationBar.hidden = YES;
//    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
//    statusView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:statusView];
//    self.view.backgroundColor = [UIColor whiteColor];
//
//    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, SCREENWIDTH, 44)];
//    navView.backgroundColor = NAVCOLOR;
//    [self.view addSubview:navView];
//
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame = CGRectMake(0, 0, 58, 44);
//    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    [navView addSubview:backButton];
//
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.image  = [UIImage imageNamed:@"title_return_n.png"];
//    imageView.frame = CGRectMake(0, 0, 16, 23);
//    imageView.center = backButton.center;
//    [backButton addSubview:imageView];
//
//    UILabel *nameLable = [[UILabel alloc]initWithFrame:CGRectMake(SCREENWIDTH / 2 - 50, 0, 100, 44)];
//    nameLable.text  = @"流量查询";
//    nameLable.textAlignment = NSTextAlignmentCenter;
//    nameLable.font = [UIFont systemFontOfSize:18];
//    nameLable.textColor = [UIColor whiteColor];
//    [navView addSubview:nameLable];
//
//    //后退按钮
//    UIButton *goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    goBackButton.frame = CGRectMake(SCREENWIDTH - 50, 0, 50, 44);
//    [goBackButton setTitle:@"后退" forState:UIControlStateNormal];
//    [goBackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [goBackButton addTarget:self action:@selector(goBackButton) forControlEvents:UIControlEventTouchUpInside];
//    [navView addSubview:goBackButton];
}

-(void)showLeft
{
    [FlowQueryViewController destroyInstance];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)goBackButton
{
    if ([self.webView canGoBack])
    {
        [self.webView goBack];
    }else{
        [self showLeft];
    }
}

#pragma mark webDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (kStringIsEmpty(_macIdStr)) {
        [UIUtil showToast:@"该设备没有ICCID请手动输入" inView:self.view];
    }else{
        [UIUtil hideProgressHUD];
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

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

@end
