//
//  KDXFvoiceManager.m
//  WeiZhong_ios
//
//  Created by hk on 17/9/21.
//
//
//#import "UDPManager.h"
#import "dialogueAddressCell.h"

#import "KDXFvoiceManager.h"
#import "TTSConfig.h"
#import "IATConfig.h"
//#import <AMapSearchKit/AMapSearchKit.h>
#import "ChineseToPinyin.h"
#import "Header.h"
#import "LocalizedStringTool.h"
#import "UserManager.h"
#import "UIUtil.h"
//#import "CreatePoiRequest.h"
//#import "CreatePoiResponse.h"
//#import "GetPoiRequest.h"
//#import "GetPoiResponse.h"
#import "AppData.h"
#import "TIPmodel.h"
#import "JZLocationConverter.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MusicModel.h"
#import "MusicCell.h"
#import <AVFoundation/AVFoundation.h>
#import "FHXTmoreSelectTableViewCell.h"
#define SONGLIST @"http://search.kuwo.cn/r.s?all=%@&pn=1&rn=20&ft=music&itemset=web_2017&client=kt&rformat=json&encoding=utf8&key=YUFDSAFDSABFEELIENNDGT"
//#import "MusicViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "newMusic.h"
#import "PcmPlayer.h"


#define L(key)  NSLocalizedString(key, nil)

#define LoadStr @"您可以说导航、打电话" //听音乐

#define LoadStr2 @"我可以导航、打电话"

@interface  KDXFvoiceManager()<IFlySpeechSynthesizerDelegate,AVAudioPlayerDelegate,PcmPlayerDelegate>
{
    //AMapSearchDelegate
    int BTmode;
    BOOL isSpeakIng; //是否在说话
    BOOL isSpeakAgain;
    BOOL isCanSpeak; //能否说话
    BOOL isCanRetain; //提示用户没有说话之后一直处于语音语义理解状态
    BOOL tableReload; //能否刷新tableView
    CGFloat degree;
    int voiceInt; //声音大小
    UIButton *voiceButton; //停止说话按钮
    UIImageView *quanquanImageView; //说话时圈圈动画
    NSString *speakText; //说话展现内容
    NSString *addressStr; //说出的关键字
    NSString *cityStr; //导航城市
    NSMutableArray *dataArr; //搜索到的导航信息
    NSMutableArray *phoneDataArr; //搜索到的电话本信息
    NSMutableArray *contactArray;
    NSString *_taskID; //任务ID
    NSTimer *timer;
    BOOL isNoFinish; //firstStep里面的话有没有说完(YES表示没说完，NO表示说完)
    BOOL noUseListenFirst;
    long long x; //播放歌曲当前时间的总帧数
    int y; //播放歌曲当前时间每秒播放的帧数
    UILabel *doIngLabel;   //当前状态label
    UISlider* volumeViewSlider;
    CGFloat voicePhone;
    MPVolumeView *volumeView;
    BOOL quanquanLater;//是否延时圈圈nohidden
    BOOL isShowVoiceAnimal; //是否展示声音动画效果
    int speakTimeInt;  //说话计时
    BOOL isCanZero;//计时能否至零
    NSString *playUrl; //存储播放连接
    BOOL isGetUrl; //是否去合成本地默认语音
    BOOL isStep32; //step是否是32  直接本地搜索号码
    int speakInt; //语音说话时判断是否卡顿
}
@property(nonatomic,assign)BOOL stop;
@property(nonatomic,strong)NSMutableArray *songDataArr; //搜索到的歌曲信息
@property(nonatomic,strong)AVPlayerItem *item;
@property(nonatomic,strong)AVPlayer *player;
@property(nonatomic,strong)AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) PcmPlayer *firstPlayer;
@property(nonatomic,assign)int n;
@property(nonatomic,assign)int tag; //区分导航、打电话、搜索歌曲

@end
@implementation KDXFvoiceManager
+(KDXFvoiceManager*)shareInstance{
    static KDXFvoiceManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^
                  {
                      instance = [[[self class] alloc] init];
                  });
    return instance;
}
-(id)init{
    if (self = [super init]){
        _songDataArr = [NSMutableArray array];
        phoneDataArr = [NSMutableArray array];
        dataArr = [NSMutableArray array];
        _isNetOK = YES;
        [self viewDidLoad];
    }
    return self;
}
-(void)zeroVoice{
//    [volumeViewSlider setValue:0.3f animated:NO];
//    // send UI control event to make the change effect right now.
//    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void)getVoiceNow{
//    [volumeViewSlider setValue:1 animated:NO];
//    // send UI control event to make the change effect right now.
//    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void)getVoice{
//    double delayInSeconds = 0.8f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                   {
//                       [volumeViewSlider setValue:1 animated:NO];
//                       // send UI control event to make the change effect right now.
//                       [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
//                       NSLog(@"声音   get");
//                   });
}
- (void)viewDidLoad
{
//    [super viewDidLoad];
    
    
    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //uri合成路径设置
    playUrl = [NSString stringWithFormat:@"%@/%@",prePath,@"uri.pcm"];
    //pcm播放器初始化
    _firstPlayer = [[PcmPlayer alloc] init];
    _firstPlayer.PcmDele = self;
    
    _myTableView = [[UITableView alloc]init];
    _myTableView.backgroundColor = RGB(235, 235, 245);
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    
    quanquanLater = NO;
    // Do any additional setup after loading the view from its nib.
    volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-300, -200, 300, 100)];
//    [self.view addSubview: volumeView];

    volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    voicePhone = [AVAudioSession sharedInstance].outputVolume;
    
    [self getVoiceNow];
    NSLog(@"voicePhone = %f",voicePhone);
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoVoice) name:@"gotoVoice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CALLCOMING) name:@"CALLCOMING" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CTCallStateDisconnected) name:@"CTCallStateDisconnected" object:nil];
    
    
//    APPDELEGATE.isEnterOnekeyVoiceVC = YES;
    _isFromOnekeyVoiceVCBack = NO;
    
    BTmode = (int)self.BTmusic;
    speakInt = 0;
    self.stop = YES;
    isSpeakIng = NO;
    isSpeakAgain = NO;
    isCanSpeak = YES;
    isCanRetain = YES;
    isCanZero = YES;
    tableReload = NO;
    degree = 0.;
    isNoFinish = YES;
    noUseListenFirst = YES;
    x = 0;
    y = 1;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataArr = [NSMutableArray array];
    phoneDataArr = [NSMutableArray array];
    
//    dispatch_async(dispatch_get_main_queue(), ^
//                   {
//                       voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                       voiceButton.frame = CGRectMake((SCREENWIDTH - 82 - 16) / 2, 0, 82, 82);
//                       [voiceButton setImage:[UIImage imageNamed:@"voicenaci_maike_n"] forState:UIControlStateNormal];
//                       [voiceButton addTarget:self action:@selector(speakStop) forControlEvents:UIControlEventTouchUpInside];
////                       [_voiceImageView addSubview:voiceButton];
//                       
//                       quanquanImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 82, 82)];
//                       quanquanImageView.image = [UIImage imageNamed:@"voicenavi_mkbg"];
//                       [voiceButton addSubview:quanquanImageView];
//                       quanquanImageView.hidden = YES;
//                       [self setNavi];
//                   });
    
//    [UIApplication sharedApplication].idleTimerDisabled = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(quanAnimation) userInfo:nil repeats:YES];
    double delayInSeconds = 2.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       _searcher = [[BMKSuggestionSearch alloc] init];
                       _searcher.delegate = self; //BMKSuggestionSearchDelegate
                       
                       contactArray = [NSMutableArray array];
                       self.uploader = [[IFlyDataUploader alloc] init];
                       DISPATCH_ON_GROUP_THREAD(^{
                           [self getContact];
                       })
                       
                       if (![USER_PLIST boolForKey:@"isFirstOne"]) {
                           [self uploadContact];
                           [USER_PLIST setInteger:contactArray.count forKey:@"connecterCount"];
                           [USER_PLIST setBool:YES forKey:@"isFirstOne"];
                           [USER_PLIST synchronize];
                       }else{
                           if (contactArray.count != [USER_PLIST integerForKey:@"connecterCount"]) {
                               [self uploadContact];
                               [USER_PLIST setInteger:contactArray.count forKey:@"connecterCount"];
                               [USER_PLIST synchronize];
                           }
                       }
                   });
    if (IOS_VERSION < 10.1) {
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetoothA2DP error:nil];
    }else{
        
    }
    [self initSynthesizer];
    [self initUnderstander];
}

- (void)viewWillAppear:(BOOL)animated
{
//    APPDELEGATE.isEnterOnekeyVoiceVC = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_iFlySpeechSynthesizer stopSpeaking];
    _iFlySpeechSynthesizer.delegate = nil;
    [_iFlySpeechUnderstander cancel];
    [_iFlySpeechUnderstander stopListening];
//    [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [timer invalidate];
    timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self getVoice];
}

//- (void)dealloc
//{
//    [self getVoice];
//    
//}

-(void)gotoVoice
{
//    if (_item != nil)
//    {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
//        _item = nil;
//    }
//    if (_player != nil)
//    {
//        [_player.currentItem removeObserver:self forKeyPath:@"status"];
//        [_player pause];
//        _player = nil;
//    }
//    
//    [_iFlySpeechUnderstander cancel];
//    isCanSpeak = YES;
////    [self firstStep];
//    isCanRetain = YES;
    [dataArr removeAllObjects];
    [phoneDataArr removeAllObjects];
    [self.songDataArr removeAllObjects];
    [_myTableView reloadData];
//    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(hiddenTableView)]) {
//        [_ChangeChatDele hiddenTableView];
//    }
}
-(void)CTCallStateDisconnected{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self back];
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
            [_ChangeChatDele cancelVoice];
        }
    });
}
-(void)CALLCOMING{
    
    NSLog(@"来电话了  返回UI");
    
}
-(void)speakStop
{
    if (!isSpeakIng) {
        [self gotoVoice];
    }
    else if (isSpeakIng && _stop)
    {
        [_iFlySpeechUnderstander stopListening];
        isSpeakIng = NO;
//        [_voiceImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"voicenaci_sound0"]]];
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(changeSoundImage:)]) {
            [_ChangeChatDele changeSoundImage:0];
        }
        _stop = NO;
    }
}
-(void)wakeUpVoice{
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(wakeUpVoice)]) {
        [_ChangeChatDele wakeUpVoice];
    }
}
-(void)setNavi
{
//    self.navigationController.navigationBar.hidden = YES;
//    
//    self.view.backgroundColor = [UIColor whiteColor];
//    
//    UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
//    statusView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:statusView];
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
//    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 - 50, 0, 100, 44)];
//    nameLable.text = @"语音";
//    nameLable.textAlignment = NSTextAlignmentCenter;
//    nameLable.font = [UIFont systemFontOfSize:18];
//    nameLable.textColor = [UIColor whiteColor];
//    [navView addSubview:nameLable];
//    
//    doIngLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH  - 150, 0, 150, 44)];
//    doIngLabel.textAlignment = NSTextAlignmentRight;
//    doIngLabel.font = [UIFont systemFontOfSize:10];
//    doIngLabel.textColor = [UIColor redColor];
    //    [navView addSubview:doIngLabel];
}

-(void)back
{
    
    self.isEnterOnekeyVoiceVC = NO;
    self.isFromOnekeyVoiceVCBack = YES;
    dispatch_async(dispatch_get_main_queue(), ^
                   {
//                       if (APPDELEGATE.isLoadVCMain)
//                       {
//                           MusicViewController *musicVC = [MusicViewController shareInstance];
//                           [musicVC initPlay];
//                       }
//                       else
//                       {
//                           if (BTmode == 2)
//                           {
//                               [[NSNotificationCenter defaultCenter] postNotificationName:@"ZZXusbMode" object:nil];
//                           }
//                       }
                   });
    [_iFlySpeechSynthesizer stopSpeaking];
//    _iFlySpeechSynthesizer.delegate = nil;
//    _iFlySpeechUnderstander.delegate = nil;
    [_iFlySpeechUnderstander cancel];
    [_iFlySpeechUnderstander stopListening];
//    [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    self.audioPlayer = nil;
    if (_player) {
        [_player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    _item = nil;
    [_player pause];
    _player = nil;
//    [timer invalidate];
//    timer = nil;
    
//    [OnekeyVoiceViewController destroyInstance];
//    [self.navigationController popViewControllerAnimated:YES];
    [self changeCA2];
    [_firstPlayer stop];
}

-(void)quanAnimation
{
    speakTimeInt ++;
//    NSLog(@"speakTimeInt = %d",speakTimeInt);
    if (speakTimeInt >= 30) {
        speakTimeInt = 30;
    }
}

-(void)firstStep
{
    speakInt ++;
    
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(removeSpeakData)]) {
        [_ChangeChatDele removeSpeakData];
    }

    speakText = LoadStr;
    _step = First;
    isCanSpeak = YES;
    isCanRetain = YES;
    isCanZero = YES;
    
    if (noUseListenFirst)// 走一次无效的语义理解 不然蓝牙远程控制接受不到
    {
        noUseListenFirst = NO;
    }

    if ([USER_PLIST objectForKey:@"URLOK"]) {   // ;   [fm fileExistsAtPath:playUrl]
        self.isEnterOnekeyVoiceVC = YES;
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(changeFirstStr::)]) {
            [_ChangeChatDele changeFirstStr:speakText :YES];
        }
        isShowVoiceAnimal = NO;
        isSpeakAgain = YES;
        _synType = NomalType;
        if (_iFlySpeechSynthesizer.isSpeaking)
        {
            _state = Playing;
        }
        [self getVoice];
        [_iFlySpeechSynthesizer stopSpeaking];

        
       
            [self changeCA];
        
        
        TTSConfig *instance = [TTSConfig sharedInstance];
        _firstPlayer = [[PcmPlayer alloc] initWithFilePath:playUrl sampleRate:[instance.sampleRate integerValue]];
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           
                           if ([newMusic shareInstance].isSpeaking) {
                               [_firstPlayer play];
                           }
                       });
       
    }else{
        
        [self speakText:speakText];
    }
    
}

-(void)speakText:(NSString *)string
{
    
    [self changeCA];
    
    self.isEnterOnekeyVoiceVC = YES;
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(changeFirstStr::)]) {
        [_ChangeChatDele changeFirstStr:string :YES];
    }
    
    isShowVoiceAnimal = NO;
    isSpeakAgain = YES;
    if ([string isEqualToString:@""])
    {
        return;
    }
    _synType = NomalType;
    _iFlySpeechSynthesizer.delegate = self;
    [_iFlySpeechSynthesizer startSpeaking:string];
    doIngLabel.text = @"开始说";
    if (_iFlySpeechSynthesizer.isSpeaking)
    {
        _state = Playing;
    }
    [self getVoice];
    isCanZero = YES;
    isCanRetain = YES;
    
    NSLog(@"计算时间差a");
    int speakNumber = speakInt;
    double delayInSeconds = 8.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       if (speakInt == speakNumber) {
                           [UIUtil showToast:@"网络异常" inView:SELFVIEW];
                           [_iFlySpeechSynthesizer stopSpeaking];
                           [_iFlySpeechUnderstander cancel];
                           [_iFlySpeechUnderstander stopListening];
                           if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
                               [_ChangeChatDele cancelVoice];
                           }

                       }
                       
                   });
}

#pragma mark --- IFlySpeechSynthesizerDelegate

/**
 合成结束(完成)回调
 对uri合成添加播放的功能
 ****/
-(void)netProblemVOiceOut{
    [UIUtil showToast:@"网络异常，再见" inView:SELFVIEW];
    [_iFlySpeechSynthesizer stopSpeaking];
    [_iFlySpeechUnderstander cancel];
    [_iFlySpeechUnderstander stopListening];
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
        [_ChangeChatDele cancelVoice];
    }
    return;
}
- (void)onCompleted:(IFlySpeechError *)error
{
    
    if (error.errorCode == 20001) {
        [self netProblemVOiceOut];
    }
    
    
    
    NSLog(@" errorCode = %d errorType = %d  errorDesc = %@ ",error.errorCode,error.errorType,error.errorDesc);
    if (isGetUrl) {
        isGetUrl = NO;
        if (error.errorCode == 0) {
            [USER_PLIST setBool:YES forKey:@"URLOK"];
        }
    }
    doIngLabel.text = @"语音合成结束";
    if ([newMusic shareInstance].isSpeaking) {
        [[newMusic shareInstance].globalManager setMode:MODE_A2DP];
    }
    if (_step == 88)
    {
        [_iFlySpeechSynthesizer stopSpeaking];
        [_iFlySpeechUnderstander cancel];
        [_iFlySpeechUnderstander stopListening];
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
            [_ChangeChatDele cancelVoice];
        }
        return;
    }

    if (_step == 101)
    {
        _n++;
//        _iFlySpeechSynthesizer.delegate = nil;
        if (_n == self.songDataArr.count)
        {
            _n = 0;
        }
//        MusicViewController *musicVC = [MusicViewController shareInstance];
//        [musicVC netTableViewSelectRow:_n];
//        MusicModel *model = self.songDataArr[_n];
//        [self sendNai3:model];
        return;
    }
    if (_step == 102)
    {
        [_iFlySpeechSynthesizer stopSpeaking];
//        _iFlySpeechSynthesizer.delegate = nil;
        [_iFlySpeechUnderstander cancel];
        [_iFlySpeechUnderstander stopListening];
//        [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        self.isEnterOnekeyVoiceVC = NO;
//        _iFlySpeechUnderstander.delegate = nil;
        [self changeCA2];
//        [OnekeyVoiceViewController destroyInstance];
//        MusicViewController *musicVC = [MusicViewController shareInstance];
//        NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
//        [viewControllers removeLastObject];
//        if (![viewControllers containsObject:musicVC])
//        {
//            [viewControllers addObject:musicVC];
//        }
//        [self.navigationController setViewControllers:viewControllers animated:NO];
//        double delayInSeconds = 0.5f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                       {
//                           APPDELEGATE.isFromOnekeyVoiceVCBack = YES;
//                           MusicViewController *musicVC = [MusicViewController shareInstance];
//                           [musicVC initPlay];
//                       });
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
            [_ChangeChatDele cancelVoice];
        }
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(goToMusicVC:)]) {
            [_ChangeChatDele goToMusicVC:NO];
        }
    }
    
    if (_step == 100)
    {
        [_iFlySpeechSynthesizer stopSpeaking];
//        _iFlySpeechSynthesizer.delegate = nil;
        [_iFlySpeechUnderstander cancel];
        [_iFlySpeechUnderstander stopListening];
//        [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        MusicModel *model = self.songDataArr[_n];
        //        [self sendNai3:model];
        
        self.isNetMusic = YES;
        self.netMusicArrM = self.songDataArr;
        NSData* NETmusicData = [NSKeyedArchiver archivedDataWithRootObject:self.netMusicArrM];
        [[NSUserDefaults standardUserDefaults]setObject:NETmusicData forKey:@"NETmusic"];
        [[newMusic shareInstance]loadNetMusic];

        self.isEnterOnekeyVoiceVC = NO;

        [self changeCA2];
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoiceNoVoice)]) {
            [_ChangeChatDele cancelVoiceNoVoice];
        }

        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(goToMusicVC:)]) {
            [_ChangeChatDele goToMusicVC:YES];
            //播放网络音乐
        }
        return;
    }
    if (_step == 99)
    {
        [_iFlySpeechSynthesizer stopSpeaking];
        [_iFlySpeechUnderstander cancel];
        [_iFlySpeechUnderstander stopListening];
        TIPmodel *tip = phoneDataArr[_n];
        [self sendNai2:tip];
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
            [_ChangeChatDele cancelVoice];
        }
        return;
    }
    if (_step == NumberPhone) {
        NSMutableString *strPhone = [[NSMutableString alloc] initWithFormat:@"telprompt://%@", addressStr];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhone]];
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
            [_ChangeChatDele cancelVoice];
        }
        return;
    }
    if (_step == 98)
    {
        [_iFlySpeechSynthesizer stopSpeaking];
        [_iFlySpeechUnderstander cancel];
        [_iFlySpeechUnderstander stopListening];
        TIPmodel *tip = dataArr[_n];
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
            [_ChangeChatDele cancelVoice];
        }
        
        

        [self sendNai:tip];
        return;
    }
    if (error.errorCode != 0)
    {
    }
    if (isSpeakAgain)
    {
        if (noUseListenFirst)
        {
            [_iFlySpeechUnderstander cancel];
            _iFlySpeechUnderstander.delegate = self;
            
            noUseListenFirst = NO;
        }
        isNoFinish = NO;
        
        [NSThread detachNewThreadSelector:@selector(performGetMusicMessagedMethod) toTarget:self withObject:nil];
        isSpeakAgain = NO;
    }
    NSLog(@"csqfirstStep合成结束");
}
-(void)onPlayCompleted{
    NSLog(@"csqfirstStepc播放默认结束");
    if (isSpeakAgain)
    {
        isNoFinish = NO;
        [NSThread detachNewThreadSelector:@selector(performGetMusicMessagedMethod) toTarget:self withObject:nil];
        isSpeakAgain = NO;
    }
}
-(void)performGetMusicMessagedMethod
{
    
    doIngLabel.text = @"speak end";
    if (_step == 102) {
        return;
    }
    if (isCanZero) {
        speakTimeInt = 0;
        isCanZero = NO;
    }
    if (isCanSpeak)
    {
        [self playSound:@"speak_end"];
//        if (![AppData btMIC]) {
//            //qq声音在蓝牙设备上 语音在手机上
//            //                        [self playSound:@"qq"];
//            //                        double delayInSeconds = 0.4f;
//            //                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            //                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//            //                                       {
//            //                                           [self speakNotZeroVoice];
//            //                                           [self zeroVoice];
//            //                                       });
//            //qq声音在手机上 语音在手机上
//            
//            [self speakNotZeroVoiceNotLater];
//            [self playSound:@"qq"];//或者延时0.1
//            
//            //没有qq声音没有延时，建议这种
//            //             [self speak];
//            
//        }else{
//            if (APPDELEGATE.isLink) {
//                [self speakNotZeroVoice];
//                double delayInSeconds = 0.05f;
//                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                               {
//                                   [self playSound:@"qq"];
//                                   _stop = YES;
//                               });
//            }else{
//                [self playSound:@"qq"];
//            }
//        }
    }
    else
    {
        if (self.tag == 1)
        {
            [self searchAddress];
            doIngLabel.text = @"开始搜索地址";
        }
        if (self.tag == 2)
        {
            if (_step ==  First) {
                return;
            }
            doIngLabel.text = @"开始搜索手机号";
            [self searchAddress2];
        }
        if (self.tag == 3)
        {
            if (_step ==  First) {
                return;
            }
            doIngLabel.text = @"开始搜索歌曲";
            [self searchAddress3];
        }
    }
    [NSThread exit];
}

-(void)playSound:(NSString *)soundStr
{
    NSString *path = [[NSBundle mainBundle] pathForResource:soundStr ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.delegate = self;

    [self getVoiceNow];
    [self.audioPlayer play];

}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self speak];
//    if (![AppData btMIC]) {
//        
//    }else{
//        if (!APPDELEGATE.isLink) {
//            [self speak];
//        }
//    }
//    [self zeroVoice];
}
/**
 语音语义理解启动
 ****/
-(void)speak
{
    
//    if (isCanZero) {
//        speakTimeInt = 0;
//        isCanZero = NO;
//    }
    
    quanquanLater = NO;

    
    [_iFlySpeechUnderstander setParameter:@"2000" forKey:[IFlySpeechConstant VAD_EOS]];
    [_iFlySpeechUnderstander startListening];
    isSpeakIng = YES;
    doIngLabel.text = @"开始听";
    
    if (![AppData btMIC]) {
        NSLog(@"设置手机说话");
        [self changeMIC];
    }
}
-(void)speakNotZeroVoice
{
    //    [self zeroVoice];
    
//    if (isCanZero) {
//        speakTimeInt = 0;
//        isCanZero = NO;
//    }
    
    [_iFlySpeechUnderstander startListening];
    isSpeakIng = YES;
    if (![AppData btMIC]) {
        double delayInSeconds = 0.005f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           
                           [self changeMIC];
                       });
        
        NSLog(@"设置手机说话");
        
    }
}
-(void)speakNotZeroVoiceNotLater
{
    //    [self zeroVoice];
    
    
    
    quanquanLater = YES;
    if (![AppData btMIC]) {
        [_iFlySpeechUnderstander setParameter:@"2000" forKey:[IFlySpeechConstant VAD_EOS]];
    }
    
    [_iFlySpeechUnderstander startListening];
    isSpeakIng = YES;
    if (![AppData btMIC]) {
        [self changeMIC];
        NSLog(@"设置手机说话");
    }
}

/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakBegin
{
    speakInt ++;
    NSLog(@"计算时间差b");
    [self getVoiceNow];
//    _textLabel.text = speakText;
    
    if (self.tag == 3)
    {
        _myTableView.hidden = YES;
    }
    else
    {
        _myTableView.hidden = NO;
    }
    
    if (tableReload)
    {
        [_myTableView reloadData];
        tableReload = NO;
        
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(pushTableview)]) {
            [_ChangeChatDele pushTableview];
        }
        
        
    }
    if (_state != Playing)
    {
        
    }
    _state = Playing;
}

/**
 *  播放进度回调
 *
 *  @param progress 当前播放进度，0-100
 *  @param beginPos 当前播放文本的起始位置，0-100
 *  @param endPos 当前播放文本的结束位置，0-100
 */

-(void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos
{
    NSLog(@"播放进度speak progress %2d%%.", progress);
    if (progress > 0) {
        
    }
//    [_player pause];
}

#pragma mark --- IFlySpeechRecognizerDelegate

/**
 音量变化回调
 volume 录音的音量，音量范围0~30
 ****/
- (void)onVolumeChanged:(int)volume
{
    if (isNoFinish)
    {
        return;
    }
    if (!isShowVoiceAnimal) {
        return;
    }
    if (volume >= voiceInt)
    {
        
        voiceInt = volume;
    }
//    [_voiceImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"voicenaci_sound%d",volume]]];
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(changeSoundImage:)]) {
        [_ChangeChatDele changeSoundImage:volume];
    }
}

/**
 开始录音回调
 ****/
- (void)onBeginOfSpeech
{
    if (!isNoFinish)
    {
        if (!quanquanLater) {
            quanquanImageView.hidden = NO;
            isShowVoiceAnimal = YES;
        }else{
            double delayInSeconds = 1.15f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               isShowVoiceAnimal = YES;
                               quanquanImageView.hidden = NO;
                               //                               [self zeroVoice];
                           });
        }
        
    }
}

/**
 停止录音回调
 ****/
- (void)onEndOfSpeech
{
    [self getVoiceNow];
    doIngLabel.text = @"听完了开始网络解析";
//    [_voiceImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"voicenaci_sound0"]]];
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(changeSoundImage:)]) {
        [_ChangeChatDele changeSoundImage:0];
    }
    quanquanImageView.hidden = YES;
    isSpeakIng = NO;
}

- (void)onError:(IFlySpeechError *)errorCode
{
    NSLog(@"语音识别结果判断*********************************errorDesc = %@",errorCode.errorDesc);
    if (errorCode.errorCode != 0) {
        if (errorCode.errorCode == 10114 || errorCode.errorCode == 20001) {
            [self netProblemVOiceOut];
        }else{
            speakText = @"我没有听清。";
            [self speakText:speakText];
            return;
        }
    }
}
- (BOOL)deptNumInputShouldNumber:(NSString *)str
{
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}


/**
 语义理解结果回调
 result 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 isLast：表示最后一次
 ****/
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast
{
    isStep32 = NO;
    doIngLabel.text = @"语音解析完成";
    NSDictionary *dic =nil;
    NSMutableString *result = [[NSMutableString alloc] init];
    if (results != nil) {
        dic = results[0];
    }
    for (NSString *key in dic)
    {
        [result appendFormat:@"%@",key];
    }
    NSLog(@"听写结果:result = %@",result);
    NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic222 = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"听写结果:dic222 = %@",dic222);
    
    if(error)
    {
        NSLog(@"json解析听写结果失败:error = %@",error);
    }
    
    if (voiceInt <= 5)
    {
//        if (_step == First)
//        {
            if (speakTimeInt >= 21) {
                if (isCanRetain) {
                    speakText = @"您好像没有说话";
                    [self speakText:speakText];
                    isCanRetain = NO;
                    isCanZero = NO;
                    voiceInt = 0;
                    return;
                }else{
                    speakText = @"再见";
                    _step = 88;
                    [self speakText:speakText];
                    isCanRetain = NO;
                    voiceInt = 0;
                    return;
                }
            }else if(speakTimeInt >= 10){
                if (isCanRetain) {
                    speakText = @"您好像没有说话";
                    [self speakText:speakText];
                    isCanRetain = NO;
                    isCanZero = NO;
                    voiceInt = 0;
                    return;
                }else{
                    [self speak];
                    voiceInt = 0;
                    return;
                }
            }else{
                [self speak];
                voiceInt = 0;
                return;
            }

//        }
//        if (_step == Three)
//        {
//            if (self.tag == 1 || self.tag == 2)
//            {
//                
//                
//                if (speakTimeInt >= 21) {
//                    speakText = @"再见";
//                    _step = 88;
//                    [self speakText:speakText];
//                    isCanRetain = NO;
//                    voiceInt = 0;
//                    return;
//                }else if(speakTimeInt >= 10){
//                    if (isCanRetain) {
//                        speakText = @"您好像没有说话！请说第几个或者取消。";
//                        [self speakText:speakText];
//                        isCanRetain = NO;
//                        isCanZero = NO;
//                        voiceInt = 0;
//                        return;
//                    }else{
//                        [self speak];
//                        voiceInt = 0;
//                        return;
//                    }
//                }else{
//                    [self speak];
//                    voiceInt = 0;
//                    return;
//                }

                
//                if (isCanRetain)
//                {
//                    speakText = @"您好像没有说话！请说第几个或者取消。";
//                    [self speakText:speakText];
//                    isCanRetain = NO;
//                    voiceInt = 0;
//                    return;
//                }
//                else if (!isCanRetain)
//                {
//                    [self speak];
//                    voiceInt = 0;
//                    return;
//                }
//            }
//            if (self.tag == 3)
//            {
//                if (speakTimeInt >= 21) {
//                    speakText = @"再见";
//                    _step = 88;
//                    [self speakText:speakText];
//                    isCanRetain = NO;
//                    voiceInt = 0;
//                    return;
//                }else if(speakTimeInt >= 10){
//                    if (isCanRetain) {
//                        speakText = @"您好像没有说话！请说第几首或者取消。";
//                        [self speakText:speakText];
//                        isCanRetain = NO;
//                        isCanZero = NO;
//                        voiceInt = 0;
//                        return;
//                    }else{
//                        [self speak];
//                        voiceInt = 0;
//                        return;
//                    }
//                }else{
//                    [self speak];
//                    voiceInt = 0;
//                    return;
//                }

                
//            }
//        }
    }
    else
    {
        NSLog(@"音量大小音量大小音量大小音量大小音量大小音量大小音量大小音量大小音量大小音量大小:voiceInt = %d",voiceInt);
        voiceInt = 0;
    }
    
    if (result.length == 0 || results == nil) //输入的是杂音之类的
    {
        [self speak];
        return;
    }
    
    if (dic222[@"text"] == nil) //吐字不清晰
    {
        speakText = @"我不明白您的意思。";
        [self speakText:speakText];
        return;
    }
    
    if (dic222[@"text"] != nil)
    {
//        _myTextLabel.text = dic222[@"text"];
        
        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(changeFirstStr::)]) {
            [_ChangeChatDele changeFirstStr:dic222[@"text"] :NO];
        }
        
        NSArray *array = [dic222[@"text"] componentsSeparatedByString:@"给"];
        if (array.count >= 2){
            if ([self deptNumInputShouldNumber:array[1]]) {
                
                speakText = [NSString stringWithFormat:@"正在给号码%@打电话，请点击呼叫键。",array[1]];
                addressStr = array[1];
                _step = NumberPhone;
                [self speakText:speakText];
                return;
            }
        }
        
        NSLog(@"text = %@ , dic222[semantic] = %@",dic222[@"text"],dic222[@"semantic"]);
        
        if (_step == 31) {
            NSDictionary *dict = dic222[@"semantic"];
            if((dic222[@"semantic"] == nil|| dict.count == 0)){
                
                if ([dic222[@"text"] rangeOfString:@"打电话"].location != NSNotFound && (dic222[@"semantic"] == nil|| dict.count == 0)) {
                    speakText = @"您要打电话给谁";
                    _step = 32;
                    self.tag = 2;
                    [self speakText:speakText];
                    return;
                }
                /*屏蔽音乐
                if (([dic222[@"text"] rangeOfString:@"音乐"].location != NSNotFound ||[dic222[@"text"] rangeOfString:@"放歌"].location != NSNotFound||
                     [dic222[@"text"] rangeOfString:@"来一首"].location != NSNotFound||
                     [dic222[@"text"] rangeOfString:@"放音乐"].location != NSNotFound) && (dic222[@"semantic"][@"slots"][@"song"] == nil && dic222[@"semantic"][@"slots"][@"artist"] == nil && [dic222[@"text"] rangeOfString:@"网络"].location == NSNotFound && [dic222[@"text"] rangeOfString:@"U盘"].location == NSNotFound)) {
                    speakText = @"即将为您跳转音乐播放页面";
                    _step = 102;
                    [self speakText:speakText];
                    return;
                }
                 */
                
                
                cityStr = @"深圳市";//[UDPManager sharedInstance].addressDetailStr;
                addressStr = dic222[@"text"];
                speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                _step = 999;
                isCanSpeak = NO;
                [self speakText:speakText];
                return;
            }else
            {
                if (dic222[@"semantic"][@"slots"][@"endLoc"][@"city"] != nil)
                {
                    
                    if ([dic222[@"semantic"][@"slots"][@"endLoc"][@"city"]  isEqualToString:@"CURRENT_CITY"]) {
                        
                        cityStr = @"深圳市";//[UDPManager sharedInstance].addressDetailStr;
                    }else{
                        cityStr = dic222[@"semantic"][@"slots"][@"endLoc"][@"city"];
                    }
                    
                    NSArray *array = [dic222[@"text"] componentsSeparatedByString:@"到"];
                    if (array.count >= 2)
                    {
                        addressStr = array[array.count - 1];
                        speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                        _step = 999;
                        isCanSpeak = NO;
                        [self speakText:speakText];
                        return;
                    }else{
                        addressStr = dic222[@"semantic"][@"slots"][@"endLoc"][@"city"];
                        speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                        _step = 999;
                        isCanSpeak = NO;
                        [self speakText:speakText];
                        return;
                    }
                }
            }
        }
        if (_step == 32) {
            
            if ([self deptNumInputShouldNumber:dic222[@"text"]]) {                
                speakText = [NSString stringWithFormat:@"正在给号码%@打电话，请点击呼叫键。",dic222[@"text"]];
                addressStr = dic222[@"text"];
                _step = NumberPhone;
                [self speakText:speakText];
                return;
            }
            
            
            
            NSDictionary *dict = dic222[@"semantic"];
            if((dic222[@"semantic"] == nil|| dict.count == 0)){
                
                if ([dic222[@"text"] rangeOfString:@"导航"].location != NSNotFound && (dic222[@"semantic"] == nil|| dict.count == 0)) {
                    speakText = @"您要导航到哪里";
                    _step = 31;
                    self.tag = 1;
                    [self speakText:speakText];
                    return;
                }
                /*屏蔽音乐
                if (([dic222[@"text"] rangeOfString:@"音乐"].location != NSNotFound ||[dic222[@"text"] rangeOfString:@"放歌"].location != NSNotFound||
                     [dic222[@"text"] rangeOfString:@"来一首"].location != NSNotFound||
                     [dic222[@"text"] rangeOfString:@"放音乐"].location != NSNotFound) && (dic222[@"semantic"][@"slots"][@"song"] == nil && dic222[@"semantic"][@"slots"][@"artist"] == nil && [dic222[@"text"] rangeOfString:@"网络"].location == NSNotFound && [dic222[@"text"] rangeOfString:@"U盘"].location == NSNotFound)) {
                    speakText = @"即将为您跳转音乐播放页面";
                    _step = 102;
                    [self speakText:speakText];
                    return;
                }
                 */
                if ([dic222[@"text"] isEqualToString:@"取消"])
                {
                    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
                        [_ChangeChatDele cancelVoice];
                    }
                    return;
                }
                if (![AppData deptNumInputShouldNumber:dic222[@"text"]]) {
                    addressStr = dic222[@"text"];
                    isStep32 = YES;
                    speakText = [NSString stringWithFormat:@"电话本中搜索%@，请稍后...",addressStr];
                    _step = 999;
                    isCanSpeak = NO;
                    [self speakText:speakText];
                }else{
                    addressStr = dic222[@"text"];
                    speakText = [NSString stringWithFormat:@"正在给%@打电话，请点击呼叫键。",dic222[@"text"]];
                    _step = NumberPhone;
                    [self speakText:speakText];
                }
                
                
                return;
            }else
            {
                if (dic222[@"semantic"][@"slots"][@"name"] != nil)
                {
                    addressStr = dic222[@"semantic"][@"slots"][@"name"];
                    speakText = [NSString stringWithFormat:@"电话本中搜索%@，请稍后...",addressStr];
                    _step = 999;
                    isCanSpeak = NO;
                    [self speakText:speakText];
                    return;
                }
            }
        }
        
        if (_step == First || _step == 31 || _step == 32)
        {
            if ([dic222[@"text"] isEqualToString:@"取消"])
            {
                if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
                    [_ChangeChatDele cancelVoice];
                }
                return;
            }
            if ([dic222[@"text"] rangeOfString:@"我要去"].location != NSNotFound)
            {
                 NSArray *array = [dic222[@"text"] componentsSeparatedByString:@"我要去"];
                NSLog(@"array.count = %d",array.count);
                if (array.count >=2) {
                    addressStr = array[array.count - 1];
                    speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                    self.tag = 1;
                    _step = 999;
                    isCanSpeak = NO;
                    [self speakText:speakText];
                    return;
                }else{
                    speakText = @"您要去哪里";
                    _step = 31;
                    self.tag = 1;
                    [self speakText:speakText];
                    return;
                }
                return;
            }
            
            NSDictionary *dict = dic222[@"semantic"];
            
            
            if ([dic222[@"text"] rangeOfString:@"导航到"].location != NSNotFound && (dic222[@"semantic"] == nil|| dict.count == 0))
            {
                NSArray *array = [dic222[@"text"] componentsSeparatedByString:@"导航到"];
                NSLog(@"array.count = %d",array.count);
                if (array.count >=2) {
                    addressStr = array[array.count - 1];
                    speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                    self.tag = 1;
                    _step = 999;
                    isCanSpeak = NO;
                    [self speakText:speakText];
                    return;
                }else{
                    speakText = @"您要导航到哪里";
                    _step = 31;
                    self.tag = 1;
                    [self speakText:speakText];
                    return;
                }
                return;
            }

            
            
            if ([dic222[@"text"] rangeOfString:@"导航"].location != NSNotFound && (dic222[@"semantic"] == nil|| dict.count == 0)) {
                speakText = @"您要导航到哪里";
                _step = 31;
                self.tag = 1;
                [self speakText:speakText];
                return;
            }
            if ([dic222[@"text"] rangeOfString:@"打电话"].location != NSNotFound && (dic222[@"semantic"] == nil|| dict.count == 0)) {
                speakText = @"您要打电话给谁";
                _step = 32;
                self.tag = 2;
                [self speakText:speakText];
                return;
            }
            /*屏蔽音乐
            if (([dic222[@"text"] rangeOfString:@"来首歌"].location != NSNotFound || [dic222[@"text"] rangeOfString:@"音乐"].location != NSNotFound ||[dic222[@"text"] rangeOfString:@"放歌"].location != NSNotFound||
                 [dic222[@"text"] rangeOfString:@"来一首"].location != NSNotFound||
                 [dic222[@"text"] rangeOfString:@"放音乐"].location != NSNotFound) && (dic222[@"semantic"][@"slots"][@"song"] == nil && dic222[@"semantic"][@"slots"][@"artist"] == nil && [dic222[@"text"] rangeOfString:@"网络"].location == NSNotFound && [dic222[@"text"] rangeOfString:@"U盘"].location == NSNotFound)) {
                speakText = @"即将为您跳转音乐播放页面";
                _step = 102;
                [self speakText:speakText];
                return;
            }
            */
            
            
            if (dict.count == 0) //说“来一首歌曲”时走这里
            {
                speakText = @"我还没有学会";
                [self speakText:speakText];
                return;
            }
            
            if (dic222[@"semantic"] == nil)
            {
                speakText = @"我还没有学会";
                [self speakText:speakText];
                return;
            }
            else
            {
                if (dic222[@"semantic"][@"slots"][@"endLoc"][@"city"] != nil )
                {
                    self.tag = 1;
                    
                    if ([dic222[@"semantic"][@"slots"][@"endLoc"][@"city"]  isEqualToString:@"CURRENT_CITY"]) {
                        cityStr = @"深圳市";//[UDPManager sharedInstance].addressDetailStr;
                    }else{
                        cityStr = dic222[@"semantic"][@"slots"][@"endLoc"][@"city"];
                    }
                    NSArray *array = [dic222[@"text"] componentsSeparatedByString:@"到"];
                    if (array.count >= 2)
                    {
                        addressStr = array[array.count - 1];
                        speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                        _step = 999;
                        isCanSpeak = NO;
                        [self speakText:speakText];
                        return;
                    }else{
                        addressStr = dic222[@"semantic"][@"slots"][@"endLoc"][@"city"];
                        speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                        _step = 999;
                        isCanSpeak = NO;
                        [self speakText:speakText];
                        return;
                        
                    }
                }
                if (dic222[@"semantic"][@"slots"][@"endLoc"][@"areaAddr"] != nil )
                {
                    self.tag = 1;
                    
                    cityStr = @"深圳市";//[UDPManager sharedInstance].addressDetailStr;
                    NSArray *array = [dic222[@"text"] componentsSeparatedByString:@"到"];
                    if (array.count >= 2)
                    {
                        addressStr = array[array.count - 1];
                        speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                        _step = 999;
                        isCanSpeak = NO;
                        [self speakText:speakText];
                        return;
                    }else{
                        addressStr = dic222[@"semantic"][@"slots"][@"endLoc"][@"areaAddr"];
                        speakText = [NSString stringWithFormat:@"正在搜索%@有关的位置信息，请稍后...",addressStr];
                        _step = 999;
                        isCanSpeak = NO;
                        [self speakText:speakText];
                        return;
                        
                    }
                }
                
                if (dic222[@"semantic"][@"slots"][@"name"] != nil )
                {
                    self.tag = 2;
                    
                    addressStr = dic222[@"semantic"][@"slots"][@"name"];
                    speakText = [NSString stringWithFormat:@"电话本中搜索%@，请稍后...",addressStr];
                    _step = 999;
                    isCanSpeak = NO;
                    [self speakText:speakText];
                    return;
                }
                /*屏蔽音乐
                if (dic222[@"semantic"][@"slots"][@"song"] != nil || dic222[@"semantic"][@"slots"][@"artist"] != nil)
                {
                    self.tag = 3;
                    
                    if (dic222[@"semantic"][@"slots"][@"song"] != nil)
                    {
                        cityStr = dic222[@"semantic"][@"slots"][@"song"];
                    }
                    if (dic222[@"semantic"][@"slots"][@"artist"] != nil)
                    {
                        cityStr = dic222[@"semantic"][@"slots"][@"artist"];
                    }
                    addressStr = cityStr;
                    speakText = [NSString stringWithFormat:@"正在搜索%@的有关歌曲，请稍后...",addressStr];
                    _step = 999;
                    isCanSpeak = NO;
                    [self speakText:speakText];
                    return;
                }else{
                    
                }
                 */
            }
            speakText = @"我还没学会";
            [self speakText:speakText];
            return;
        }
        
        if (_step == Three)
        {
            NSString *speakText11 = [ChineseToPinyin pinyinFromChiniseString:dic222[@"text"]];
            NSString *firstText = [ChineseToPinyin csqpinyinFromChinese:dic222[@"text"]];
            
            if (self.tag == 1)
            {
                
                NSRange LastOneRange = [speakText11 rangeOfString:@"YI"];
                NSRange LastRange = [speakText11 rangeOfString:@"ZUIHOU"];
                if(LastOneRange.location != NSNotFound && LastRange.location != NSNotFound)
                {
                    TIPmodel *tip = dataArr[dataArr.count - 1];
                    speakText = [NSString stringWithFormat:@"选择了最后1个%@，正在打开地图...",tip.keyString];
                    _n = dataArr.count - 1;
                    _step = 98;
                    [self speakText:speakText];
                    return;
                }
                
                                NSRange OneRange = [speakText11 rangeOfString:@"YI"];
                if(OneRange.location != NSNotFound)
                {
                    if (dataArr.count >= 1)
                    {
                        TIPmodel *tip = dataArr[0];
                        speakText = [NSString stringWithFormat:@"选择了第1个：%@，正在打开地图...",tip.keyString];
                        _n = 0;
                        _step = 98;
                        [self speakText:speakText];
                    }
                    return;
                }
                NSRange TwoRange = [speakText11 rangeOfString:@"ER"];
                if(TwoRange.location != NSNotFound)
                {
                    if (dataArr.count >= 2)
                    {
                        TIPmodel *tip = dataArr[1];
                        speakText = [NSString stringWithFormat:@"选择了第2个：%@，正在打开地图...",tip.keyString];
                        _n = 1;
                        _step = 98;
                        [self speakText:speakText];
                    }
                    else
                    {
                        speakText = @"超出范围，请说第几个或者取消。";
                        [self speakText:speakText];
                    }
                    return;
                }
                NSRange ThreeRange = [speakText11 rangeOfString:@"SAN"];
                if(ThreeRange.location != NSNotFound)
                {
                    if (dataArr.count >= 3)
                    {
                        TIPmodel *tip = dataArr[2];
                        speakText = [NSString stringWithFormat:@"选择了第3个：%@，正在打开地图...",tip.keyString];
                        _n = 2;
                        _step = 98;
                        [self speakText:speakText];
                    }
                    else
                    {
                        speakText = @"超出范围，请说第几个或者取消。";
                        [self speakText:speakText];
                    }
                    return;
                }
                NSRange FourRange = [speakText11 rangeOfString:@"SI"];
                if(FourRange.location != NSNotFound)
                {
                    if (dataArr.count >= 4)
                    {
                        TIPmodel *tip = dataArr[3];
                        speakText = [NSString stringWithFormat:@"选择了第4个：%@，正在打开地图...",tip.keyString];
                        _n = 3;
                        _step = 98;
                        [self speakText:speakText];
                    }
                    else
                    {
                        speakText = @"超出范围，请说第几个或者取消。";
                        [self speakText:speakText];
                    }
                    return;
                }
                NSRange FireRange = [speakText11 rangeOfString:@"WU"];
                if(FireRange.location != NSNotFound)
                {
                    if (dataArr.count >= 5)
                    {
                        TIPmodel *tip = dataArr[4];
                        speakText = [NSString stringWithFormat:@"选择了第5个：%@，正在打开地图...",tip.keyString];
                        _n = 4;
                        _step = 98;
                        [self speakText:speakText];
                    }
                    else
                    {
                        speakText = @"超出范围，请说第几个或者取消。";
                        [self speakText:speakText];
                    }
                    return;
                }
                NSRange QXRange = [firstText rangeOfString:@"QX"];
                if(QXRange.location != NSNotFound)
                {
//                    speakText = @"我可以导航、打电话、听音乐。";
                    _step = First;
                    isCanRetain = YES;
                    isCanZero = YES;
//                    [self speakText:speakText];
                    [dataArr removeAllObjects];
                    [_myTableView reloadData];
                    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(hiddenTableView)]) {
                        [_ChangeChatDele hiddenTableView];
                    }
                    return;
                }
                speakText = @"我不明白您的意思。请说第几个或者取消。";
                [self speakText:speakText];
                return;
            }
            
            if (self.tag == 2)
            {
                if (phoneDataArr.count == 1)
                {
                    NSRange QDRange = [firstText rangeOfString:@"QD"];
                    if(QDRange.location != NSNotFound)
                    {
                        TIPmodel *tip = phoneDataArr[0];
                        speakText = [NSString stringWithFormat:@"正在给%@打电话，请点击呼叫键。",tip.keyString];
                        _n = 0;
                        _step = 99;
                        [self speakText:speakText];
                        return;
                    }
                    NSRange QXRange = [firstText rangeOfString:@"QX"];
                    if(QXRange.location != NSNotFound)
                    {
                        speakText = LoadStr2;
                        _step = First;
                        isCanRetain = YES;
                        isCanZero = YES;
//                        [self speakText:speakText];
                        [phoneDataArr removeAllObjects];
                        [_myTableView reloadData];
                        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(hiddenTableView)]) {
                            [_ChangeChatDele hiddenTableView];
                        }
                        return;
                    }
                }
                if (phoneDataArr.count > 1)
                {

                    NSCharacterSet* nonDigits =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                    int remainSecond =[[dic222[@"text"] stringByTrimmingCharactersInSet:nonDigits] intValue];
                    NSLog(@" num %d ",remainSecond);
                    
                    if (remainSecond != 0) {
                        if (phoneDataArr.count >= remainSecond)
                        {
                            TIPmodel *tip = phoneDataArr[remainSecond - 1];
                            speakText = [NSString stringWithFormat:@"选择了第%d个，正在给%@打电话，请点击呼叫键。",remainSecond,tip.keyString];
                            _n = remainSecond - 1;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;

                    }
                    
                    NSRange LastOneRange = [speakText11 rangeOfString:@"YI"];
                    NSRange LastRange = [speakText11 rangeOfString:@"ZUIHOU"];
                    if(LastOneRange.location != NSNotFound && LastRange.location != NSNotFound)
                    {
                        TIPmodel *tip = phoneDataArr[phoneDataArr.count - 1];
                        speakText = [NSString stringWithFormat:@"选择了最后1个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                        _n = phoneDataArr.count - 1;
                        _step = 99;
                        [self speakText:speakText];
                        return;
                    }

                    
                    NSRange OneRange = [speakText11 rangeOfString:@"YI"];
                    if(OneRange.location != NSNotFound)
                    {
                        TIPmodel *tip = phoneDataArr[0];
                        speakText = [NSString stringWithFormat:@"选择了第1个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                        _n = 0;
                        _step = 99;
                        [self speakText:speakText];
                        return;
                    }
                    NSRange TwoRange = [speakText11 rangeOfString:@"ER"];
                    if(TwoRange.location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 2)
                        {
                            TIPmodel *tip = phoneDataArr[1];
                            speakText = [NSString stringWithFormat:@"选择了第2个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 1;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    NSRange ThreeRange = [speakText11 rangeOfString:@"SAN"];
                    if(ThreeRange.location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 3)
                        {
                            TIPmodel *tip = phoneDataArr[2];
                            speakText = [NSString stringWithFormat:@"选择了第3个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 2;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    NSRange FourRange = [speakText11 rangeOfString:@"SI"];
                    if(FourRange.location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 4)
                        {
                            TIPmodel *tip = phoneDataArr[3];
                            speakText = [NSString stringWithFormat:@"选择了第4个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 3;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    NSRange FireRange = [speakText11 rangeOfString:@"WU"];
                    if(FireRange.location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 5)
                        {
                            TIPmodel *tip = phoneDataArr[4];
                            speakText = [NSString stringWithFormat:@"选择了第5个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 4;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    
                    if([speakText11 rangeOfString:@"LIU"].location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 6)
                        {
                            TIPmodel *tip = phoneDataArr[5];
                            speakText = [NSString stringWithFormat:@"选择了第6个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 5;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                 
                    if([speakText11 rangeOfString:@"QI"].location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 7)
                        {
                            TIPmodel *tip = phoneDataArr[6];
                            speakText = [NSString stringWithFormat:@"选择了第7个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 6;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
           
                    if([speakText11 rangeOfString:@"BA"].location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 8)
                        {
                            TIPmodel *tip = phoneDataArr[7];
                            speakText = [NSString stringWithFormat:@"选择了第8个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 7;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
    
                    if([speakText11 rangeOfString:@"JIU"].location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 9)
                        {
                            TIPmodel *tip = phoneDataArr[8];
                            speakText = [NSString stringWithFormat:@"选择了第9个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 8;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    if([speakText11 rangeOfString:@"SHI"].location != NSNotFound)
                    {
                        if (phoneDataArr.count >= 10)
                        {
                            TIPmodel *tip = phoneDataArr[9];
                            speakText = [NSString stringWithFormat:@"选择了第10个，正在给%@打电话，请点击呼叫键。",tip.keyString];
                            _n = 9;
                            _step = 99;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几个或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }

                    NSRange QXRange = [firstText rangeOfString:@"QX"];
                    if(QXRange.location != NSNotFound)
                    {
//                        speakText = @"我可以导航、打电话、听音乐。";
                        _step = First;
                        isCanRetain = YES;
                        isCanZero = YES;
//                        [self speakText:speakText];
                        [phoneDataArr removeAllObjects];
                        [_myTableView reloadData];
                        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(hiddenTableView)]) {
                            [_ChangeChatDele hiddenTableView];
                        }
                        return;
                    }
                }
                speakText = @"我不明白您的意思。请说第几个或者取消。";
                [self speakText:speakText];
                return;
            }
            
            if (self.tag == 3)
            {
                if (self.songDataArr.count == 1)
                {
                    NSRange QDRange = [firstText rangeOfString:@"QD"];
                    if(QDRange.location != NSNotFound)
                    {
                        MusicModel *model = self.songDataArr[0];
                        speakText = [NSString stringWithFormat:@"准备播放：%@",model.songName];
                        _n = 0;
                        _step = 100;
                        [self speakText:speakText];
                        return;
                    }
                    NSRange QXRange = [firstText rangeOfString:@"QX"];
                    if(QXRange.location != NSNotFound)
                    {
                        speakText = LoadStr2;
                        _step = First;
                        isCanRetain = YES;
                        isCanZero = YES;
//                        [self speakText:speakText];
                        [self.songDataArr removeAllObjects];
                       [_myTableView reloadData];
                        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(hiddenTableView)]) {
                            [_ChangeChatDele hiddenTableView];
                        }
                        return;
                    }
                }
                if (self.songDataArr.count > 1)
                {
                    NSRange OneRange = [speakText11 rangeOfString:@"YI"];
                    if(OneRange.location != NSNotFound)
                    {
                        MusicModel *model = self.songDataArr[0];
                        speakText = [NSString stringWithFormat:@"准备播放第1首：%@",model.songName];
                        _n = 0;
                        _step = 100;
                        [self speakText:speakText];
                        return;
                    }
                    NSRange TwoRange = [speakText11 rangeOfString:@"ER"];
                    if(TwoRange.location != NSNotFound)
                    {
                        if (self.songDataArr.count >= 2)
                        {
                            MusicModel *model = self.songDataArr[1];
                            speakText = [NSString stringWithFormat:@"准备播放第2首：%@",model.songName];
                            _n = 1;
                            _step = 100;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几首或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    NSRange ThreeRange = [speakText11 rangeOfString:@"SAN"];
                    if(ThreeRange.location != NSNotFound)
                    {
                        if (self.songDataArr.count >= 3)
                        {
                            MusicModel *model = self.songDataArr[2];
                            speakText = [NSString stringWithFormat:@"准备播放第3首：%@",model.songName];
                            _n = 2;
                            _step = 100;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几首或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    NSRange FourRange = [speakText11 rangeOfString:@"SI"];
                    if(FourRange.location != NSNotFound)
                    {
                        if (self.songDataArr.count >= 4)
                        {
                            MusicModel *model = self.songDataArr[3];
                            speakText = [NSString stringWithFormat:@"准备播放第4首：%@",model.songName];
                            _n = 3;
                            _step = 100;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几首或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    NSRange FireRange = [speakText11 rangeOfString:@"WU"];
                    if(FireRange.location != NSNotFound)
                    {
                        if (self.songDataArr.count >= 5)
                        {
                            MusicModel *model = self.songDataArr[4];
                            speakText = [NSString stringWithFormat:@"准备播放第5首：%@",model.songName];
                            _n = 4;
                            _step = 100;
                            [self speakText:speakText];
                        }
                        else
                        {
                            speakText = @"超出范围，请说第几首或者取消。";
                            [self speakText:speakText];
                        }
                        return;
                    }
                    NSRange QXRange = [firstText rangeOfString:@"QX"];
                    if(QXRange.location != NSNotFound)
                    {
                        speakText = LoadStr2;
                        _step = First;
                        isCanRetain = YES;
                        isCanZero = YES;
//                        [self speakText:speakText];
                        [self.songDataArr removeAllObjects];
                        [_myTableView reloadData];
                        if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(hiddenTableView)]) {
                            [_ChangeChatDele hiddenTableView];
                        }
                        return;
                    }
                }
                speakText = @"我不明白您的意思，请说第几首或者取消。";
                [self speakText:speakText];
                return;
            }
        }
    }
}

//搜索导航信息
-(void)searchAddress
{
    DISPATCH_ON_MAIN_THREAD(^{
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_myTableView registerNib:[UINib nibWithNibName:@"dialogueAddressCell" bundle:nil] forCellReuseIdentifier:@"dialogueAddressCell"];
        self.myTableView.estimatedRowHeight = 60; //这个值写个多少也没事，但是一定要有
        self.myTableView.rowHeight = UITableViewAutomaticDimension;
        
    })
    
    BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = @"";
    if (cityStr!= nil)
    {
        option.cityname = cityStr;
    }else {
        option.cityname = @"深圳市";//[UDPManager sharedInstance].addressDetailStr;
    }
    
    NSLog(@"option.cityname = %@",option.cityname);
    
 
    option.keyword = addressStr;
    BOOL flag = [_searcher suggestionSearch:option]; //触发BMKSuggestionSearchDelegate方法
    if(flag)
    {
        NSLog(@"语音:建议检索发送成功");
    }
    else
    {
        NSLog(@"语音:建议检索发送失败");
    }
}

#pragma mark --- BMKSuggestionSearchDelegate

//返回suggestion搜索结果
- (void)onGetSuggestionResult:(BMKSuggestionSearch *)searcher result:(BMKSuggestionResult *)result errorCode:(BMKSearchErrorCode)error
{
    doIngLabel.text = @"搜索地址结束";
    if (_step ==  First || ![newMusic shareInstance].isSpeaking) {
        return;
    }
    
    if (error == BMK_SEARCH_NO_ERROR) //搜索结果正常
    {
        [dataArr removeAllObjects];
        for (int i = 0;  i < result.ptList.count; i++)
        {
            TIPmodel *model = [[TIPmodel alloc] init];
            model.keyString = result.keyList[i];
            model.addressString = [NSString stringWithFormat:@"%@%@",result.cityList[i],result.districtList[i]];
            NSValue *va = result.ptList[i];
            
            
            CLLocationCoordinate2D coordinate;
            [va getValue:&coordinate];
            model.latitude = coordinate.latitude;
            model.longitude = coordinate.longitude;
            
            if (model.addressString != nil && model.latitude != 0. && ![model.addressString isEqualToString: @""]) {
                [dataArr addObject:model];
            }
            NSLog(@"model.keyString = %@ model.addressString = %@,model.latitude = %f",model.keyString,model.addressString,model.latitude);
        }
        if (dataArr.count > 0)
        {
           
            
            
            if (dataArr.count == 1)
            {
                NSString *str1 = @"";
                for (TIPmodel *model in dataArr)
                {
                    str1 = [NSString stringWithFormat:@"%@。",str1,model.keyString];
                }
                speakText = [NSString stringWithFormat:@"已为您搜索到%@%@",str1,@"请说确定或者取消。"] ;
                _step = Three;
                isCanSpeak = YES;
                tableReload = YES;
                [self speakText:speakText];
            }
            else
            {
                NSString *str1 = @"";
                int a = 1;
                if (dataArr.count > 5)
                {
                    for (int i = 0; i < 5; i++)
                    {
                        TIPmodel *model = dataArr[i];
                                                str1 = [NSString stringWithFormat:@"%@第%d个：%@。",str1,a,model.keyString];
                        a++;
                        
                        speakText = [NSString stringWithFormat:@"搜索到5条记录。%@%@",str1,@"请说第几个或者取消。"];
                    }
                }
                else
                {
                    for (TIPmodel *model in dataArr)
                    {
                        str1 = [NSString stringWithFormat:@"%@%d个：%@的%@。",str1,a,model.addressString,model.keyString];
                        a++;
                        speakText = [NSString stringWithFormat:@"搜索到%d条记录。%@%@",(int)dataArr.count,str1,@"请说第几个或者取消。"];
                    }
                }
                _step = Three;
                isCanSpeak = YES;
                tableReload = YES;
                [self speakText:speakText];
            }
        }
    }
    else
    {
        [dataArr removeAllObjects];
        speakText = @"搜索结果异常！请详细说导航到哪里？";
        if (_step != 31 || _step != 32|| _step != 33) {
            _step = 31;
        }
        isCanRetain = YES;
        isCanZero = YES;
        isCanSpeak = YES;
        [self speakText:speakText];
    }
}

//搜索电话本
-(void)searchAddress2
{
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.rowHeight = 90;
    [phoneDataArr removeAllObjects];
    
    
    
    if (isStep32) {   //人名本地直接搜索  拼音前两位
        NSString *teleStr = [ChineseToPinyin csqpinyinFromChinese:addressStr];
        for (TIPmodel *model in contactArray)
        {
            if ([model.twoCharStr rangeOfString:teleStr].location != NSNotFound)
            {
                [phoneDataArr addObject:model];
            }
        }
    }else{       //科大讯飞返回人名
        for (TIPmodel *model in contactArray)
        {
            if ([model.keyString rangeOfString:addressStr].location != NSNotFound)
            {
                [phoneDataArr addObject:model];
            }
        }
    }
    
    
    if (phoneDataArr.count == 1)
    {
        NSString *str1 = @"";
        for (TIPmodel *model in phoneDataArr)
        {
            str1 = [NSString stringWithFormat:@"%@%@的号码%@。",str1,model.keyString,model.addressString];
        }
        //   speakText = [NSString stringWithFormat:@"已为您搜索到，%@",@"请说确定或者取消。"] ; 不报号码
        speakText = [NSString stringWithFormat:@"已为您搜索到%@，%@",str1,@"请说确定或者取消."] ; // 报号码
        _step = Three;
        isCanSpeak = YES;
        tableReload = YES;
        [self speakText:speakText];
    }
    else if (phoneDataArr.count > 1)
    {
        NSString *str1 = @"";
        int a = 1;
        for (TIPmodel *model in phoneDataArr)
        {
            str1 = [NSString stringWithFormat:@"%@第%d个：%@的号码%@。",str1,a,model.keyString,model.addressString];
            a++;
        }
        speakText = [NSString stringWithFormat:@"搜索到%d条记录。%@%@",(int)phoneDataArr.count,str1,@"请说第几个或者取消."]; //报号码
        _step = Three;
        isCanSpeak = YES;
        tableReload = YES;
        [self speakText:speakText];
    }
    else
    {
        [phoneDataArr removeAllObjects];
        speakText = @"未搜索到，请说“打电话给谁”";
        if (_step != 31 || _step != 32|| _step != 33) {
            _step = 32;
        }
        isCanRetain = YES;
        isCanZero = YES;
        isCanSpeak = YES;
        [self speakText:speakText];
    }
}

//搜索歌曲
-(void)searchAddress3
{
    doIngLabel.text = @"搜索歌曲结束";
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MusicCell" bundle:nil] forCellReuseIdentifier:@"MusicCell"];
    self.myTableView.estimatedRowHeight = 44; //这个值写个多少也没事，但是一定要有
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    [self.songDataArr removeAllObjects];
    
    NSString *urlStr = [NSString stringWithFormat:SONGLIST,addressStr];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
     {
         
         if (![newMusic shareInstance].isSpeaking) {
             return ;
         }
         NSString *longStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         longStr = [longStr stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
         NSData *longData = [longStr dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:longData options:NSJSONReadingMutableContainers error:nil];
         NSArray *arr = dic[@"abslist"];
         for (NSDictionary *d in arr)
         {
             MusicModel *model = [[MusicModel alloc] init];
             model.songId = d[@"MUSICRID"];
             model.songName = [d[@"SONGNAME"] stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
             model.artist = [d[@"ARTIST"] stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
             [self.songDataArr addObject:model];
         }
         
         if (self.songDataArr.count == 1)
         {
             MusicModel *model = self.songDataArr[0];
             speakText = [NSString stringWithFormat:@"准备播放第1首：%@",model.songName];
             speakText = @"准备进入播放界面...";
             _n = 0;
             _step = 100;
             isCanSpeak = YES;
             tableReload = YES;
             [self speakText:speakText];
         }
         else if (self.songDataArr.count > 1)
         {
             
             MusicModel *model = self.songDataArr[0];
             speakText = [NSString stringWithFormat:@"准备播放第1首：%@",model.songName];
             speakText = @"准备进入播放界面...";
             _n = 0;
             _step = 100;
             isCanSpeak = YES;
             tableReload = YES;
             [self speakText:speakText];
         }
         else
         {
             [self.songDataArr removeAllObjects];
             speakText = @"未搜索到，您想听谁的歌曲？";
             if (_step != 31 || _step != 32|| _step != 33) {
                 _step = First;
             }
             isCanRetain = YES;
             isCanZero = YES;
             isCanSpeak = YES;
             [self speakText:speakText];
         }
     }];
}



//导航
-(void)sendNai:(TIPmodel *)tip
{
    if ([AppData useMapType] == 1)
    {
        NSString *stringURL = [[NSString stringWithFormat:@"baidumap://map/navi?location=%.8f,%.8f&coord_type=bd09ll",tip.latitude, tip.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if([AppData useMapType] == 3)
    {
        
        NSLog(@"苹果地图导航  lat %f lng %f",USERMANAGER.mapDetial.userCoordinate.latitude,USERMANAGER.mapDetial.userCoordinate.longitude);
            NSString *str = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=%f,%f",tip.latitude,tip.longitude,USERMANAGER.mapDetial.userCoordinate.latitude,USERMANAGER.mapDetial.userCoordinate.longitude];
            NSURL *url = [NSURL URLWithString:str];
            [[UIApplication sharedApplication] openURL:url];
        
    }
    else if([AppData useMapType] == 2)
    {
        CLLocationCoordinate2D _userCoordinate;
        _userCoordinate.latitude = tip.latitude;
        _userCoordinate.longitude = tip.longitude;
        _userCoordinate = [JZLocationConverter CSQbd09ToWgs84:_userCoordinate];
        
        NSString *stringURL = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=broker&backScheme=openbroker2&poiname=%@&poiid=BGVIS&lat=%.8f&lon=%.8f&dev=1&style=2",tip.addressString,_userCoordinate.latitude,_userCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }    
    [_iFlySpeechSynthesizer stopSpeaking];
//    _iFlySpeechSynthesizer.delegate = nil;
    
    [self changeCA2];
//    [OnekeyVoiceViewController destroyInstance];
      self.isEnterOnekeyVoiceVC = NO;
//    APPDELEGATE.isFromOnekeyVoiceVCBack = YES;
//    [self.navigationController popViewControllerAnimated:YES];
}

//打电话
-(void)sendNai2:(TIPmodel *)tip
{
    
    tip.addressString = [[tip.addressString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    NSMutableString *strPhone = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",tip.addressString];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhone]];
//    [self back];
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoice)]) {
        [_ChangeChatDele cancelVoice];
    }
}

//播放歌曲
-(void)sendNai3:(MusicModel *)model
{
    NSString *urlStr = [NSString stringWithFormat:@"http://antiserver.kuwo.cn/anti.s?type=convert_url&format=aac&response=url&rid=%@&key=YUFDSAFDSABFEELIENNDGT",model.songId];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
     {
         NSString *songUrl = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
         [_player.currentItem removeObserver:self forKeyPath:@"status"];
         _item = nil;
         _player = nil;
         _item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:songUrl]];
         _player = [[AVPlayer alloc] initWithPlayerItem:_item];
         [_player play];
         self.isPlayNetMusic = YES;
         
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_item];
         [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
     }];
}

-(void)itemDidPlayToEndTime:(NSNotification *)noti
{
    _step = 101;
    if (_n == self.songDataArr.count - 1)
    {
        _n = -1;
        MusicModel *model = self.songDataArr[_n + 1];
        speakText = [NSString stringWithFormat:@"播放完毕，重新播放第1首：%@",model.songName];
        [self speakText:speakText];
        return;
    }
    MusicModel *model = self.songDataArr[_n + 1];
    speakText = [NSString stringWithFormat:@"播放结束，准备播放下一首：%@",model.songName];
    [self speakText:speakText];
}

//KVO响应方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"] && object == _player.currentItem)
    {
        if ([change[@"new"] integerValue] == AVPlayerItemStatusReadyToPlay)
        {
            CMTime totalTime = _player.currentItem.duration;
            int t = (int)totalTime.value / totalTime.timescale;
            NSString *totalTimeStr = [NSString stringWithFormat:@"%02d:%02d",t / 60 % 60,t % 60];
            [self.voiceMusicDict setObject:totalTimeStr forKey:@"VoiceMusicTotalTime"];
            NSLog(@"语音:音乐总时间:totalTimeStr = %@",totalTimeStr);
            [self.voiceMusicDict setObject:@"00:00" forKey:@"VoiceMusicCurrentTime"];
            
            if (!self.isNetMusic)
            {
                self.isNetMusic = YES;
                self.netMusicArrM = self.songDataArr;
//                MusicViewController *musicVC = [MusicViewController shareInstance];
//                musicVC.n = _n;
//                if (!APPDELEGATE.isLink)
//                {
//                    [musicVC showAppModeUI:0];
//                }
//                else
//                {
////                    [APPDELEGATE.mMediaManager close];
////                    [APPDELEGATE.globalManager close];
////                    APPDELEGATE.mMediaManager = nil;
////                    APPDELEGATE.globalManager = nil;
//                }
//                [self.navigationController pushViewController:musicVC animated:NO];
            }
            
            CMTime time = CMTimeMake(1, 1);
            __weak typeof(self) weakSelf = self;
            [_player addPeriodicTimeObserverForInterval:time queue:nil usingBlock:^(CMTime time)
             {
                 CMTime currentTime = weakSelf.player.currentItem.currentTime;
                 x = currentTime.value;
                 y = currentTime.timescale;
                 if (currentTime.value < 0)
                 {
                     x = -currentTime.value;
                 }
                 if (currentTime.timescale < 0)
                 {
                     y = -currentTime.timescale;
                 }
                 int c = (int)(x / y);
                 NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d",c / 60 % 60,c % 60];
                 [self.voiceMusicDict setObject:currentTimeStr forKey:@"VoiceMusicCurrentTime"];
                 NSLog(@"语音:音乐当前播放时间:c = %d，currentTimeStr = %@",c,currentTimeStr);
             }];
        }
    }
}

//- (void)createPoiResponse:(ResponseBase *)sender
//{
//    CreatePoiResponse *response = (CreatePoiResponse *)sender;
//
//    if ([response isSuccess])
//    {
////        [UIUtil showToast:@"导航已发送" inView:self.view];
//
//        _taskID = [NSString stringWithFormat:@"%ld", (long)response.taskID];
//
//        double delayInSeconds = 1.0f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                       {
//
//                       });
//    }
//    else
//    {
//        if (ResponseErrorNoInternet == response.errorCode)
//        {
//            [UIUtil showToast:L(@"NoInternet") inView:SELFVIEW];
//        }
//        else if (nil != response.errorDesc && response.errorDesc.length > 0)
//        {
//            [UIUtil showToast:response.errorDesc inView:SELFVIEW];
//        }
//        else
//        {
//            [UIUtil showToast:L(@"HintRequestFailed") inView:SELFVIEW];
//        }
//    }
//}

#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tag == 1)
    {
        if (dataArr.count <= 5)
        {
            return dataArr.count;
        }
        else
        {
            return 5;
        }
    }
    if (self.tag == 2)
    {
        
        return phoneDataArr.count;
    }
    if (self.tag == 3)
    {
        if (self.songDataArr.count <= 20)
        {
            return self.songDataArr.count;
        }
        else
        {
            return 20;
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tag == 2)
    {
        return 44;
    }
    else
        {
            return 60;
        }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tag == 1)
    {
     
        static NSString *tipCellIdentifier = @"dialogueAddressCell";
        
        dialogueAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
        
//        if (cell == nil)
//        {
//            cell = [[dialogueAddressCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tipCellIdentifier];
//        }
        cell.backgroundColor = [UIColor clearColor];
        TIPmodel *tip = dataArr[indexPath.row];
        cell.addressLabel.text = [NSString stringWithFormat:@"%@",tip.keyString];
//        cell.textLabel.textColor = [UIColor whiteColor];
        cell.lineLabel.text = tip.addressString;
        cell.longLabel.text = @"";
        cell.numberLabel.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
//        cell.detailTextLabel.textColor = [UIColor whiteColor];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 1, cell.contentView.frame.size.width, 1)];
//        label.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [cell.contentView  addSubview:label];
        return cell;
    }
    else if (self.tag == 2)
    {
        static NSString *identifier = @"FHXTmoreSelectTableViewCell";
        FHXTmoreSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[FHXTmoreSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        TIPmodel *tip = phoneDataArr[indexPath.row];
        cell.nameLabel.text = tip.keyString;
        cell.addressLabel.text = tip.addressString;
        
        cell.backgroundColor = [UIColor clearColor];
//        cell.nameLabel.textColor = [UIColor whiteColor];
//        cell.addressLabel.textColor = [UIColor whiteColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else if (self.tag == 3)
    {
        MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MusicCell"];
        MusicModel *model = self.songDataArr[indexPath.row];
        cell.songNameLabel.text = [NSString stringWithFormat:@"%d：%@",(int)indexPath.row + 1,model.songName];
        cell.artistLabel.text = [NSString stringWithFormat:@"歌手:%@",model.artist];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else
    {
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tag == 1)
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        TIPmodel *tip = dataArr[indexPath.row];
        speakText = [NSString stringWithFormat:@"选择了第%d个：%@，正在打开地图...",(int)indexPath.row + 1,tip.keyString];
        _n = (int)indexPath.row;
        _step = 98;
        [self speakText:speakText];
    }
    if (self.tag == 2)
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        TIPmodel *tip = phoneDataArr[indexPath.row];
        if (phoneDataArr.count == 1)
        {
            speakText = [NSString stringWithFormat:@"正在给%@打电话，请点击呼叫键。",tip.keyString];
        }
        else
        {
            speakText = [NSString stringWithFormat:@"选择了第%d个，正在给%@打电话，请点击呼叫键。",(int)indexPath.row + 1,tip.keyString];
        }
        _n = (int)indexPath.row;
        _step = 99;
        [self speakText:speakText];
    }
    if (self.tag == 3)
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        MusicModel *model = self.songDataArr[indexPath.row];
        if (self.songDataArr.count == 1)
        {
            speakText = [NSString stringWithFormat:@"准备播放：%@",model.songName];
        }
        else
        {
            speakText = [NSString stringWithFormat:@"准备播放第%d首：%@",(int)indexPath.row + 1,model.songName];
        }
        _n = (int)indexPath.row;
        _step = 100;
        [self speakText:speakText];
    }
}

//点击音乐界面网络的cell
-(void)playNetMusic:(NSInteger)row
{
    MusicModel *model = self.songDataArr[row];
    if (self.songDataArr.count == 1)
    {
        speakText = [NSString stringWithFormat:@"准备播放：%@",model.songName];
    }
    else
    {
        speakText = [NSString stringWithFormat:@"准备播放第%d首：%@",(int)row + 1,model.songName];
    }
    _n = (int)row;
    _step = 100;
    [self speakText:speakText];
}

//播放/暂停
-(void)playOrPuse
{
    if (_player.timeControlStatus == AVPlayerTimeControlStatusPlaying)
    {
        [_player pause];
        self.isPlayNetMusic = NO;
    }
    else if (_player.timeControlStatus == AVPlayerTimeControlStatusPaused)
    {
        [_player play];
        self.isPlayNetMusic = YES;
    }
}

//上一曲
-(void)last
{
    _n--;
    if (_n == -1)
    {
        _n = self.songDataArr.count - 1;
    }
//    MusicViewController *musicVC = [MusicViewController shareInstance];
//    [musicVC netTableViewSelectRow:_n];
//    MusicModel *model = self.songDataArr[_n];
//    [self sendNai3:model];
}

//下一曲
-(void)next
{
    _n++;
    if (_n == self.songDataArr.count)
    {
        _n = 0;
    }
//    MusicViewController *musicVC = [MusicViewController shareInstance];
//    [musicVC netTableViewSelectRow:_n];
//    MusicModel *model = self.songDataArr[_n];
//    [self sendNai3:model];
}

- (void)initSynthesizer
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil)
    {
        return;
    }
    //合成服务单例
    if (_iFlySpeechSynthesizer == nil)
    {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    _iFlySpeechSynthesizer.delegate = self;
    //设置语速1-100
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //设置音量1-100
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //设置音调1-100
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //设置采样率
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //设置文本编码格式
    [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    [_iFlySpeechSynthesizer setParameter:@"0" forKey:[IFlySpeechConstant PLAYER_INIT]];
    
    NSDictionary *languageDic = @{@"Guli":@"text_uighur", //维语
                                  @"XiaoYun":@"text_vietnam", //越南语
                                  @"Abha":@"text_hindi", //印地语
                                  @"Gabriela":@"text_spanish", //西班牙语
                                  @"Allabent":@"text_russian", //俄语
                                  @"Mariane":@"text_french"}; //法语
    
    NSString *textNameKey = [languageDic valueForKey:instance.vcnName];
    NSString *textSample = nil;
    
    if(textNameKey && [textNameKey length] > 0)
    {
        textSample = NSLocalizedStringFromTable(textNameKey, @"tts/tts", nil);
    }
    else
    {
        textSample = NSLocalizedStringFromTable(@"text_chinese", @"tts/tts", nil);
    }
    
    if (![USER_PLIST boolForKey:@"URLOK"]) {
        isGetUrl = YES;
        [_iFlySpeechSynthesizer synthesize:LoadStr toUri:playUrl];
    }

}

/**
 设置识别参数
 ****/
-(void)initUnderstander
{
    //语义理解单例
    if (_iFlySpeechUnderstander == nil)
    {
        _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    }
    
    _iFlySpeechUnderstander.delegate = self;
    
    if (_iFlySpeechUnderstander != nil)
    {
        IATConfig *instance = [IATConfig sharedInstance];
        //参数意义与IATViewController保持一致，详情可以参照其解释
        [_iFlySpeechUnderstander setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        [_iFlySpeechUnderstander setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        [_iFlySpeechUnderstander setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        [_iFlySpeechUnderstander setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]])
        {
            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            [_iFlySpeechUnderstander setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }
        else if ([instance.language isEqualToString:[IATConfig english]])
        {
            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        [_iFlySpeechUnderstander setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        [_iFlySpeechUnderstander setParameter:@"0" forKey:[IFlySpeechConstant RECORDER_INIT]];
    }
    //设置为麦克风输入语音
    [_iFlySpeechUnderstander setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
}

-(void)getContact
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] >= 9.0)
    {
        //1.获取授权状态
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        
        //2.判断授权状态
        if (status != CNAuthorizationStatusAuthorized) //没有授权
        {
            [self setTheCurrentAddressBookEnvironment];
        }
        else //已经授权
        {
//            DISPATCH_ON_GROUP_THREAD(^{
                [self getContactPeople];
                
//            })
        
        }
    }
    else
    {
        //1.获取授权状态
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        
        //2.判断授权状态
        if (status != kABAuthorizationStatusAuthorized) //没有授权
        {
            [self setTheCurrentAddressBookEnvironment2];
        }
        else //已经授权
        {
            [self getContactPeople2];
        }
    }
}

//设置权限(ios9.0以上)
- (void)setTheCurrentAddressBookEnvironment
{
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
         if (granted)
         {
//             DISPATCH_ON_GROUP_THREAD(^{
                 [self getContactPeople];
                 
//             })
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:@"请在设置中打开访问权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
             [alert show];
         }
     }];
}


- (void)getContactPeople
{
    //3.创建录对象
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    //4.创建获取通信录的请求对象
    //4.1.拿到所有打算获取的属性对应的key
    NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    //4.2.创建CNContactFetchRequest对象
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    
    //5.遍历所有的联系人
    [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop)
     {
         //5.1.获取联系人的姓名
         NSString *lastname = contact.familyName;
         NSString *firstname = contact.givenName;
         NSLog(@"语音:通讯录联系人姓名 = %@%@",lastname,firstname);
         //5.2.获取联系人的电话号码
         NSArray *phoneNums = contact.phoneNumbers;
         if (phoneNums.count == 0) {
             TIPmodel *modle = [[TIPmodel alloc] init];
             modle.keyString = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
             modle.addressString = @"";
             [contactArray addObject:modle];
         }
         for (CNLabeledValue *labeledValue in phoneNums)
         {
             //5.2.1.获取电话号码的key
             NSString *phoneLabel = labeledValue.label;
             //5.2.2.获取电话号码
             CNPhoneNumber *phoneNumer = labeledValue.value;
             NSString *phoneValue = phoneNumer.stringValue;
             NSLog(@"语音:通讯录联系人电话号码的key = %@，电话号码 = %@",phoneLabel,phoneValue);
             
             TIPmodel *modle = [[TIPmodel alloc] init];
             modle.keyString = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
             modle.addressString = phoneValue;
             [contactArray addObject:modle];
         }
     }];

    }

//设置权限(ios9.0以下)
- (void)setTheCurrentAddressBookEnvironment2
{
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                             {
                                                 if (granted)
                                                 {
                                                     
//                                                     DISPATCH_ON_GROUP_THREAD(^{
                                                         [self getContactPeople2];
//                                                     })
                                                 }
                                                 else
                                                 {
                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"授权失败" message:@"请在设置中打开访问权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                                                     [alert show];
                                                 }
                                             });
}

- (void)getContactPeople2
{
    //3.创建通信录对象
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    //4.获取所有的联系人
    CFArrayRef peopleArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex peopleCount = CFArrayGetCount(peopleArray);
    
    //5.遍历所有的联系人
    for (int i = 0; i < peopleCount; i++)
    {
        //5.1.获取某一个联系人
        ABRecordRef person = CFArrayGetValueAtIndex(peopleArray, i);
        //5.2.获取联系人的姓名
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSLog(@"语音:通讯录联系人姓名 = %@%@",lastName,firstName);
        //5.3.获取电话号码
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex phoneCount = ABMultiValueGetCount(phones);
        for (int i = 0; i < phoneCount; i++)
        {
            //5.3.1.获取电话对应的key
            NSString *phoneLabel = (__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
            //5.3.2.获取电话号码
            NSString *phoneValue = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            NSLog(@"语音:通讯录联系人电话号码的key = %@，电话号码 = %@",phoneLabel,phoneValue);
            
            TIPmodel *modle = [[TIPmodel alloc]init];
            modle.keyString = [NSString stringWithFormat:@"%@%@",lastName ,firstName];
            modle.addressString = phoneValue;
            [contactArray addObject:modle];
        }
        CFRelease(phones);
    }
    CFRelease(addressBook);
    CFRelease(peopleArray);
}

- (void)uploadContact
{
    //获取联系人
    IFlyContact *iFlyContact = [[IFlyContact alloc] init];
    NSString *contact = [iFlyContact contact];
    [_uploader setParameter:@"uup" forKey:[IFlySpeechConstant SUBJECT]];
    [_uploader setParameter:@"contact" forKey:[IFlySpeechConstant DATA_TYPE]];
    [_uploader uploadDataWithCompletionHandler:^(NSString * grammerID, IFlySpeechError *error)
     {
         [self onUploadFinished:error];
         
     } name:@"contact" data: contact];
}

- (void)onUploadFinished:(IFlySpeechError *)error
{
    if ([error errorCode] == 0)
    {
        NSLog(@"语音:上传成功");
    }
    else
    {
        NSLog(@"语音:上传失败");
    }
}


-(void)changeCA
{
 //设备
    DISPATCH_ON_GROUP_THREAD(^{
        if(IOS_VERSION<10.0) {
            if ([AVAudioSession sharedInstance].categoryOptions != 12) {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                                 withOptions:12    error:nil];
            }
        }
    })
    
   
    [[newMusic shareInstance]changeOutSpeak];
    
    //改变输出源
    for (AVAudioSessionPortDescription* desc in [[AVAudioSession sharedInstance] availableInputs]) {
        printf("outOrIn        : inPut %s\n",[desc.portType UTF8String]);
//        if ([desc.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
//            [[AVAudioSession sharedInstance] setPreferredInput:desc error:nil];
//        }
    }

    for (AVAudioSessionPortDescription *mDes in [[AVAudioSession sharedInstance] currentRoute].outputs){
        printf("outOrIn        : outPort %s\n",[mDes.portType UTF8String]);
        //hfp蓝牙规范 支持边输入边输出 不同于A2DP 和hsp
        if ([mDes.portType isEqualToString:@"BluetoothA2DPOutput"] ) {
            //上面通话模式打开扬声器输出声音
        }
    }
 
}

-(void)changeCA2
{
  
    [self getVoiceNow];
    
    if(IOS_VERSION<10.0) {
        double delayInSeconds = 0.05f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {

//        if ([AVAudioSession sharedInstance].categoryOptions != 12) {
//            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
//                                             withOptions:12    error:nil];
//        }
                           [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback    error:nil];
                    });
    }
    
    
//
//    if (IOS_VERSION < 10.1) {
//        AVAudioSession *session = [AVAudioSession sharedInstance];
//        NSError *setCategoryError = nil;
//        [session setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
//        NSError *activationError = nil;
//        [session setActive:YES error:&activationError];
//        NSLog(@"AVAudioSessionCategory————playBack");
//    }else{
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetoothA2DP error:nil];//AVAudioSessionCategoryOptionAllowBluetoothA2DP AVAudioSessionCategoryOptionAllowBluetooth
//        NSLog(@"AVAudioSessionCategory————PlayAndRecordAllowBluetoothA2DP");
//    }
    [self getVoice];
    

}
-(void)changeMIC{
    if(IOS_VERSION<10.0) {
    
    /** 输出和麦克风都在手机 */
        if ([newMusic shareInstance].isSpeaking) {
           
        
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:nil];
        }
    }
//    for (AVAudioSessionPortDescription* desc in [[AVAudioSession sharedInstance] availableInputs]) {
//        printf("outOrIn        : inPut %s\n",[desc.portType UTF8String]);
//                        if ([desc.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
//                            NSError*error;
//                            [[AVAudioSession sharedInstance] setPreferredInput:desc error:&error];
//                            if (error != nil){
//                                printf("outOrIn   设置失败%@",error.userInfo);
//                            }
//                            else{
//                                printf("outOrIn   设置成功");
//                            }
//                        }
//    }

    
    
    
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    NSError *setCategoryError = nil;
//    
//    [session setCategory:AVAudioSessionCategoryPlayAndRecord
//             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
//                   error:&setCategoryError];
}
-(void)cancelVoiceNoVoice{
    if (_ChangeChatDele && [_ChangeChatDele respondsToSelector:@selector(cancelVoiceNoVoice)]) {
        [_ChangeChatDele cancelVoiceNoVoice];
    }
}
- (void)didReceiveMemoryWarning
{
//    [super didReceiveMemoryWarning];

}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}


@end
