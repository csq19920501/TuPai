//
//  NewMusicVC.m
//  WeiZhong_ios
//
//  Created by hk on 17/9/14.
//
//

#import "NewMusicVC.h"
#import "newMusicTableViewCell.h"
#import "newMusic.h"
#import "NewMusicPlayViewController.h"
#import "UITableView+WFEmpty.h"
#import "Masonry.h"
#import "Header.h"
#import "CALayer+PauseAimate.h"
@interface NewMusicVC ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,NewMusicDelegate>
{
//    UIScrollView *musciScroll;
    UITableView *localTableview;
    UITableView *UhoustTableview;
    UITableView *netTableview;
    NSTimer *MusicTimer;
    UIView *navView;
    int scrollViewPage;
    
    BOOL _isReload;
    BOOL _isAdd;
}
@property (weak, nonatomic) IBOutlet UISlider *MusicSlider;

@property (weak, nonatomic) IBOutlet UIView *scrollBackView;
@property (weak, nonatomic) IBOutlet UIScrollView *musciScroll;

@property (weak, nonatomic) IBOutlet UIImageView *musicIcon;
@property (weak, nonatomic) IBOutlet UILabel *musicName;
@property (weak, nonatomic) IBOutlet UILabel *musicSinger;
@property (weak, nonatomic) IBOutlet UIButton *musicPlayOrPause;
@property (weak, nonatomic) IBOutlet UIButton *musicNext;
@property (weak, nonatomic) IBOutlet UIProgressView *musicProgress;
@property (weak, nonatomic) IBOutlet UIView *musciManagerView;
@end

@implementation NewMusicVC
- (IBAction)musicPlayOrPause:(id)sender {
    [[newMusic shareInstance]musicPlayaAndPause];
}
- (IBAction)musicNext:(id)sender {
    [[newMusic shareInstance]musicNext];
    [self addIconViewAnimate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:@"applicationDidBecomeActive" object:nil];
    
    [self setNai];
    [self setViews];
    
    if ([newMusic shareInstance].UhoustMusicArray.count == 0) {
        [UhoustTableview addEmptyViewHaveButtonWithImageName:@"" title:@"未连接设备或者U盘没有歌曲"];
        UhoustTableview.emptyView.hidden = NO;
    }else{
        
        UhoustTableview.emptyView.hidden = YES;
    }
    if ([newMusic shareInstance].localMusicArray.count == 0) {
        [localTableview addEmptyViewWithImageName:@"" title:@"本地暂时没有歌曲"];
        
        localTableview.emptyView.hidden = NO;
    }else{
        localTableview.emptyView.hidden = YES;
    }
    if ([newMusic shareInstance].netMusicArray.count == 0) {
        [netTableview addEmptyViewWithImageName:@"" title:@"暂无网络歌曲"];
       
        netTableview.emptyView.hidden = NO;
    }else{
        netTableview.emptyView.hidden = YES;
    }
    
    
    MusicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(changeMusicState)
                                                userInfo:nil
                                                 repeats:YES];
    [newMusic shareInstance].NewMusicDele = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toMusicVC)];
    [_musciManagerView addGestureRecognizer:tap];
    if (_isNet) {
        UIButton *bu = (UIButton *)[self.view viewWithTag:2 + 100];
        [self changeM:bu];
        if([newMusic shareInstance].netMusicArray.count != 0){
            [self tableView:netTableview didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }
    [self.MusicSlider setThumbImage:[UIImage imageNamed:@"底部音乐显示底盘_进度条滑块"] forState:UIControlStateNormal];
    
    _musicIcon.layer.cornerRadius = 32;
    _musicIcon.layer.borderColor = [[UIColor whiteColor]colorWithAlphaComponent:0.7].CGColor;
    _musicIcon.layer.borderWidth = 1;
    _musicIcon.layer.masksToBounds = YES;
    
}

-(void)applicationDidBecomeActive{
    
    double delayInSeconds = 10.f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       if ([newMusic shareInstance].UhoustMusicArray.count == 0) {
                           [UhoustTableview addEmptyViewHaveButtonWithImageName:@"" title:@"未连接设备或者U盘没有歌曲"];
                           UhoustTableview.emptyView.hidden = NO;
                       }else{
                           UhoustTableview.emptyView.hidden = YES;
                       }
                   });
}


-(void)toMusicVC{
    NSLog(@"跳转音乐页面");
    [self.navigationController pushViewController:[[NewMusicPlayViewController alloc]init] animated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeView];
        [self.view bringSubviewToFront:_musicIcon];
        [self changeMusicState];
    });
    _isReload = NO;
    _isAdd = NO;
}
//跳转tableVIew并选中效果
-(void)changeView{
    [UIView animateWithDuration:0.3 animations:^{
        [_musciScroll scrollRectToVisible:CGRectMake(SCREENWIDTH*([newMusic shareInstance].MusicMode -1), 0, SCREENWIDTH, SCREENHEIGHT - 124 - 54) animated:YES];
        scrollViewPage = [newMusic shareInstance].MusicMode -1;
        
        for (UIButton *button in navView.subviews) {
            button.selected = NO;
        }
        UIButton *bu = (UIButton *)[self.view viewWithTag:scrollViewPage + 100];
        bu.selected = YES;
    } completion:^(BOOL finished) {
        
    }];

    switch ([newMusic shareInstance].musicState) {
        case localPlay:
        case localPause:
        {
            if ([newMusic shareInstance].localMusicArray.count == 0 || [newMusic shareInstance].musicSelectNum > [newMusic shareInstance].localMusicArray.count - 1 ) {
                return;
            }
            [localTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case netPlay:
        case netPause:
        {
            if ([newMusic shareInstance].netMusicArray.count == 0 || [newMusic shareInstance].musicSelectNum > [newMusic shareInstance].netMusicArray.count - 1) {
                return;
            }
            [netTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case uPlay:
        case uPause:
        {
            if ([newMusic shareInstance].UhoustMusicArray.count == 0 || [newMusic shareInstance].UhoustMusicArray.count < [newMusic shareInstance].musicSelectNum + 1) {
                return;
            }
            if ([newMusic shareInstance].UhoustMusicArray.count != [newMusic shareInstance].uSongAllNum && [newMusic shareInstance].UhoustMusicArray.count >= [newMusic shareInstance].musicSelectNum) {
                if ([newMusic shareInstance].uSongChange) {
                    [UhoustTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                    [newMusic shareInstance].uSongChange = NO;
                }else{
                    [UhoustTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }else if([newMusic shareInstance].UhoustMusicArray.count == [newMusic shareInstance].uSongAllNum){
                [UhoustTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            }
            
            
        }
            break;
        default:
        {
            
        }
            break;
    }

}
//只有选中效果
-(void)changeViewNotChangeTable{
    switch ([newMusic shareInstance].musicState) {
        case localPlay:
        case localPause:
        {
            if ([newMusic shareInstance].localMusicArray.count == 0 || [newMusic shareInstance].musicSelectNum > [newMusic shareInstance].localMusicArray.count - 1 ) {
                return;
            }
            [localTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case netPlay:
        case netPause:
        {
            if ([newMusic shareInstance].netMusicArray.count == 0 || [newMusic shareInstance].musicSelectNum > [newMusic shareInstance].netMusicArray.count - 1) {
                return;
            }
            [netTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case uPlay:
        case uPause:
        {
            if ([newMusic shareInstance].UhoustMusicArray.count == 0 || [newMusic shareInstance].UhoustMusicArray.count < [newMusic shareInstance].musicSelectNum + 1) {
                return;
            }
            if ([newMusic shareInstance].UhoustMusicArray.count != [newMusic shareInstance].uSongAllNum && [newMusic shareInstance].UhoustMusicArray.count >= [newMusic shareInstance].musicSelectNum) {
                if ([newMusic shareInstance].uSongChange) {
                    [UhoustTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                    [newMusic shareInstance].uSongChange = NO;
                }else{
                    [UhoustTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }else if([newMusic shareInstance].UhoustMusicArray.count == [newMusic shareInstance].uSongAllNum){
                [UhoustTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            }
            
            
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (void)addIconViewAnimate
{
    //    [_MusicImageView.layer removeAllAnimations];
    // 1.创建基本动画
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    // 2.给动画设置一些属性
    rotationAnim.fromValue = @(0);
    rotationAnim.toValue = @(M_PI * 2);
    rotationAnim.repeatCount = NSIntegerMax;
    rotationAnim.autoreverses = NO;
    rotationAnim.duration = 35;
    // 3.将动画添加到iconView的layer上面
    [_musicIcon.layer addAnimation:rotationAnim forKey:nil];
    [_musicIcon.layer resumeAnimateCSQ];
    _isAdd = YES;
}



-(void)changeMusicState{
    _musicIcon.image  = [newMusic shareInstance].playingMusic.m_musicCover;
    _musicName.text = [newMusic shareInstance].playingMusic.m_musicName;
//    _musicProgress.progress = [newMusic shareInstance].musicProgressFloat;
    _MusicSlider.value = [newMusic shareInstance].musicProgressFloat;
    
    if ([[newMusic shareInstance].nowPlayTime isEqualToString:@"00:00"]) {
        if ([newMusic shareInstance].MusicMode != MODELOCAL) {
            _MusicSlider.enabled = NO;
        }
    }else{
        if ([newMusic shareInstance].MusicMode == MODEUHOST) {
            _MusicSlider.enabled = NO;
        }else{
            _MusicSlider.enabled = YES;
        }
    }
    
    
    switch ([newMusic shareInstance].musicState) {
        case uPlay:
        case localPlay:
        case netPlay:
        {
            
            _musicPlayOrPause.selected = YES;
            NSLog(@"new  _musicPlayOrPause.selected = YES");
            if (!_isReload) {
                if (_isAdd) {
                    
                    [_musicIcon.layer resumeAnimate];
                    NSLog(@"动画处理resumeAnimate");
                }else{
                    
                    [self addIconViewAnimate];
                    NSLog(@"动画处理addIconViewAnimate");
                }
                _isReload = YES;
            }

        }
            break;
            
        default:
        {
            
            _musicPlayOrPause.selected = NO;
            NSLog(@"new  _musicPlayOrPause.selected = NO");
            if (_isReload) {
                [_musicIcon.layer pauseAnimate];
                _isReload = NO;
                NSLog(@"动画处理pauseAnimate");
            }
        }
            break;
    }
    NSString *musicStateStr = nil;
    switch ([newMusic shareInstance].musicState) {
        case localPlay:
        case localPause:
        {
            musicStateStr = @"本地-";
            
        }
            break;
        case netPause:
        case netPlay:
        {
            musicStateStr = @"网络-";
        }
            break;
        case uPlay:
        case uPause:
        {
            musicStateStr = @"USB-";
        }
            break;
        default:
            break;
    }
    _musicSinger.text = [NSString stringWithFormat:@"%@%@",musicStateStr,[newMusic shareInstance].playingMusic.m_singerName];
    if (IOS_VERSION >= 10.0) {
        _musicName.adjustsFontForContentSizeCategory = YES;
        _musicSinger.adjustsFontForContentSizeCategory = YES;
    }
    
}
-(void)changeSelectMusic:(NSInteger)selectMusicNum{
    switch ([newMusic shareInstance].musicState) {
        case localPlay:
        case localPause:
        {
           [localTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectMusicNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
            break;
        case netPlay:
        case netPause:
        {
            [netTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectMusicNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
            break;
        case uPlay:
        case uPause:
        {
            [UhoustTableview reloadData];
           [UhoustTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectMusicNum inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
            break;
        default:
        {
            
        }
            break;
    }
}
-(void)deselectTable{
    switch ([newMusic shareInstance].MusicMode) {
        case MODELOCAL:
        {
            
            [localTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
        }
            break;
        case MODENET:
        {
            
            [netTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
        }
            break;
        default:
            break;
    }
    [localTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
    NSLog(@"[newMusic shareInstance].musicSelectNum = %d",[newMusic shareInstance].musicSelectNum);
    
    [netTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
}
-(void)tableViewReloadData:(NSInteger)tableviewMode{
    switch (tableviewMode) {
        case MODEUHOST_UhostLoad:
        {
            if ([newMusic shareInstance].UhoustMusicArray.count == 0) {
                [UhoustTableview addEmptyViewWithImageName:@"" title:@"正在加载U盘歌曲..."];

                UhoustTableview.emptyView.hidden = NO;
                

            }else{
                UhoustTableview.emptyView.hidden = YES;
                
            }
            [UhoustTableview reloadData];
            
            [self changeView];
            
        }
            break;
        case MODEUHOST:
        {
            if ([newMusic shareInstance].UhoustMusicArray.count == 0) {
                [UhoustTableview addEmptyViewHaveButtonWithImageName:@"" title:@"未连接设备或者U盘没有歌曲"];
            
                UhoustTableview.emptyView.hidden = NO;
                

            }else{
                UhoustTableview.emptyView.hidden = YES;
            }
            [UhoustTableview reloadData];
            [self changeView];
        }
            break;
        case MODEUHOST_NotGoto:
        {
            if ([newMusic shareInstance].UhoustMusicArray.count == 0) {
                [UhoustTableview addEmptyViewHaveButtonWithImageName:@"" title:@"未连接设备或者U盘没有歌曲"];
                UhoustTableview.emptyView.hidden = NO;
               

            }else{
                UhoustTableview.emptyView.hidden = YES;
            }
            [UhoustTableview reloadData];            
            [self changeViewNotChangeTable];
        }
            break;
        case MODELOCAL:
        {
            if ([newMusic shareInstance].localMusicArray.count == 0) {
                [localTableview addEmptyViewWithImageName:@"" title:@"本地暂时没有歌曲"];
                localTableview.emptyView.hidden = NO;
              
            }else{
                localTableview.emptyView.hidden = YES;
            }
            [localTableview reloadData];
            [self changeView];
        }
            break;
        case MODENET:
        {
            if ([newMusic shareInstance].netMusicArray.count == 0) {
                [netTableview addEmptyViewWithImageName:@"" title:@"暂没有网络歌曲"];
              
                netTableview.emptyView.hidden = NO;
            }else{
                netTableview.emptyView.hidden = YES;
            }
            [netTableview reloadData];
            [self changeView];
        }
            break;
        default:
            break;
    }
    
}

-(void)setNai{
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = HBackColor;
    self.title = @"音乐列表";
    
//    [self.navigationItem setLeftBarButtonItem:({
//        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:({
//            UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
//            [button setBackgroundImage:[UIImage imageNamed:BackImageNormal] forState:UIControlStateNormal];
//            [button setBackgroundImage:[UIImage imageNamed:BackImageP] forState:UIControlStateHighlighted];
//            [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//            button.frame = CGRectMake(0, 0, 25, 25);
//            button;
//        })];
//        barButton;//APP_登录确定1_返回.png
//    })];
//    [self.navigationItem setRightBarButtonItem:({
//        UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:({
//            UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
//            [button setBackgroundImage:[UIImage imageNamed:@"MAIN2_位置_状态栏_轨迹_N.png"] forState:UIControlStateNormal];
//            [button setBackgroundImage:[UIImage imageNamed:@"MAIN2_位置_状态栏_轨迹_N.png"] forState:UIControlStateHighlighted];
//            [button addTarget:self action:@selector(showReft) forControlEvents:UIControlEventTouchUpInside];
//            button.frame = CGRectMake(0, 0, 25, 25);
//            button;
//        })];
//        barButton;//APP_登录确定1_返回.png
//    })];

    
    
    
    
    
    
    
    

//    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
//    statusView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:statusView];
//    self.view.backgroundColor = [UIColor whiteColor];
    
    navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    
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
    
    NSArray *buArray = @[@"本地",@"USB",@"在线音乐"];
    for (int i = 0; i < 3; i++) {
        UIButton *buttonT = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonT.frame = CGRectMake(SCREENWIDTH /3 * (i), 0, SCREENWIDTH /3, 44);
        buttonT.backgroundColor = [UIColor clearColor];
        [buttonT setTitle:buArray[i] forState:UIControlStateNormal];
        buttonT.titleLabel.font = [UIFont systemFontOfSize:18];
        [buttonT setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [buttonT setTitleColor:HTextColor forState:UIControlStateSelected];
        buttonT.tag = 100 + i;
        [buttonT addTarget:self action:@selector(changeM:) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:buttonT];
        if (i == 0) {
            buttonT.selected = YES;
            scrollViewPage = 0;
        }
        if (i == 0 || i == 1) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(buttonT.frame.size.width - 1, 10, 1, buttonT.frame.size.height - 20)];
            label.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.4];
            [buttonT addSubview:label   ];
        }
    }
}
-(void)changeM:(UIButton*)bu{
    for (UIButton *button in navView.subviews) {
        button.selected = NO;
    }
    bu.selected = YES;
    
    int i = bu.tag - 100;
    [UIView animateWithDuration:0.3 animations:^{
        [_musciScroll scrollRectToVisible:CGRectMake(SCREENWIDTH*i, 0, SCREENWIDTH, SCREENHEIGHT - 124 - 54) animated:YES];
        scrollViewPage = i;
    } completion:^(BOOL finished) {

    }];
}
-(void)showLeft{
    [MusicTimer invalidate];
    MusicTimer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setViews{
//    _musciScroll = [[UIScrollView alloc]init];//initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT - 124)
//    float width = _musciScroll.frame.size.width;
//    float heigth = _musciScroll.frame.size.height;
    float width = SCREENWIDTH   ;
    float heigth = SCREENHEIGHT - kTopHeight - 60 - 54;
    _musciScroll.contentSize = CGSizeMake(width * 3, heigth);
    _musciScroll.showsHorizontalScrollIndicator = NO;
    _musciScroll.pagingEnabled = YES;
    _musciScroll.delegate = self;
    _musciScroll.bounces = NO;
    [self.view addSubview:_musciScroll];
    
    
//    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(20);
//        make.top.equalTo(label.mas_bottom).offset(5);
//        make.height.equalTo(button1.mas_width).multipliedBy(1.3);
//    }];
    
    localTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, width, heigth )];
    localTableview.delegate = self;
    localTableview.dataSource = self;
    localTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [localTableview registerNib:[UINib nibWithNibName:@"newMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"newMusicTableViewCell"];
    [_musciScroll addSubview:localTableview];
    
    UhoustTableview = [[UITableView alloc]initWithFrame:CGRectMake(width, 0, width, heigth)];
    UhoustTableview.delegate = self;
    UhoustTableview.dataSource = self;
    UhoustTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [UhoustTableview registerNib:[UINib nibWithNibName:@"newMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"newMusicTableViewCell"];
    [_musciScroll addSubview:UhoustTableview];
    
    netTableview = [[UITableView alloc]initWithFrame:CGRectMake(width*2, 0, width, heigth)];
    netTableview.delegate = self;
    netTableview.dataSource = self;
    netTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [netTableview registerNib:[UINib nibWithNibName:@"newMusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"newMusicTableViewCell"];
    [_musciScroll addSubview:netTableview];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == localTableview) {
        return [newMusic shareInstance].localMusicArray.count;
    }
    else if (tableView == UhoustTableview) {
        return [newMusic shareInstance].UhoustMusicArray.count;
    }
    else{
        return [newMusic shareInstance].netMusicArray.count;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == localTableview ) {
        static NSString*identifier = @"newMusicTableViewCell";
        newMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        MusicBean *model = [newMusic shareInstance].localMusicArray[indexPath.row];
        cell.musicName.text = model.m_musicName;
        cell.musicSingerLabel.text = model.m_singerName;

        UIView *selectView = [[UIView alloc]initWithFrame:cell.frame];
        selectView.backgroundColor = [UIColor clearColor];
        UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 5, 40)];
        blueView.backgroundColor = HTextColor;
        [selectView addSubview:blueView];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, selectView.frame.size.height - 1, [UIScreen mainScreen].bounds.size.width -20, 1)];
        lineView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
        [selectView addSubview:lineView];
        [cell setSelectedBackgroundView:selectView];
        if (cell.selected) {
            cell.musicName.backgroundColor = HTextColor;
            cell.musicSingerLabel.backgroundColor = HTextColor;
        }
        return cell;
    }
    if (tableView == netTableview ) {
        static NSString*identifier = @"newMusicTableViewCell";
        newMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        MusicBean *model = [newMusic shareInstance].netMusicArray[indexPath.row];
        cell.musicName.text = model.m_musicName;
        cell.musicSingerLabel.text = model.m_singerName;
        
        UIView *selectView = [[UIView alloc]initWithFrame:cell.frame];
        selectView.backgroundColor = [UIColor clearColor];
        UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 5, 40)];
        blueView.backgroundColor = HTextColor;
        [selectView addSubview:blueView];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, selectView.frame.size.height - 1, SCREENWIDTH -20, 1)];
        lineView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
        [selectView addSubview:lineView];
        [cell setSelectedBackgroundView:selectView];

        return cell;
    }else{
        static NSString*identifier = @"newMusicTableViewCell";
        newMusicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        MusicEntry *model = [newMusic shareInstance].UhoustMusicArray[indexPath.row];
//        cell.musicName.text = model.name;
//        cell.musicSingerLabel.text = model.artist;
        cell.musicSingerLabel.hidden = YES;
        
        UIView *selectView = [[UIView alloc]initWithFrame:cell.frame];
        selectView.backgroundColor = [UIColor clearColor];
        UIView *blueView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 5, 40)];
        blueView.backgroundColor = HTextColor;
        [selectView addSubview:blueView];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, selectView.frame.size.height - 1, SCREENWIDTH -20, 1)];
        lineView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
        [selectView addSubview:lineView];
        [cell setSelectedBackgroundView:selectView];

        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == localTableview ) {
//        [[newMusic shareInstance].globalManager setMode:MODE_A2DP];
        switch ([newMusic shareInstance].MusicMode) {
            case MODENET:
            {

                [netTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
            }
                break;
            case MODEUHOST:
            {
                
                [UhoustTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
            }
                break;
                
            default:
                break;
        }
        [newMusic shareInstance].MusicMode = MODELOCAL;
        
        
        
        MusicBean *model = [newMusic shareInstance].localMusicArray[indexPath.row];
        if (!([newMusic shareInstance].playingMusic == model && [newMusic shareInstance].musicState == localPlay)) {
            [[newMusic shareInstance]musicPause];
        }else{
            [self toMusicVC];
        }
        if ([newMusic shareInstance].playingMusic != model ) {
             [[newMusic shareInstance]palyLocalMusic:model];
        }else{
            if ([newMusic shareInstance].musicState == localPause) {
                [[newMusic shareInstance]musicPlay];
            }
        }
        [newMusic shareInstance].uSongSelectNum = -1;
    }
    else if (tableView == netTableview ) {
//        [[newMusic shareInstance].globalManager setMode:MODE_A2DP];
        switch ([newMusic shareInstance].MusicMode) {
            case MODELOCAL:
            {
                
                [localTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
            }
                break;
            case MODEUHOST:
            {
                
                [UhoustTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
            }
                break;
                
            default:
                break;
        }
        [newMusic shareInstance].MusicMode = MODENET;
        
        MusicBean *model = [newMusic shareInstance].netMusicArray[indexPath.row];
        if (!([newMusic shareInstance].playingMusic == model && [newMusic shareInstance].musicState == netPlay)) {
            
            [[newMusic shareInstance]musicPause];
        }else{
            [self toMusicVC];
        }
        if ([newMusic shareInstance].playingMusic != model ) {
            
            [[newMusic shareInstance]playNetMusic:model];
        }else{
            if ([newMusic shareInstance].musicState == netPause) {
                
                [[newMusic shareInstance]musicPlay];
            }
        }
        [newMusic shareInstance].musicState = netPlay;
        [newMusic shareInstance].uSongSelectNum = -1;
    }
    else{
//        [[newMusic shareInstance].globalManager setMode:MODE_UHOST];
        switch ([newMusic shareInstance].MusicMode) {
            case MODELOCAL:
            {
                
                [localTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
            }
                break;
            case MODENET:
            {
                
                [netTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[newMusic shareInstance].musicSelectNum inSection:0] animated:YES]; //取消点击效果
            }
                break;
                
            default:
                break;
        }
        [newMusic shareInstance].MusicMode = MODEUHOST;

        
//        MusicEntry *model = [newMusic shareInstance].UhoustMusicArray[indexPath.row];
//
//        if ([newMusic shareInstance].musicState != uPause && [newMusic shareInstance].musicState != uPlay) {            
//            [[newMusic shareInstance]musicPause];
//        }
//        else if([newMusic shareInstance].musicState == uPlay && [newMusic shareInstance].uSongSelectNum == model.index){
//            [self toMusicVC];
//        }
//        if ([newMusic shareInstance].uSongSelectNum != model.index ) {
//
//            [[newMusic shareInstance]setUhoustPlayMusic:model];
//        }else{
//
//            [[newMusic shareInstance]musicPlay];
//
//        }
    }
}

- (IBAction)touch_up_inside:(id)sender {
    UISlider*slider = sender;
    [[newMusic shareInstance]changeMusicValue:slider.value];
    //延时恢复防止滑动条回滑
    double delayInSeconds = 1.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [MusicTimer setFireDate:[NSDate date]];
                   });
}
- (IBAction)touchDown:(id)sender {
     [MusicTimer setFireDate:[NSDate distantFuture]];
}
- (IBAction)cancelEvent:(id)sender {
    [MusicTimer setFireDate:[NSDate date]];
}
- (IBAction)valueChange:(id)sender {
}
- (IBAction)outSide:(id)sender {
    NSLog(@"touch reKnow    up outside");//滑到最右边走这个方法不会走上面touch_up_inside的方法
    [[newMusic shareInstance]musicNext];
    //延时恢复防止滑动条回滑
    double delayInSeconds = 1.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [MusicTimer setFireDate:[NSDate date]];
                   });

}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 当前视图中有N多UIScrollView
    if (scrollView == _musciScroll) {
        scrollViewPage  = scrollView.contentOffset.x / SCREENWIDTH;
        [UIView animateWithDuration:0.3 animations:^{
            for (UIButton *button in navView.subviews) {
                button.selected = NO;
            }
            UIButton *bu = (UIButton *)[self.view viewWithTag:scrollViewPage + 100];
            bu.selected = YES;
        }];
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
