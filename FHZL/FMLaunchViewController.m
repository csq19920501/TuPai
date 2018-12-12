//
//  FMLaunchViewController.m
//  WeiZhong_ios
//
//  Created by haoke on 17/3/28.
//
//

#import "FMLaunchViewController.h"
//#import "YTAlertView.h"
#import "Header.h"
//#import "KTOneFingerRotationGestureRecognizer.h"
#import <CoreBluetooth/CoreBluetooth.h>
#define degreesToRadians(x) (M_PI * x / 180.0) //度转弧度
#define radiansToDegrees(x) (x * 180 / M_PI) //弧度转度
#define GrayColor [[UIColor grayColor] colorWithAlphaComponent:0.3]
#define RGBAa(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#import "newMusic.h"
#import "KDXFvoiceManager.h"
@interface FMLaunchViewController ()
{
    UIButton *button2;
    CGFloat bigin;
    UIImageView *oneView;
    UILabel *rateLabel;
    CGFloat fm;
    CGFloat fm3; //点击ok时把fm的值存在fm3中
    int fm2;
//    AppDelegate *appDele;
    NSTimer *timer;
    BOOL isCanSend; //能否发送(旋转手势的时候才为YES，YES的时候才执行每0.5秒发射频率)
    UIView *firstView;
    UIView *secondView;
    UIView *threeView;
    UIView *numberCircleView; //数字框视图
    UIButton *changeButton;
    int buttonStep; //频率步骤
    int firstInt; //第一步数值
    int twoInt; //第二步数值
    int threeInt; //第三部数值
    int fourInt; //第四部数值
}

@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat stopAngle;

@end

@implementation FMLaunchViewController

@synthesize currentAngle = _currentAngle;
@synthesize startAngle = _startAngle;
@synthesize stopAngle = _stopAngle;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isCanSend = NO;
//    appDele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    buttonStep = 1;
    fm =  87.5;
    fm3 = 87.5;
    fm2 = (int)(fm * 10);
//    MYLog(@"++++++++++++fm = %f",fm);
    
    [self setNavi];
    [self loadViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRight) name:@"duankailianjie2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRight) name:@"lianjielanya" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFMUI:) name:@"changeFMUI" object:nil];
    
    if (timer == nil)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                 target:self
                                               selector:@selector(sendFm)
                                               userInfo:nil
                                                repeats:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",fm2] forKey:@"FMpinglv"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (secondView.hidden == NO)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"secondViewIsHidden"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"secondViewIsHidden"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",fm2] forKey:@"FMpinglv"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [timer invalidate];
    timer = nil;
}

-(void)changeRight
{
    if ([KDXFvoiceManager shareInstance].isLink)
    {
        if ([USER_PLIST objectForKey:@"DIANYA"])
        {
            [button2 setTitle:[NSString stringWithFormat:@"电压:%@V",[USER_PLIST objectForKey:@"DIANYA"]] forState:UIControlStateNormal];
        }
        else
        {
            [button2 setTitle:@"电压:12V" forState:UIControlStateNormal];
        }
    }
    else
    {
        [button2 setTitle:@"电压:0V" forState:UIControlStateNormal];
    }
}

//修改频率UI
-(void)changeFMUI:(NSNotification *)userinfo
{
    NSDictionary *dict = userinfo.userInfo;
    [oneView setTransform:CGAffineTransformRotate([oneView transform], ([[dict objectForKey:@"FM"] floatValue] / 10. - fm) * M_PI * 2 / 20.6)];
    bigin = bigin + (([[dict objectForKey:@"FM"] floatValue] / 10. - fm) * M_PI * 2 / 20.6);
    fm = [[dict objectForKey:@"FM"] floatValue] / 10.;
    fm2 = (int)[[dict objectForKey:@"FM"] integerValue];
    rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2 / 10.];
}

//修改FM频率
-(void)sendFm
{
    if ([KDXFvoiceManager shareInstance].isLink)
    {
        if ([USER_PLIST objectForKey:@"DIANYA"])
        {
            [button2 setTitle:[NSString stringWithFormat:@"电压:%@V",[USER_PLIST objectForKey:@"DIANYA"]] forState:UIControlStateNormal];
        }
        else
        {
            [button2 setTitle:@"电压:12V" forState:UIControlStateNormal];
        }
    }
    if (isCanSend)
    {
        [self sendFM:[NSString stringWithFormat:@"%.d",fm2]];
        isCanSend = NO;
    }
}


-(void)sendFM:(NSString *)fm2Str
{
//    [[newMusic shareInstance]setFM:fm2Str];
}

//设置导航栏

-(void)setNavi{
        self.view.backgroundColor = HBackColor;
        self.title = @"FM发射";
        
//        [self.navigationItem setLeftBarButtonItem:({
//            UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:({
//                UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
//                [button setBackgroundImage:[UIImage imageNamed:BackImageNormal] forState:UIControlStateNormal];
//                [button setBackgroundImage:[UIImage imageNamed:BackImageP] forState:UIControlStateHighlighted];
//                [button addTarget:self action:@selector(showLeft) forControlEvents:UIControlEventTouchUpInside];
//                button.frame = CGRectMake(0, 0, 25, 25);
//                button;
//            })];
//            barButton;//APP_登录确定1_返回.png
//        })];
}
-(void)showLeft{
        [self.navigationController popViewControllerAnimated:YES];
}



//加载视图
-(void)loadViews
{
    self.view.backgroundColor = RGB(244, 244, 244);
    
    bigin = 0.;
    if (isIphone4 || isIphone5)
    {
        rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 - 70, 50 + 40, 140, 50)];
    }
    else
    {
        rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 50 + 40, SCREENWIDTH - 180, 50)];
    }
    
    rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
    rateLabel.textColor = [UIColor blackColor];
    rateLabel.font = [UIFont boldSystemFontOfSize:25];
    rateLabel.textAlignment = NSTextAlignmentCenter;
    rateLabel.backgroundColor = [UIColor whiteColor];
    rateLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:rateLabel];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(rateLabel.left - 60, rateLabel.top - 5, 60, 60);
    [leftButton addTarget:self action:@selector(dele) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:@"频率1_03"] forState:UIControlStateNormal];
    [self.view addSubview:leftButton];
    
    UIButton *rigthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rigthButton.frame = CGRectMake(rateLabel.right, rateLabel.top - 5, 60, 60);
    [rigthButton setImage:[UIImage imageNamed:@"频率1_03-2"] forState:UIControlStateNormal];
    [rigthButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rigthButton];
    
    if (!firstView)
    {
        firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 140, SCREENWIDTH, SCREENHEIGHT - 140 - 50)];
        firstView.backgroundColor = RGB(244, 244, 244);
        [self.view addSubview:firstView];
    }
    firstView.hidden = YES;
    
    UIImageView *fireView = [[UIImageView alloc] init];
    fireView.frame = CGRectMake(0, 0, SCREENWIDTH - 30, SCREENWIDTH - 30);
    if (isIphone4)
    {
        fireView.frame = CGRectMake(0, 0, (SCREENWIDTH - 30) * 4.5 / 5, (SCREENWIDTH - 30) * 4.5 / 5);
        CGPoint center = self.view.center;
        center.y = center.y - 140 + 35;
        fireView.center = center;
    }
    else
    {
        CGPoint center = self.view.center;
        center.y = center.y - 140;
        fireView.center = center;
    }
    fireView.image = [UIImage imageNamed:@"频率1_04.png"];
    [firstView addSubview:fireView];
    
    UIImageView *sixView = [[UIImageView alloc] init];
    sixView.frame = CGRectMake(0, 0, (SCREENWIDTH + 33), (SCREENWIDTH  + 33));
    if (isIphone4)
    {
        sixView.frame = CGRectMake(0, 0, (SCREENWIDTH + 33) * 4.5 / 5 , (SCREENWIDTH + 33) * 4.5 / 5);
        CGPoint center = self.view.center;
        center.y = center.y - 140 + 35;
        sixView.center = center;
    }
    else
    {
        CGPoint center = self.view.center;
        center.y = center.y - 140;
        sixView.center = center;
    }
    sixView.image = [UIImage imageNamed:@"fmlauncher_open_image"];
    [firstView addSubview:sixView];
    
    oneView = [[UIImageView alloc] init];
    oneView.frame = CGRectMake(0, 0, SCREENWIDTH - 30, SCREENWIDTH - 30);
    if (isIphone4)
    {
        oneView.frame = CGRectMake(0, 0, (SCREENWIDTH - 30) * 4.5 / 5, (SCREENWIDTH - 30) * 4.5 / 5);
        CGPoint center = self.view.center;
        center.y = center.y - 140 + 35;
        oneView.center = center;
    }
    else
    {
        CGPoint center = self.view.center;
        center.y = center.y - 140;
        oneView.center = center;
    }
    oneView.image = [UIImage imageNamed:@"频率1_3.png"];
    oneView.userInteractionEnabled = YES;
    [firstView addSubview:oneView];
    
    /* 旋转手势 */
//    KTOneFingerRotationGestureRecognizer *spin = [[KTOneFingerRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotated:)];
//    [oneView addGestureRecognizer:spin];
    
    [self setStartAngle:-0.0];
    [self setStopAngle:360.0];
    [self first];
    
//    if (!secondView)
//    {
//        secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 140, SCREENWIDTH, SCREENHEIGHT - 140 - 50)];
//        secondView.backgroundColor = RGB(244, 244, 244);
//        [self.view addSubview:secondView];
//        
//        numberCircleView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, SCREENWIDTH - 60, SCREENHEIGHT - 140 - 30 - 30)];
//        numberCircleView.backgroundColor = [UIColor whiteColor];
//        numberCircleView.layer.cornerRadius = 5;
//        numberCircleView.layer.borderColor = [UIColor grayColor].CGColor;
//        numberCircleView.layer.borderWidth = 1;
//        [secondView addSubview:numberCircleView];
//        
//        CGFloat width,heigth;
//        width = numberCircleView.width / 3;
//        heigth = numberCircleView.height / 4;
//        for (int i = 0; i < 4; i++)
//        {
//            for (int j = 0; j < 3; j++)
//            {
//                if ((i == 0 && j == 1) || (i == 0 && j == 2)) //两条竖线
//                {
//                    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(j * width - 0.5, 15, 1, heigth * 4 - 30)];
//                    lineLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
//                    [numberCircleView addSubview:lineLabel];
//                }
//                if ((j == 0 && i == 1) || (j == 0 && i == 2) || (j == 0 && i == 3)) //三条横线
//                {
//                    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, i * heigth - 0.5, width * 3 - 30, 1)];
//                    lineLabel.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
//                    [numberCircleView addSubview:lineLabel];
//                }
//                
//                UIButton *FMbutton = [UIButton buttonWithType:UIButtonTypeCustom];
//                FMbutton.frame = CGRectMake(j * width, i * heigth, width, heigth);
//                [FMbutton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//                [numberCircleView addSubview:FMbutton];
//                if (i < 3 )
//                {
//                    [FMbutton setTitle:[NSString stringWithFormat:@"%d",i * 3 + j + 1] forState:UIControlStateNormal];
//                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:40];
//                    FMbutton.tag = 1000 + i * 3 + j;
//                    [FMbutton addTarget:self action:@selector(changeFM:) forControlEvents:UIControlEventTouchUpInside];
//                }
//                if (i == 3 && j == 0)
//                {
//                    [FMbutton setTitle:[NSString stringWithFormat:@"%d",0] forState:UIControlStateNormal];
//                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:40];
//                    FMbutton.tag = 1000 + i * 3 + j;
//                    [FMbutton addTarget:self action:@selector(changeFM:) forControlEvents:UIControlEventTouchUpInside];
//                }
//                if (i == 3 && j== 1)
//                {
//                    UIImageView *buView = [[UIImageView alloc] initWithFrame:CGRectMake(FMbutton.width / 4, FMbutton.height / 2 - FMbutton.width / 4, FMbutton.width / 2, FMbutton.width / 2)];
//                    buView.image = [UIImage imageNamed:@"频率_叉.png"];
//                    [FMbutton addSubview:buView];
//                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:30];
//                    FMbutton.tag = 1010;
//                    [FMbutton addTarget:self action:@selector(backStepClick) forControlEvents:UIControlEventTouchUpInside];
//                }
//                if (i == 3 && j== 2)
//                {
//                    [FMbutton setTitle:[NSString stringWithFormat:@"%@",@"ok"] forState:UIControlStateNormal];
//                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:30];
//                    FMbutton.tag = 1011;
//                    [FMbutton addTarget:self action:@selector(okClick) forControlEvents:UIControlEventTouchUpInside];
//                }
//                if (FMbutton.selected)
//                {
//                    FMbutton.enabled = NO;
//                }
//                else
//                {
//                    FMbutton.enabled = YES;
//                }
//            }
//        }
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"secondViewIsHidden"])
//        {
//            secondView.hidden = YES;
//        }
//        else
//        {
//            secondView.hidden = NO;
//        }
//    }
    
//    secondView.hidden = YES;
    if (!threeView) {
        threeView =  secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 140 + 50 , SCREENWIDTH, SCREENHEIGHT - 140 - 50 + 20)];
        threeView.backgroundColor = RGB(244, 244, 244);
        [self.view addSubview:threeView];
        
        CGFloat width,heigth;
        width = threeView.width / 3;
        heigth = threeView.height / 5;
        for (int i = 0; i < 5; i++)
        {
            for (int j = 0; j < 3; j++)
            {
                
                UIButton *FMbutton = [UIButton buttonWithType:UIButtonTypeCustom];
                [FMbutton setBackgroundColor:[UIColor whiteColor]];
                FMbutton.layer.borderColor = [UIColor grayColor].CGColor;
                FMbutton.layer.borderWidth = 0.3;
                FMbutton.frame = CGRectMake(j * width, i * heigth, width, heigth);
                [FMbutton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [threeView addSubview:FMbutton];

                if (i < 3 )
                {
                    [FMbutton setTitle:[NSString stringWithFormat:@"%d",i * 3 + j + 1] forState:UIControlStateNormal];
                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:40];
                    FMbutton.tag = 1000 + i * 3 + j;
                    [FMbutton addTarget:self action:@selector(changeFM:) forControlEvents:UIControlEventTouchUpInside];
                }
                if (i == 3 && j == 0)
                {
                    [FMbutton setTitle:[NSString stringWithFormat:@"%d",0] forState:UIControlStateNormal];
                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:40];
                    FMbutton.tag = 1000 + i * 3 + j;
                    [FMbutton addTarget:self action:@selector(changeFM:) forControlEvents:UIControlEventTouchUpInside];
                }
                if (i == 3 && j== 1)
                {
                    [FMbutton setTitle:[NSString stringWithFormat:@"%@",@"."] forState:UIControlStateNormal];
                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:40];
                    FMbutton.tag = 1010;
                    [FMbutton addTarget:self action:@selector(changeFM:) forControlEvents:UIControlEventTouchUpInside];
                }
                if (i == 3 && j== 2)
                {
                    UIImageView *buView = [[UIImageView alloc] initWithFrame:CGRectMake(FMbutton.width / 4, FMbutton.height / 2 - FMbutton.width / 4, FMbutton.width / 2, FMbutton.width / 2)];
                    buView.image = [UIImage imageNamed:@"频率_叉"];
                    [FMbutton addSubview:buView];
                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:30];
                    FMbutton.tag = 1011;
                    [FMbutton addTarget:self action:@selector(backStepClick) forControlEvents:UIControlEventTouchUpInside];
                }
                if (i == 4 && j == 0) {
                    FMbutton.frame = CGRectMake(0, i * heigth, width*3, heigth - 20);
                    [FMbutton setTitle:[NSString stringWithFormat:@"%@",@"OK"] forState:UIControlStateNormal];
                    [FMbutton setBackgroundColor:RGBAa(30, 158, 255, 1)];
                    FMbutton.titleLabel.font = [UIFont systemFontOfSize:40];
                    FMbutton.tag = 1012;
                    [FMbutton addTarget:self action:@selector(okClick) forControlEvents:UIControlEventTouchUpInside];

                }
                if (i == 4 && (j == 1 || j == 2)) {
                    FMbutton.hidden = YES;
                }
            }
            
        }
        
        
        
    }
    
    
    
    [self firstStep]; //王工添加的代码
    
//    changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    changeButton.frame = CGRectMake(SCREENWIDTH - 60, SCREENHEIGHT - 50, 50, 40);
//    [changeButton setImage:[UIImage imageNamed:@"汽车定位1_10"] forState:UIControlStateNormal];
//    [changeButton setImage:[UIImage imageNamed:@"汽车定位1_0-02"] forState:UIControlStateHighlighted];
//    [changeButton addTarget:self action:@selector(changeView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:changeButton];
}

//记忆频率(记的是fm2，此时fm3还是87.5)
-(void)first
{
    if ([USER_PLIST objectForKey:@"FMpinglv"] != nil)
    {
        fm = [[USER_PLIST objectForKey:@"FMpinglv"] floatValue] / 10.;
        fm3 = fm;
    }
    else
    {
        fm = 87.5;
        fm3 = fm;
    }
    [oneView setTransform:CGAffineTransformRotate([oneView transform], (fm - 87.5) * M_PI * 2 / 20.6)];
    bigin = bigin + ((fm - 87.5) * M_PI * 2 / 20.6);
    fm2 = (int)[[USER_PLIST objectForKey:@"FMpinglv"] integerValue];
    if (fm2 == 0)
    {
        fm2 = 875;
    }
    rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2 / 10.];
}

//减少FM
-(void)dele
{
    if (fm > 87.5)
    {
        fm = fm - 0.1;
        if (fm < 87.549999 && fm > 87.449999)
        {
            fm = 87.5;
        }
        if (fm < 87.449999)
        {
            fm = 108.0;
        }
        [oneView setTransform:CGAffineTransformRotate([oneView transform], -2 * M_PI * 0.1 / 20.6)];
        bigin = bigin - 2 * M_PI * 0.1 / 20.6;
        
        fm2 = (int)(fm * 10);
        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2 / 10.];
//        if (APPDELEGATE.isLink && appDele.globalManager != nil)
//        {
            [self sendFM:[NSString stringWithFormat:@"%.d",fm2]];
//        }
        return;
    }
    if (fm <= 87.5)
    {
        fm = 108.0;
        [oneView setTransform:CGAffineTransformRotate([oneView transform], -2 * M_PI * 0.1 / 20.6)];
        bigin = bigin - 2 * M_PI * 0.1 / 20.6;
        fm2 = (int)(fm * 10);
        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2 / 10.];
//        if (APPDELEGATE.isLink && appDele.globalManager != nil)
//        {
            [self sendFM:[NSString stringWithFormat:@"%.d",fm2]];
//        }
    }
}

//增加FM
-(void)add
{
    if (fm < 108.0)
    {
        fm = fm + 0.1;
        if (fm > 107.949999 && fm < 108.499999)
        {
            fm = 108.0;
        }
        if (fm > 108.499999)
        {
            fm = 87.5;
        }
        [oneView setTransform:CGAffineTransformRotate([oneView transform], 2 * M_PI * 0.1 / 20.6)];
        bigin = bigin + 2 * M_PI * 0.1 / 20.6;
        fm2 = (int)(fm * 10);
        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2 / 10.];
//        if (APPDELEGATE.isLink && appDele.globalManager != nil)
//        {
            [self sendFM:[NSString stringWithFormat:@"%.d",fm2]];
//        }
        return;
    }
    if (fm >= 108.0)
    {
        fm = 87.5;
        [oneView setTransform:CGAffineTransformRotate([oneView transform], 2*M_PI * 0.1/20.6)];
        bigin = bigin + 2 * M_PI * 0.1/20.6;
        fm2 = (int)(fm * 10);
        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2/10.];
//        if (APPDELEGATE.isLink && appDele.globalManager != nil)
//        {
            [self sendFM:[NSString stringWithFormat:@"%.d",fm2]];
//        }
    }
}

//旋转手势
//- (void)rotated:(KTOneFingerRotationGestureRecognizer *)recognizer
//{
//    CGFloat degrees = radiansToDegrees([recognizer rotation]);
//    CGFloat currentAngle = [self currentAngle] + degrees;
//    CGFloat relativeAngle = fmodf(currentAngle, 360.0); //Converts to angle between 0 and 360 degrees. //两数整除后的余数
//    
//    BOOL shouldRotate = NO;
//    if ([self startAngle] <= [self stopAngle])
//    {
//        shouldRotate = (relativeAngle >= [self startAngle] && relativeAngle <= [self stopAngle]);
//    }
//    else if ([self startAngle] > [self stopAngle])
//    {
//        shouldRotate = (relativeAngle >= [self startAngle] || relativeAngle <= [self stopAngle]);
//    }
//    shouldRotate = YES;
//    if (shouldRotate)
//    {
//        [self setCurrentAngle:currentAngle];
//        UIView *view = [recognizer view];
//        [view setTransform:CGAffineTransformRotate([view transform], [recognizer rotation])];
//        bigin = bigin + [recognizer rotation];
//        if (bigin >= M_PI * 2)
//        {
//            bigin = bigin - M_PI * 2;
//        }
//        if (bigin <=  -M_PI * 2)
//        {
//            bigin = bigin + M_PI * 2;
//        }
//        
//        if (bigin >= 0)
//        {
//            CGFloat a = bigin * 20.6 / (M_PI * 2);
//            fm = a + 87.5;
//            fm2 = (int)(fm * 10);
//            rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2 / 10.];
//        }
//        if (bigin < 0) {
//            CGFloat a = (M_PI * 2 + bigin) * 20.6 / (M_PI * 2);
//            fm = a + 87.5;
//            fm2 = (int)(fm * 10);
//            rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm2 / 10.];
//        }
//    }
//    MYLog(@"fm %f",fm);
//    isCanSend = YES;
//}

-(void)changeView
{
    if (!changeButton.selected)
    {
        secondView.hidden = NO;
    }
    else
    {
        secondView.hidden = YES;
    }
    changeButton.selected = !changeButton.selected;
}

//点击键盘
-(void)changeFM:(UIButton *)but
{
    if (buttonStep == 1)
    {
        NSString *str = but.titleLabel.text;
        fm = [str floatValue];
        firstInt = [str intValue];
        rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
        buttonStep++;
        [self firstStep];
        return;
    }
    if (buttonStep == 2)
    {
        NSString *str = but.titleLabel.text;
        twoInt = [str intValue];
        fm = firstInt * 10 + twoInt;
        rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
        buttonStep++;
        [self firstStep];
        return;
    }
    
    if (buttonStep == 3)
    {
        NSString *str = but.titleLabel.text;
        
        if (firstInt == 1)
        {
            threeInt = [str intValue];
            fm = firstInt * 100 + twoInt * 10 + threeInt;
            rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            
        }
        else
        {
            fm = firstInt * 10 + twoInt * 1;// + threeInt / 10.;
            rateLabel.text = [NSString stringWithFormat:@"%d.Mhz",(int)fm];
        }
        buttonStep++;
        [self firstStep];
        return;

    }
    if (buttonStep == 4)
    {
        NSString *str = but.titleLabel.text;
        
        if (firstInt == 1)
        {
            fm = firstInt * 100 + twoInt * 10 + threeInt;
            rateLabel.text = [NSString stringWithFormat:@"%d.Mhz",(int)fm];
            
        }
        else
        {
            threeInt = [str intValue];
            fm = firstInt * 10 + twoInt * 1 + threeInt / 10.;
            rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
        }
        buttonStep++;
        [self firstStep];
        return;
    }

//    if (buttonStep == 3)
//    {
//        NSString *str = but.titleLabel.text;
//        threeInt = [str intValue];
//        if (firstInt == 1)
//        {
//            fm = firstInt * 100 + twoInt * 10 + threeInt;
//            rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
//            
//        }
//        else
//        {
//            fm = firstInt * 10 + twoInt * 1 + threeInt / 10.;
//            rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
//        }
//        buttonStep++;
//        [self firstStep];
//        return;
//    }
    if (buttonStep == 5)
    {
        NSString *str = but.titleLabel.text;
        fourInt  = [str intValue];
        if (firstInt == 1)
        {
            fm = firstInt * 100.0 + twoInt * 10 + threeInt + fourInt / 10.;
        }
        else
        {
            
        }
        buttonStep++;
        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
        [self firstStep];
        return;
    }
}

//点击ok
-(void)okClick
{
    buttonStep = 1;
    firstInt = 0;
    twoInt = 0;
    threeInt = 0;
    fourInt = 0;
    [self firstStep];
    fm3 = fm;
    fm2 = (int)(fm * 10);

//    if (APPDELEGATE.isLink && appDele.globalManager != nil)
//    {
        [self sendFM:[NSString stringWithFormat:@"%.d",fm2]];
//    }
}

//点击回退
-(void)backStepClick
{
    NSLog(@" buttonStep = %d  firstInt = %d",buttonStep,firstInt);
    if (buttonStep > 1)
    {
        if (firstInt == 1) {
            if (buttonStep == 6)
            {
                fourInt = 0;
                fm = firstInt * 100 + twoInt * 10 + threeInt;
                rateLabel.text = [NSString stringWithFormat:@"%d.Mhz",(int)fm];
            }
            if (buttonStep == 5)
            {
                fourInt = 0;
                fm = firstInt * 100 + twoInt * 10 + threeInt;
                rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            }
            if (buttonStep == 4)
            {
                threeInt = 0;
                fm = firstInt * 10 + twoInt * 1;
                rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            }
            if (buttonStep == 3)
            {
                twoInt = 0;
                fm = firstInt;
                rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            }
            if (buttonStep == 2)
            {
                firstInt = 0;
                fm = firstInt;
                rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            }
            buttonStep-- ;
            [self firstStep];
        }else{
            if (buttonStep == 5)
            {
                fourInt = 0;
                fm = firstInt * 10 + twoInt * 1;
                rateLabel.text = [NSString stringWithFormat:@"%d.Mhz",(int)fm];
            }
            if (buttonStep == 4)
            {
                threeInt = 0;
                fm = firstInt * 10 + twoInt * 1;
                rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            }
            if (buttonStep == 3)
            {
                twoInt = 0;
                fm = firstInt;
                rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            }
            if (buttonStep == 2)
            {
                firstInt = 0;
                fm = firstInt;
                rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
            }
            
            buttonStep-- ;
            [self firstStep];
        }
    }
    if (buttonStep == 1)
    {
        fm = fm3;
        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
        [self firstStep];
    }
}

//处理键盘点击事件
-(void)firstStep
{
    if (buttonStep == 1)
    {
        for (UIButton *button in threeView.subviews)
        {
            if ([button isKindOfClass:[UIButton class]])
            {
                [button setTitleColor:GrayColor forState:UIControlStateNormal];
                button.enabled = NO;
            }
            if (button.tag == 1000 || button.tag == 1007 || button.tag == 1008)  //点击ok后1、8、9可以点
            {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.enabled = YES;
            }
        }
    }
    if (buttonStep == 2)
    {
        if (firstInt == 1)
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
                if (button.tag == 1009) //如果第一次点1，则第二次0可以点
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
            }
        }
        if (firstInt == 8)
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
                if (button.tag == 1006 || button.tag == 1007||button.tag == 1008) //如果第一次点8，则第二次7、8、9可以点
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
            }
        }
        if (firstInt == 9)
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
                if (button.tag == 1012 || button.tag == 1010 ) //如果第一次点9，则第二次ok不能点
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
            }
        }
    }
    if (buttonStep == 3)
    {
        if (firstInt == 1 && twoInt == 0)
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
                if (button.tag == 1012  || button.tag == 1008 || button.tag == 1010) //如果第一次点1，第二次点0，则第三次9和ok不能点
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
            }
        }
        if (firstInt == 8)
        {
           
                for (UIButton *button in threeView.subviews)
                {
                    if ([button isKindOfClass:[UIButton class]])
                    {
                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
                        button.enabled = NO;
                    }
                    if (button.tag == 1010) //如果第一次点8，第二次点7，则第三次5、6、7、8、9可以点
                    {
                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        button.enabled = YES;
                    }
                }
        }
        if (firstInt == 9)
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
                if (button.tag == 1010) //如果第一次点8，第二次点7，则第三次5、6、7、8、9可以点
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
            }
        }

    }
    if (buttonStep == 4)
    {
        if (firstInt == 1 && twoInt == 0)
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
                if (button.tag == 1010) //如果第一次点8，第二次点7，则第三次5、6、7、8、9可以点
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
            }
        }
        if (firstInt == 8)
        {
            if (twoInt == 7)
            {
                for (UIButton *button in threeView.subviews)
                {
                    if ([button isKindOfClass:[UIButton class]])
                    {
                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
                        button.enabled = NO;
                    }
                    if (button.tag == 1004 || button.tag == 1007||button.tag == 1008||button.tag == 1005||button.tag == 1006) //如果第一次点8，第二次点7，则第三次5、6、7、8、9可以点
                    {
                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        button.enabled = YES;
                    }
                }
            }
            if (twoInt == 8 || twoInt == 9)
            {
                for (UIButton *button in threeView.subviews)
                {
                    if ([button isKindOfClass:[UIButton class]])
                    {
                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        button.enabled = YES;
                    }
                    if (button.tag == 1012 || button.tag == 1010) //如果第一次点8，第二次点8或者9，则第三次ok不能点
                    {
                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
                        button.enabled = NO;
                    }
                }
            }
        }
        if (firstInt == 9)
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
                if (button.tag == 1012 || button.tag == 1010) //如果第一次点9，第二次点0 - 9任意，则第三次ok不能点
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
            }
        }
    }
    if (buttonStep == 5)
    {
        if (firstInt == 1)
        {
            if (threeInt == 8)
            {
                for (UIButton *button in threeView.subviews)
                {
                    if ([button isKindOfClass:[UIButton class]])
                    {
                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
                        button.enabled = NO;
                    }
                    if (button.tag == 1009) //如果第一次点1，第三次点8，则第四次0可以点
                    {
                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        button.enabled = YES;
                    }
                }
            }
            else
            {
                for (UIButton *button in threeView.subviews)
                {
                    if ([button isKindOfClass:[UIButton class]])
                    {
                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        button.enabled = YES;
                    }
                    if (button.tag == 1012 || button.tag == 1010) //如果第一次点1，第三次不点8，则第四次ok不能点
                    {
                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
                        button.enabled = NO;
                    }
                }
            }
        }
        else
        {
            for (UIButton *button in threeView.subviews)
            {
                if ([button isKindOfClass:[UIButton class]])
                {
                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
                    button.enabled = NO;
                }
                if (button.tag == 1012) //如果第一次不点1，则第四次ok可以点
                {
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    button.enabled = YES;
                }
            }
        }
    }
    if (buttonStep == 6)
    {
        for (UIButton *button in threeView.subviews)
        {
            if ([button isKindOfClass:[UIButton class]])
            {
                [button setTitleColor:GrayColor forState:UIControlStateNormal];
                button.enabled = NO;
            }
            if (button.tag == 1012) //如果第一次点1，则第五次ok可以点
            {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.enabled = YES;
            }
        }
    }
    UIButton *backbutton = (UIButton *)[threeView viewWithTag:1011];
    [backbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backbutton.enabled = YES;
}
//注释掉的是第二种secredView的按键响应方法  不应该删除
//
////点击键盘
//-(void)changeFM:(UIButton *)but
//{
//    if (buttonStep == 1)
//    {
//        NSString *str = but.titleLabel.text;
//        fm = [str floatValue];
//        firstInt = [str intValue];
//        rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
//        buttonStep++;
//        [self firstStep];
//        return;
//    }
//    if (buttonStep == 2)
//    {
//        NSString *str = but.titleLabel.text;
//        twoInt = [str intValue];
//        fm = firstInt * 10 + twoInt;
//        rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
//        buttonStep++;
//        [self firstStep];
//        return;
//    }
//    if (buttonStep == 3)
//    {
//        NSString *str = but.titleLabel.text;
//        threeInt = [str intValue];
//        if (firstInt == 1)
//        {
//            fm = firstInt * 100 + twoInt * 10 + threeInt;
//            rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
//            
//        }
//        else
//        {
//            fm = firstInt * 10 + twoInt * 1 + threeInt / 10.;
//            rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
//        }
//        buttonStep++;
//        [self firstStep];
//        return;
//    }
//    if (buttonStep == 4)
//    {
//        NSString *str = but.titleLabel.text;
//        fourInt  = [str intValue];
//        if (firstInt == 1)
//        {
//            fm = firstInt * 100.0 + twoInt * 10 + threeInt + fourInt / 10.;
//        }
//        else
//        {
//            
//        }
//        buttonStep++;
//        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
//        [self firstStep];
//        return;
//    }
//}
//
////点击ok
//-(void)okClick
//{
//    buttonStep = 1;
//    firstInt = 0;
//    twoInt = 0;
//    threeInt = 0;
//    fourInt = 0;
//    [self firstStep];
//    fm3 = fm;
//    fm2 = (int)(fm * 10);
//    
//    //    if (APPDELEGATE.isLink && appDele.globalManager != nil)
//    //    {
//    [self sendFM:[NSString stringWithFormat:@"%.d",fm2]];
//    //    }
//}
//
////点击回退
//-(void)backStepClick
//{
//    if (buttonStep > 1)
//    {
//        if (buttonStep == 5)
//        {
//            fourInt = 0;
//            fm = firstInt * 100 + twoInt * 10 + threeInt;
//        }
//        if (buttonStep == 4)
//        {
//            threeInt = 0;
//            fm = firstInt * 10 + twoInt * 1;
//        }
//        if (buttonStep == 3)
//        {
//            twoInt = 0;
//            fm = firstInt;
//        }
//        if (buttonStep == 2)
//        {
//            firstInt = 0;
//            fm = firstInt;
//        }
//        rateLabel.text = [NSString stringWithFormat:@"%.0fMhz",fm];
//        buttonStep-- ;
//        [self firstStep];
//    }
//    if (buttonStep == 1)
//    {
//        fm = fm3;
//        rateLabel.text = [NSString stringWithFormat:@"%.1fMhz",fm];
//        [self firstStep];
//    }
//}
////处理键盘点击事件
//-(void)firstStep
//{
//    if (buttonStep == 1)
//    {
//        for (UIButton *button in numberCircleView.subviews)
//        {
//            if ([button isKindOfClass:[UIButton class]])
//            {
//                [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                button.enabled = NO;
//            }
//            if (button.tag == 1000 || button.tag == 1007 || button.tag == 1008)  //点击ok后1、8、9可以点
//            {
//                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                button.enabled = YES;
//            }
//        }
//    }
//    if (buttonStep == 2)
//    {
//        if (firstInt == 1)
//        {
//            for (UIButton *button in numberCircleView.subviews)
//            {
//                if ([button isKindOfClass:[UIButton class]])
//                {
//                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                    button.enabled = NO;
//                }
//                if (button.tag == 1009) //如果第一次点1，则第二次0可以点
//                {
//                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    button.enabled = YES;
//                }
//            }
//        }
//        if (firstInt == 8)
//        {
//            for (UIButton *button in numberCircleView.subviews)
//            {
//                if ([button isKindOfClass:[UIButton class]])
//                {
//                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                    button.enabled = NO;
//                }
//                if (button.tag == 1006 || button.tag == 1007||button.tag == 1008) //如果第一次点8，则第二次7、8、9可以点
//                {
//                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    button.enabled = YES;
//                }
//            }
//        }
//        if (firstInt == 9)
//        {
//            for (UIButton *button in numberCircleView.subviews)
//            {
//                if ([button isKindOfClass:[UIButton class]])
//                {
//                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    button.enabled = YES;
//                }
//                if (button.tag == 1011 ) //如果第一次点9，则第二次ok不能点
//                {
//                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                    button.enabled = NO;
//                }
//            }
//        }
//    }
//    if (buttonStep == 3)
//    {
//        if (firstInt == 1 && twoInt == 0)
//        {
//            for (UIButton *button in numberCircleView.subviews)
//            {
//                if ([button isKindOfClass:[UIButton class]])
//                {
//                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    button.enabled = YES;
//                }
//                if (button.tag == 1011 || button.tag == 1008) //如果第一次点1，第二次点0，则第三次9和ok不能点
//                {
//                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                    button.enabled = NO;
//                }
//            }
//        }
//        if (firstInt == 8)
//        {
//            if (twoInt == 7)
//            {
//                for (UIButton *button in numberCircleView.subviews)
//                {
//                    if ([button isKindOfClass:[UIButton class]])
//                    {
//                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                        button.enabled = NO;
//                    }
//                    if (button.tag == 1004 || button.tag == 1007||button.tag == 1008||button.tag == 1005||button.tag == 1006) //如果第一次点8，第二次点7，则第三次5、6、7、8、9可以点
//                    {
//                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        button.enabled = YES;
//                    }
//                }
//            }
//            if (twoInt == 8 || twoInt == 9)
//            {
//                for (UIButton *button in numberCircleView.subviews)
//                {
//                    if ([button isKindOfClass:[UIButton class]])
//                    {
//                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        button.enabled = YES;
//                    }
//                    if (button.tag == 1011) //如果第一次点8，第二次点8或者9，则第三次ok不能点
//                    {
//                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                        button.enabled = NO;
//                    }
//                }
//            }
//        }
//        if (firstInt == 9)
//        {
//            for (UIButton *button in numberCircleView.subviews)
//            {
//                if ([button isKindOfClass:[UIButton class]])
//                {
//                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    button.enabled = YES;
//                }
//                if (button.tag == 1011) //如果第一次点9，第二次点0 - 9任意，则第三次ok不能点
//                {
//                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                    button.enabled = NO;
//                }
//            }
//        }
//    }
//    if (buttonStep == 4)
//    {
//        if (firstInt == 1)
//        {
//            if (threeInt == 8)
//            {
//                for (UIButton *button in numberCircleView.subviews)
//                {
//                    if ([button isKindOfClass:[UIButton class]])
//                    {
//                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                        button.enabled = NO;
//                    }
//                    if (button.tag == 1009) //如果第一次点1，第三次点8，则第四次0可以点
//                    {
//                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        button.enabled = YES;
//                    }
//                }
//            }
//            else
//            {
//                for (UIButton *button in numberCircleView.subviews)
//                {
//                    if ([button isKindOfClass:[UIButton class]])
//                    {
//                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                        button.enabled = YES;
//                    }
//                    if (button.tag == 1011) //如果第一次点1，第三次不点8，则第四次ok不能点
//                    {
//                        [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                        button.enabled = NO;
//                    }
//                }
//            }
//        }
//        else
//        {
//            for (UIButton *button in numberCircleView.subviews)
//            {
//                if ([button isKindOfClass:[UIButton class]])
//                {
//                    [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                    button.enabled = NO;
//                }
//                if (button.tag == 1011) //如果第一次不点1，则第四次ok可以点
//                {
//                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                    button.enabled = YES;
//                }
//            }
//        }
//    }
//    if (buttonStep == 5)
//    {
//        for (UIButton *button in numberCircleView.subviews)
//        {
//            if ([button isKindOfClass:[UIButton class]])
//            {
//                [button setTitleColor:GrayColor forState:UIControlStateNormal];
//                button.enabled = NO;
//            }
//            if (button.tag == 1011) //如果第一次点1，则第五次ok可以点
//            {
//                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//                button.enabled = YES;
//            }
//        }
//    }
//    UIButton *button = (UIButton *)[self.view viewWithTag:1010];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    button.enabled = YES;
//}

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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
