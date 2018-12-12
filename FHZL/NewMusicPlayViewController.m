//
//  NewMusicPlayViewController.m
//  WeiZhong_ios
//
//  Created by hk on 17/9/18.
//
//

#import "NewMusicPlayViewController.h"
#import "CALayer+PauseAimate.h"
#import "newMusic.h"
#import "NewMusicVC.h"
@interface NewMusicPlayViewController (){
    NSTimer *MusicTimer;
    BOOL _isAdd;
    BOOL _isReload;
    NSString *oldNowTime;
    int totalTimeInt;
}
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UILabel *songNameLable;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *relateImage;
@property (weak, nonatomic) IBOutlet UIImageView *songImage;
@property (weak, nonatomic) IBOutlet UISlider *songProgress;
@property (weak, nonatomic) IBOutlet UILabel *nowLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *preButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UISlider *voiceSlider;

@end

@implementation NewMusicPlayViewController


- (IBAction)voice_Touch_up:(id)sender {
    UISlider*slider = sender;
//    [[newMusic shareInstance].globalManager setVolume  :slider.value];
}

- (IBAction)cancelButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)palyOrPause:(id)sender {
    if (_playOrPauseButton.selected) {
        [[newMusic shareInstance]musicPause];
         [self.songImage.layer pauseAnimate];
    }else{
        [[newMusic shareInstance]musicPlay];
        if (_isAdd) {
            [self.songImage.layer resumeAnimate];
        }else{
            [self addIconViewAnimate];
        }
    }
    _playOrPauseButton.selected = !_playOrPauseButton.selected;
}
- (IBAction)preSong:(id)sender {
    
    
    [[newMusic shareInstance]musicPre];
    if (_isAdd) {
        [self.songImage.layer pauseAnimate];
        [self.songImage.layer resumeAnimate];
    }else{
        [self addIconViewAnimate];
    }
}
- (IBAction)nextSong:(id)sender {
    
    
    
    [[newMusic shareInstance]musicNext];
    
    if (_isAdd) {
        //要恢复先暂停
        [self.songImage.layer pauseAnimate];
        [self.songImage.layer resumeAnimate];
    }else{
        [self addIconViewAnimate];
    }
}
- (IBAction)sliderDown:(id)sender {
    
    
    [MusicTimer setFireDate:[NSDate distantFuture]];
}
//cancel  enent
- (IBAction)slider:(id)sender {
    
    [MusicTimer setFireDate:[NSDate date]];
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

- (IBAction)dragoutSide:(id)sender {
     NSLog(@"touch reKnow  dragoutSide");
    
}
- (IBAction)dragOutSide:(id)sender {
    NSLog(@"touch reKnow  dragoutSide");
}
- (IBAction)exit:(id)sender {
    NSLog(@"touch reKnow  exit");//滑到最右边走这个方法不会走上面touch_up_inside的方法
}

- (IBAction)enter:(id)sender {
    NSLog(@"touch reKnow  enter");
}
- (IBAction)downrepeat:(id)sender {
    NSLog(@"touch reKnow  downrepeat");
}






- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duankailanya) name:@"duankailianjie2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UhoustLeast) name:@"UhoustLeast" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:@"applicationDidBecomeActive" object:nil];
    oldNowTime = @"00:00";
    totalTimeInt = 0;
    _isAdd = NO;
    _isReload = NO;
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = YES;
    [self.songProgress setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    // 38 187 102
    [self.songProgress setMinimumTrackTintColor:[UIColor colorWithRed:38/255.0 green:187/255.0 blue:102/255.0 alpha:1.0]];
    UIToolbar *blurView = [[UIToolbar alloc] init];
    blurView.barStyle = UIBarStyleBlack;
    blurView.frame = self.backImage.bounds;
    [self.backImage addSubview:blurView];
    
    [self changeMusicState];
    if (_playOrPauseButton.selected) {
        if (!_isAdd) {
            [self addIconViewAnimate];
        }
    }else{
    }
    
//    _voiceSlider.value = [newMusic shareInstance]globalManager.voice
}
-(void)duankailanya{
    [self cancelButton:nil];
}
-(void)UhoustLeast{
    [self cancelButton:nil];
}
- (void)addIconViewAnimate
{
    _isAdd = YES;
    // 1.创建基本动画
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    // 2.给动画设置一些属性
    rotationAnim.fromValue = @(0);
    rotationAnim.toValue = @(M_PI * 2);
    rotationAnim.repeatCount = NSIntegerMax;
    rotationAnim.duration = 35;
    
    // 3.将动画添加到iconView的layer上面
    [self.songImage.layer addAnimation:rotationAnim forKey:nil];
    
}
-(void)applicationDidBecomeActive{
    if (_isReload) {
        [self addIconViewAnimate];
    }else{
        [self addIconViewAnimate];
        [self.songImage.layer pauseAnimate];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    if (MusicTimer == nil) {
        MusicTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                      target:self
                                                    selector:@selector(changeMusicState)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [MusicTimer invalidate];
    MusicTimer = nil;
}
-(void)changeMusicState{
    
    
    
//    if  ([[newMusic shareInstance].totalPlayTime isEqualToString:@"00:00"]) {
//        totalTimeInt ++;
//        if (totalTimeInt >= 15) {
//            [[newMusic shareInstance] musicNext];
//            totalTimeInt = 0;
//        }
//        
//    }else{
//        totalTimeInt = 0;
//    }
    
    
    
    if ([[newMusic shareInstance].nowPlayTime isEqualToString:@"00:00"]) {
        _songProgress.enabled = NO;
    }else{
        if ([newMusic shareInstance].MusicMode == MODEUHOST) {
            _songProgress.enabled = NO;
        }else{
            _songProgress.enabled = YES;
        }
    }
    
    _backImage.image = [newMusic shareInstance].playingMusic.m_musicCover;
    _songImage.image = [newMusic shareInstance].playingMusic.m_musicCover;
    _songNameLable.text = [newMusic shareInstance].playingMusic.m_musicName;
    _songProgress.value = [newMusic shareInstance].musicProgressFloat;
    
//    _totalLabel.text = [newMusic shareInstance].totalPlayTime;

    
    
    if  ([[newMusic shareInstance].totalPlayTime isEqualToString:@"00:00"]) {
       _totalLabel.text = @"00:00";//__:__
    }else{
       _totalLabel.text = [newMusic shareInstance].totalPlayTime;
    }

    
    
    //排除一直点暂停播放播出时间会显示“00：00”
    if (![[newMusic shareInstance].nowPlayTime isEqualToString:@"00:00"]) {
        oldNowTime = [newMusic shareInstance].nowPlayTime;
        _nowLabel.text = [newMusic shareInstance].nowPlayTime;
    }else{
        _nowLabel.text = oldNowTime;
    }
    
    
    
    
    
    BOOL now_isReload;
    
    switch ([newMusic shareInstance].musicState) {
        case uPlay:
        case localPlay:
        case netPlay:
        {
            
            now_isReload = YES;
            
            _playOrPauseButton.selected = YES;
            NSLog(@"new  _musicPlayOrPause.selected = YES");
            _relateImage.transform = CGAffineTransformMakeRotation(0);
            
            
        }
            break;
            
        default:
        {
            now_isReload = NO;
            _playOrPauseButton.selected = NO;
            _relateImage.transform = CGAffineTransformMakeRotation(-M_PI/4);
        }
            break;
    }
    if (now_isReload != _isReload) {
        if (now_isReload) {
            if (_isAdd) {
                //要恢复先暂停
                [self.songImage.layer pauseAnimate];
                
                [self.songImage.layer resumeAnimate];
            }else{
                
                [self addIconViewAnimate];
            }

        }else{
            [self.songImage.layer pauseAnimate];
        }
        _isReload = now_isReload;
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
    _singerLabel.text = [NSString stringWithFormat:@"%@%@",musicStateStr,[newMusic shareInstance].playingMusic.m_singerName];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
