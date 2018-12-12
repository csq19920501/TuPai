//
//  newMusic.h
//  WeiZhong_ios
//
//  Created by hk on 17/9/13.
//
//
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPMediaPlaylist.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MEdiaPlayer/MPNowPlayingInfoCenter.h>
#import <Foundation/Foundation.h>

#import "BluzDevice.h"
#import "BluzManager.h"
#import "BluzManagerData.h"
#import "GlobalManager.h"

#import "MusicBean.h"
typedef NS_OPTIONS(NSInteger, MusicState) {
    localPlay            = 1,
    localPause           = 2,
    uPlay                = 3,
    uPause               = 4,
    netPlay              = 5,
    netPause             = 6,
};
typedef enum {
    MODEUNKNOWN    = -1,
    MODELOCAL       = 1,
    MODEUHOST      = 2,
    MODENET     = 3,
    MODEUHOST_UhostLoad = 9, //U盘刚插入正在加载U盘歌曲的状态
    MODEUHOST_NotGoto = 10, //只刷新U盘列表 不跳转到U盘列表
}FuncModeNew;
@protocol NewMusicDelegate <NSObject>

-(void)changeSelectMusic:(NSInteger)selectMusicNum;
-(void)tableViewReloadData:(NSInteger)tableviewMode;

-(void)deselectTable;
@end
@protocol ChangeEnable <NSObject>

-(void)changeMainVCEnable;

@end

@interface newMusic : NSObject<ConnectDelegate,GlobalDelegate,MusicDelegate>
{
    AVAudioPlayer* _localMusicPlayer;
    AVPlayer *_netMusicPlayer;
}
@property(nonatomic,weak)id<NewMusicDelegate> NewMusicDele;
@property(nonatomic,weak)id<ChangeEnable> ChangeDele;
@property(nonatomic,strong)NSMutableArray *localMusicArray;
@property(nonatomic,strong)NSMutableArray *netMusicArray;
@property(nonatomic,strong)NSMutableArray *UhoustMusicArray;
@property(nonatomic,strong)NSMutableArray *BtArray;
@property(nonatomic,assign)MusicState musicState;// 当前音乐模式
@property(nonatomic,assign)MusicState saveMusicState;  //存储的音乐模式
@property(nonatomic,assign)BOOL isSpeaking;   //是否在语音

@property(nonatomic,assign)BOOL isHaveUhoust; //是否插入U盘
@property (assign, nonatomic) FuncModeNew MusicMode;


@property (strong, nonatomic) BluzDevice *mBluzConnector;
@property (strong, nonatomic) BluzManager *mMediaManager;
@property (strong, nonatomic) id<GlobalManager> globalManager;
@property (strong, nonatomic) id<MusicManager> musicManager;
@property (strong,nonatomic ) NSDictionary * linkingBT;
@property(nonatomic,strong) MusicBean * playingMusic;//当前播放歌曲
@property (nonatomic, strong) NSTimer *musicTimer;
@property(nonatomic,copy)NSString *nowPlayTime;
@property(nonatomic,copy)NSString *totalPlayTime;
@property(nonatomic,assign)float musicProgressFloat;//音乐播放百分比
@property(nonatomic,assign) int musicSelectNum;//当前播放歌曲序列号


@property(nonatomic,strong) MusicBean * netMusic;//网络当前播放歌曲
@property(nonatomic,strong) MusicEntry * uMusicSelect;//U盘当前播放歌曲
@property(nonatomic,strong) id timeObserver;//当前网络歌曲进度监听者


@property(nonatomic,assign)int uSongAllNum;//U盘全部数量
@property(nonatomic,assign)int uSongSelectNum;//u盘选中歌曲序列号
@property(nonatomic,assign)BOOL uSongChange;//u盘歌曲是否改变



//@property(nonatomic,assign)BOOL isLink;  //蓝牙是否连接
//@property(nonatomic,assign)BOOL isTelComing; //是否来电
//@property(nonatomic,assign)BOOL isEnterOnekeyVoiceVC; //是否进入语音
//@property(nonatomic,assign)BOOL isOneKeyEnterVoiceVC; //是否进入语音
//@property(nonatomic,assign)BOOL isMapNIL; //是否进入后台
//@property(nonatomic,assign)BOOL isCanVoice; //能否语音
//@property(nonatomic,assign)BOOL isTelBreak; //是否挂断
@property(nonatomic,strong)NSDictionary *blueDictionary; //连接蓝牙
@property(nonatomic,assign)BOOL isLegal; //是否正规检测结果

+(newMusic *)shareInstance;
-(void)SaveMusicState;
-(void)resumeMusicState;
-(void)musicPlay;
-(void)mustPlay;
-(void)musicPause;
-(void)musicPlayaAndPause;
-(void)musicNext;
-(void)musicPre;
-(void)palyMusic:(MusicBean*)musciBen;
-(void)loadNetMusic;
-(void)changeMusicValue:(CGFloat)value;

-(void)palyLocalMusic:(MusicBean *)musciBen;
-(void)playNetMusic:(MusicBean*)musicModel;
-(void)playUhoustMusic:(UInt32)UhoustSelect;
-(void)playUhoustMusic2:(MusicEntry*)entry;
-(void)setUhoustPlayMusic:(MusicEntry*)entry;

-(void)setFM:(NSString*)FMStr;
-(void)CTCallStateDisconnected;

-(void)loadLocalMusic;

-(void)duankailanya;
-(void)UhoustRefresh;

//打开扬声器防止听筒放歌曲
-(void)changeOutSpeak;
@end
