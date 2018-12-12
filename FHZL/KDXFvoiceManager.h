//
//  KDXFvoiceManager.h
//  WeiZhong_ios
//
//  Created by hk on 17/9/21.
//
//
#import "TIPmodel.h"
#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <UIKit/UIKit.h>
#import "iflyMSC/iflyMSC.h"
typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};


typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};
typedef NS_OPTIONS(NSInteger, Step) {
    First               = 1,
    Two                 = 2, //高异常分析需要的级别
    Three               = 3,
    Four                = 3,
    NinetyEight         = 98,
    NinetyNine          = 99,
    Hundred             = 100,
    HundredOne          = 101,
    NumberPhone         = 199,
};

@class IFlyDataUploader;
@class IFlySpeechSynthesizer;

@protocol ChangeChat <NSObject>

-(void)changeFirstStr:(NSString*)str :(BOOL)isDele;
-(void)changeSoundImage:(NSInteger)voiceLevel;
-(void)pushTableview;
-(void)hiddenTableView;
-(void)goToMusicVC:(BOOL)isGotoNet;
-(void)cancelVoice;
-(void)cancelVoiceNoVoice;
-(void)wakeUpVoice;
-(void)removeSpeakData;
@end

@interface KDXFvoiceManager : NSObject<IFlySpeechRecognizerDelegate,BMKSuggestionSearchDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BMKSuggestionSearch *_searcher;
}
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer; //语音合成对象
@property (nonatomic, strong) IFlyDataUploader *uploader; //数据上传对象
@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;
@property (nonatomic, assign) Step step;
@property (nonatomic, assign) BOOL isFromOnekeyVoiceVCBack;
@property (nonatomic, assign) BOOL isEnterOnekeyVoiceVC ;
@property (nonatomic, assign) BOOL isNetOK ;
//@property (nonatomic, assign) BOOL isEnterOnekeyVoiceVC ;
@property (nonatomic, assign) BOOL isNetMusic ;
@property (strong, nonatomic) NSMutableDictionary *voiceMusicDict; //存放语音歌曲的字典
@property (assign, nonatomic) BOOL isPlayNetMusic; //app是否正在播放网络音乐

@property (strong, nonatomic) NSMutableArray *netMusicArrM; //存放网络音乐的数组
@property (assign, nonatomic) NSInteger BTmusic; //蓝牙盒子播放音乐频道
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander; //语音语义理解对象

@property(nonatomic,assign)BOOL isLink;  //蓝牙是否连接
@property(nonatomic,assign)BOOL isTelComing; //是否来电

@property(nonatomic,assign)BOOL isOneKeyEnterVoiceVC; //是否进入语音
@property(nonatomic,assign)BOOL isMapNIL; //是否进入后台
@property(nonatomic,assign)BOOL isCanVoice; //能否语音
@property(nonatomic,assign)BOOL isTelBreak; //是否挂断

@property (nonatomic,strong)UITableView *myTableView;
@property (nonatomic,weak)id<ChangeChat>ChangeChatDele;
+(KDXFvoiceManager*)shareInstance;
-(void)firstStep;
-(void)back;
-(void)wakeUpVoice;
-(void)cancelVoiceNoVoice;
-(void)onPlayCompleted;
//导航
-(void)sendNai:(TIPmodel *)tip;
@end
