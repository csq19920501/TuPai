//
//  newMusic.m
//  WeiZhong_ios
//
//  Created by hk on 17/9/13.
//
//

#import "newMusic.h"
#import "MusicModel.h"
#import "NSString+ZHTime.h"
#import "MusicEntry.h"
#import "ZZXDataService.h"
#import "Header.h"
#import "AppData.h"
#import "UIUtil.h"
#import "KDXFvoiceManager.h"
//#import "KDXFvoiceManager.h"
@interface newMusic ()<AVAudioPlayerDelegate>
{
    int getPListFrom;
    int sendInt;
    BOOL isCanchangeFM;
    NSString *UUIDStr;
    NSData *IDSTR;
    NSString *IDStr;
    BOOL order; //自定义命令回调以及收到getBTcheck、ORDERYES通知时为YES
    int getOutNumber;
    int outNumber;
    int CHERKNUMBER;
    BOOL modeChangeIsCanSelectMusic;//是否主动恢复U盘模式
    BOOL isCanotSlider;//网络歌曲是否不能滑动生效
    BOOL isCanGoToUhouse;//能否跳转U盘歌曲
    int linkUhoustTimes;
    BOOL isGetData;//是否实时收到数据
    int  noGetDataInt;//没有到数据次数
    BOOL isCanSendNoti;
    int waitTime;//连接成功后续等待时间
}
@end

@implementation newMusic
+(newMusic*)shareInstance{
    static newMusic *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^
                  {
                      instance = [[[self class] alloc] init];
                  });
    return instance;
}
-(id)init{
    if (self = [super init]) {
        isCanSendNoti = YES;
        linkUhoustTimes = 0;
        _uSongChange = YES;
        sendInt = 0;
        isCanchangeFM = YES;
        _isSpeaking = NO;
        _localMusicArray = [NSMutableArray array];
        _netMusicArray = [NSMutableArray array];
        _UhoustMusicArray = [NSMutableArray array];
        _musicState = localPause;
        _MusicMode = MODELOCAL;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(duankailanya) name:@"duankailianjie2" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lianjielanya) name:@"lianjielanya" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(CTCallStateDisconnected) name:@"CTCallStateDisconnected" object:nil];
//多线程并行触发
//        dispatch_queue_t queue= dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);
//        
//        dispatch_async(queue, ^{
//            [self loadLocalMusic];
//        });
//        dispatch_async(queue, ^{
//        });
        
        dispatch_group_t group =  dispatch_group_create();
        
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadLocalMusic];// 执行1个耗时的异步操作
        });
        
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadNetMusic];// 执行1个耗时的异步操作
        });
        
//        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self initMediaManager];// 执行1个耗时的异步操作
//        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //添加timer需要放在主线程
            [self addProgressTimer]; // 等前面的异步操作都执行完毕后，回到主线程...
            
        });
    }
    return  self;
}
#pragma mark --- 手机音乐
-(void)loadLocalMusic{
    [_localMusicArray removeAllObjects];
    MPMediaQuery *myPlaylistsQuery = [MPMediaQuery songsQuery];
    NSArray *playlists = [myPlaylistsQuery collections];
    for (MPMediaPlaylist *playlist in playlists) {
        NSArray *array = [playlist items];
        for (MPMediaItem *song in array) {
            MusicBean * bean = [[MusicBean alloc] init];
            MPMediaItemArtwork *artwork = [song valueForProperty: MPMediaItemPropertyArtwork];
            UIImage *artworkImages = [artwork imageWithSize:CGSizeMake(320, 265)];
            if (artworkImages) {
                bean.m_musicCover = (UIImage *)artworkImages;
            } else {
                bean.m_musicCover = [UIImage imageNamed: MusicImage];
            }
            
            bean.m_musicName = [song valueForProperty: MPMediaItemPropertyTitle];
            
            NSURL* songURL = [song valueForProperty:MPMediaItemPropertyAssetURL];
            AVAsset* songAsset = [AVURLAsset URLAssetWithURL:songURL options:nil];
            NSString* lyrics = [songAsset lyrics];
            
            bean.m_Lyrics=lyrics;
            if(bean.m_Lyrics.length==0){
                bean.m_Lyrics=@"";
            }
            bean.m_url =  [song valueForProperty: MPMediaItemPropertyAssetURL];
            bean.m_AlbumTitle = [song valueForKey:MPMediaItemPropertyAlbumTitle];
            if(bean.m_AlbumTitle.length==0){
                bean.m_AlbumTitle = NSLocalizedString(@"unknown", nil);
            }
            bean.m_AlbumArtist=[song valueForKey:MPMediaItemPropertyAlbumArtist];
            if(bean.m_AlbumArtist.length==0){
                bean.m_AlbumArtist = NSLocalizedString(@"unknown", nil);
            }
            bean.m_singerName = [song valueForKey:MPMediaItemPropertyArtist];
            if(bean.m_singerName.length==0){
                bean.m_singerName = NSLocalizedString(@"unknown", nil);
            }
            //计算音乐文件所需要的时间
            CGFloat dblTotal=[[song valueForKey:MPMediaItemPropertyPlaybackDuration] floatValue];
            
            int seconds = (int)dblTotal;
            int minute = 0;
            if (seconds >= 60) {
                int index = seconds / 60;
                minute = index;
                seconds = seconds - index * 60;
            }
            bean.m_musicTime = [NSString stringWithFormat:@"%02d:%02d", minute, seconds];
            [bean setTotalTime:dblTotal];
            if (dblTotal >60) {
                [_localMusicArray addObject:bean];
                
                if (_localMusicArray.count == 1) {
                     [self setLocalMusicPlayer];
                    if (_ChangeDele && [_ChangeDele respondsToSelector:@selector(changeMainVCEnable)]) {
                        [_ChangeDele changeMainVCEnable];
                    }
                }
            }
            
        }
    }
   
    if (_ChangeDele && [_ChangeDele respondsToSelector:@selector(changeMainVCEnable)]) {
        [_ChangeDele changeMainVCEnable];
    }
    NSLog(@"newMusic加载完本地音乐%d首",_localMusicArray.count);
    
    if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
        [_NewMusicDele tableViewReloadData:MODELOCAL];
    }
}
-(void)setLocalMusicPlayer{
        if (_localMusicArray != nil) {
            if (_MusicMode != MODELOCAL) {
                NSError *error;
                MusicBean * musicModel = _localMusicArray[0];
                _localMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicModel.m_url error:&error];
                _localMusicPlayer.delegate = self;
                [_localMusicPlayer prepareToPlay];
            }else{
                if (_localMusicArray.count  != 0) {
                    _playingMusic = _localMusicArray[0];
                    _MusicMode = MODELOCAL;
                    _musicSelectNum = 0;
                    
                    NSError *error;
                    _localMusicPlayer.delegate = nil;
                    _localMusicPlayer = nil;
                    _localMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_playingMusic.m_url error:&error];
                    _localMusicPlayer.delegate = self;
                    [_localMusicPlayer prepareToPlay];
                    _totalPlayTime = [NSString stringWithTime:_localMusicPlayer.duration];
                }else{
                    
                }
            }
        }
}
-(void)palyLocalMusic:(MusicBean *)musciBen{
    _MusicMode = MODELOCAL;
    [_localMusicPlayer stop];
    _localMusicPlayer.delegate = nil;
    _localMusicPlayer = nil;
    
    NSError *error;
    _localMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musciBen.m_url error:&error];
    _localMusicPlayer.delegate = self;
    [_localMusicPlayer prepareToPlay];
    [_localMusicPlayer play];
    
    _playingMusic = musciBen;
    _musicState = localPlay;
    _totalPlayTime = [NSString stringWithTime:_localMusicPlayer.duration];
    _musicSelectNum = [_localMusicArray indexOfObject:musciBen];
    if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(changeSelectMusic:)]) {
        [_NewMusicDele changeSelectMusic:_musicSelectNum];
    }
    [self setupLockScreenInfo];
    
    if (![_localMusicPlayer isPlaying]) {
        [UIUtil showToast:@"不支持播放该音频格式" inView:SELFVIEW];
        [self musicNext];
    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [self musicNext];
    }
}



#pragma mark --- 网络音乐
-(void)loadNetMusic{
    if (_netMusicPlayer == nil) {
        //初始化_player
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:@""]];
        _netMusicPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    }
    
    NSData* netMusicData = [USER_PLIST objectForKey:@"NETmusic"];
    NSArray *netMusicArray  = [NSArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:netMusicData]];
    [_netMusicArray removeAllObjects];
    for (MusicModel *model in netMusicArray) {
        MusicBean *musicBean = [[MusicBean    alloc]init];
        musicBean.m_musicName = model.songName;
        musicBean.m_musicArtist = model.artist;
        musicBean.m_singerName = model.artist;
        musicBean.m_musicCover = [UIImage imageNamed: @"ic_launcher.png"];
        musicBean.m_url = [NSURL URLWithString:model.songId];
        [_netMusicArray addObject:musicBean];
    }
    NSLog(@"newMusic加载网络歌曲%d首",_netMusicArray.count);
    //    _musicState = netPause;
    if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
        [_NewMusicDele tableViewReloadData:MODENET];
    }
}

-(void)playNetMusic:(MusicBean*)musicModel{
    _MusicMode = MODENET;
    
    
    _playingMusic = musicModel;
    _musicState = netPlay;
    _musicSelectNum = [_netMusicArray indexOfObject:musicModel];
    NSLog(@"newMusic选中_musicSelectNum = %d",_musicSelectNum);
    
    if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(changeSelectMusic:)]) {
        [_NewMusicDele changeSelectMusic:_musicSelectNum];
    }
    
    isCanotSlider = YES;
    _nowPlayTime = @"00:00";
    _totalPlayTime = @"00:00";
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlStr = [NSString stringWithFormat:@"http://antiserver.kuwo.cn/anti.s?type=convert_url&format=aac&response=url&rid=%@&key=YUFDSAFDSABFEELIENNDGT",musicModel.m_url.absoluteString];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
         {
             
             NSString *songUrl = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"songUrl = %@",songUrl);
//             dispatch_async(dispatch_get_main_queue(), ^{
             
             
                [self removePlayStatus];
                [self removePlayLoadTime];
             
                 AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:songUrl]];
                 [_netMusicPlayer replaceCurrentItemWithPlayerItem:item];
                 
                 //刷新
                 [self reloadData:musicModel];
                 
                 //监听音乐播放完成通知
                 [self addNSNotificationForPlayMusicFinish];
                 
                 //开始播放
                 [_netMusicPlayer play];
                 
                 //监听播放器状态
                 [self addPlayStatus];
                 
                 //监听音乐缓冲进度
                 [self addPlayLoadTime];
                 
                 //监听音乐播放的进度
                 [self addMusicProgressWithItem:item];
                 
                 //音乐锁屏信息展示
                 [self setupLockScreenInfo];
                 
//             });
         }];
//    });
}
//移动滑块调整播放进度
-(void)sliderChangeNetMusic:(float)value{
//    if (!isCanotSlider) {
//        
//        //根据值计算时间
//        float time = value * CMTimeGetSeconds(_netMusicPlayer.currentItem.duration);
//        //跳转到当前指定时间
//        [_netMusicPlayer seekToTime:CMTimeMake(time, 1)];
//    }
}
//音乐锁屏信息展示
- (void)setupLockScreenInfo
{
//    return;
    // 1.获取锁屏中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    //初始化一个存放音乐信息的字典
    NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    // 2、设置歌曲名
    if (_playingMusic.m_musicName) {
        [playingInfoDict setObject:_playingMusic.m_musicName forKey:MPMediaItemPropertyAlbumTitle];
    }
    // 设置歌手名
    if (_playingMusic.m_musicArtist) {
        [playingInfoDict setObject:_playingMusic.m_musicArtist forKey:MPMediaItemPropertyArtist];
    }

    // 3设置封面的图片
    
   
    if (_playingMusic.m_musicCover != nil) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:_playingMusic.m_musicCover];
        [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    }else
    {
        UIImage * image = [UIImage imageNamed:MusicImage];
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    }
    
    // 4设置歌曲的总时长
    [playingInfoDict setObject:_totalPlayTime forKey:MPMediaItemPropertyPlaybackDuration];
    [playingInfoDict setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
    if (_MusicMode == MODELOCAL) {
        [playingInfoDict setObject:[NSNumber numberWithDouble:[_localMusicPlayer currentTime]] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
        [playingInfoDict setObject:[NSNumber numberWithDouble:[_localMusicPlayer duration]] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲总时间设置
    }
    if (_MusicMode == MODENET) {
        [playingInfoDict setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(_netMusicPlayer.currentItem.currentTime)] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
        [playingInfoDict setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(_netMusicPlayer.currentItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲总时间设置
    }
    
    
    //音乐信息赋值给获取锁屏中心的nowPlayingInfo属性
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
    
    // 5.开启远程交互
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];
    
//    if (playingInfoCenter) {
//        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
//        UIImage *image = [UIImage imageNamed:@"image"];
//        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
//        //歌曲名称
//        [songInfo setObject:@"深夜地下铁" forKey:MPMediaItemPropertyTitle];
//        //演唱者
//        [songInfo setObject:@"陶钰玉" forKey:MPMediaItemPropertyArtist];
//        //专辑名
//        [songInfo setObject:@"深夜地下铁" forKey:MPMediaItemPropertyAlbumTitle];
//        //专辑缩略图
//        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
//        [songInfo setObject:[NSNumber numberWithDouble:[audioY getCurrentAudioTime]] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
//        [songInfo setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
//        [songInfo setObject:[NSNumber numberWithDouble:[audioY getAudioDuration]] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲总时间设置
//        
//        //        设置锁屏状态下屏幕显示音乐信息
//        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
//    }
    

}

//监听音乐播放的进度
-(void)addMusicProgressWithItem:(AVPlayerItem *)item
{
    //移除监听音乐播放进度
    [self removeTimeObserver];
    __weak typeof(self) weakSelf = self;
    self.timeObserver =  [_netMusicPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        float current = CMTimeGetSeconds(time);
        //总时间
        float total = CMTimeGetSeconds(item.duration);
        if (current) {
            float progress = current / total;
            //更新播放进度条
            if (_musicState == netPlay || _musicState == netPause) {
                weakSelf.nowPlayTime = [weakSelf timeFormatted:current];
            }
        }
        [weakSelf setupLockScreenInfo];
    }];
}

//转换成时分秒
- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}
//移除监听音乐播放进度
-(void)removeTimeObserver
{
    if (self.timeObserver) {
        [_netMusicPlayer removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

-(void)reloadData:(MusicBean*)model{
//    _musicState = netPlay;
    _totalPlayTime = [NSString stringWithTime:CMTimeGetSeconds(_netMusicPlayer.currentItem.duration)];
//    _playingMusic = model;
    _netMusic = model;
}
//KVO监听音乐缓冲状态
-(void)addPlayLoadTime
{
    [_netMusicPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
//移除监听音乐缓冲状态
-(void)removePlayLoadTime
{
    if (_netMusic == nil) {return;}
    [_netMusicPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
//观察者回调
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context

{
    if ([keyPath isEqualToString:@"status"]) {
        switch (_netMusicPlayer.status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"未知转态");
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                isCanotSlider = NO;
                NSLog(@"准备播放");
            }
                break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"加载失败");
            }
                break;
                
            default:
                break;
        }
        
    }
    
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        NSArray * timeRanges = _netMusicPlayer.currentItem.loadedTimeRanges;
        //本次缓冲的时间范围
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //缓冲总长度
        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //音乐的总时间
        NSTimeInterval duration = CMTimeGetSeconds(_netMusicPlayer.currentItem.duration);
        _totalPlayTime = [NSString stringWithTime:duration];
        //计算缓冲百分比例
        NSTimeInterval scale = totalLoadTime/duration;
        //更新缓冲进度条
//        self.loadTimeProgress.progress = scale;
    }
}
-(void)addNSNotificationForPlayMusicFinish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_netMusicPlayer.currentItem];
}
-(void)playFinished:(NSNotification*)notification
{
    //播放下一首
    [self musicNext];
}
//通过KVO监听播放器状态
-(void)addPlayStatus
{
    [_netMusicPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}
//移除监听播放器状态
-(void)removePlayStatus
{
    if (_netMusic == nil) {
        
        return;}
    [_netMusicPlayer.currentItem removeObserver:self forKeyPath:@"status"];
}
//获取远程网络图片，如有缓存取缓存，没有缓存，远程加载并缓存
-(UIImage*)getMusicImageWithMusicId:(MusicModel*)model
{
    UIImage *image;
    //    NSString *key = [model.Id stringValue];
    //    UIImage *cacheImage = self.musicImageDic[key];
    //    if (cacheImage) {
    //        image = cacheImage;
    //    }else{
    //        //这里用了非常规的做法，仅用于demo快速测试，实际开发不推荐，会堵塞主线程
    //        //建议加载歌曲时先把网络图片请求下来再设置
    //        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.cover]];
    //        image =  [UIImage imageWithData:data];
    //        if (image) {
    //            [self.musicImageDic setObject:image forKey:key];
    //
    //        }
    //    }
    
    return image;
}




#pragma mark --- 音乐控制
-(void)SaveMusicState{
    _saveMusicState = _musicState;
    [self musicPause];
}
-(void)resumeMusicState{
    switch (_saveMusicState) {
        case localPlay:{
            
            [_localMusicPlayer play];
            _musicState = localPlay;
        }
            break;
        case localPause:
        {
            [[newMusic shareInstance].globalManager setMode:MODE_A2DP];
            [_localMusicPlayer pause];
            _musicState = localPause;
        }
            break;
        case netPause:{
            
            [_netMusicPlayer pause];
            _musicState = netPause;
            NSLog(@"newMusic暂停net");
        }
            break;
        case netPlay:{
            
            [_netMusicPlayer play];
            _musicState = netPlay;
            NSLog(@"newMusic播放net");
        }
            break;
        case uPlay:{
            
            [_globalManager setMode:MODE_UHOST];
            //                    _musicManager = nil;
            //                    _musicManager =  [_mMediaManager getMusicManager:(id)self];
            [_musicManager play];
            _musicState = uPlay;
            NSLog(@"newMusic播放U");
            
//            double delayInSeconds = 0.5f;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                           {
//                               if (!_isSpeaking) {
//                                   [_globalManager setMode:MODE_UHOST];
//                                   [_musicManager play];
//                                   _musicState = uPlay;
//                                   NSLog(@"newMusic播放U");
//                               }
//                           });
        }
            break;
        case uPause:{
            modeChangeIsCanSelectMusic = YES;
//            [_globalManager setMode:MODE_UHOST];
            [_musicManager pause];
            _musicState = uPause;
            NSLog(@"newMusic暂停U");
        }
            break;
        default:
            break;
    }
    [self changeOutSpeak];
}

-(void)musicPlayaAndPause{
    
    switch (_musicState) {
        case localPlay:
        case localPause:
        {
            NSLog(@"newMusic播放/暂停local");
            if (_localMusicPlayer.isPlaying) {
                [_localMusicPlayer pause];
                _musicState = localPause;
            }else{
                [_localMusicPlayer play];
                _musicState = localPlay;
            }
        }
            break;
        case netPause:{
            [_netMusicPlayer play];
            _musicState = netPlay;
            NSLog(@"newMusic播放net");
        }
            break;
        case netPlay:{
            [_netMusicPlayer pause];
            _musicState = netPause;
            NSLog(@"newMusic暂停net");
        }
            break;
        case uPlay:{
//            [_globalManager setMode:MODE_UHOST];
            _musicManager = nil;
            _musicManager =  [_mMediaManager getMusicManager:(id)self];
            [_musicManager pause];
            _musicState = uPause;
            NSLog(@"newMusic暂停U");
        }
            break;
        case uPause:{
            [_globalManager setMode:MODE_UHOST];
            _musicManager = nil;
            _musicManager =  [_mMediaManager getMusicManager:(id)self];
            [_musicManager play];
            _musicState = uPlay;
            NSLog(@"newMusic播放U");
        }
            break;
        default:
            break;
    }
    [self changeOutSpeak];
}
-(void)musicPause{
    switch (_musicState) {
        case localPlay:
        {
            if (_localMusicPlayer.isPlaying) {
                [_localMusicPlayer pause];
                _musicState = localPause;
            }
        }
            break;
        case netPlay:{
            [_netMusicPlayer pause];
            _musicState = netPause;
            
            NSLog(@"newMusic暂停net");
        }
            break;
        case uPlay:{
            [_musicManager pause];
            _musicState = uPause;
            NSLog(@"newMusic暂停U");
        }
            break;
        default:
            break;
    }
}
-(void)musicPlay{
    switch (_musicState) {
        case localPause:
        {
            
            if (_localMusicArray.count == 0) {
                return;
            }
            
            [_localMusicPlayer play];
            _musicState = localPlay;
        }
            break;
        case netPause:{
            
            [_netMusicPlayer play];
            _musicState = netPlay;
            NSLog(@"newMusic播放net");
        }
            break;
        case uPause:{
            [_globalManager setMode:MODE_UHOST];
            _musicManager = nil;
            _musicManager =  [_mMediaManager getMusicManager:(id)self];
            [_musicManager play];
            _musicState = uPlay;
            NSLog(@"newMusic播放U");
        }
            break;
        default:
            break;
    }
    [self changeOutSpeak];
}
-(void)mustPlay{
    switch (_musicState) {
        case localPause:
        case localPlay:
        {
            if (_localMusicArray.count == 0) {
                return;
            }
            [_localMusicPlayer play];
            _musicState = localPlay;
        }
            break;
        case netPause:
        case netPlay:
        {
            [_netMusicPlayer play];
            _musicState = netPlay;
            NSLog(@"newMusic播放net");
        }
            break;
        case uPause:
            case uPlay:
        {
            [_globalManager setMode:MODE_UHOST];
            _musicManager = nil;
            _musicManager =  [_mMediaManager getMusicManager:(id)self];
            [_musicManager play];
            _musicState = uPlay;
            NSLog(@"newMusic播放U");
        }
            break;
        default:
            break;
    }
    [self changeOutSpeak];
}

-(void)musicNext{
    NSLog(@"newMusic下一首");
    
    switch (_musicState) {
        case localPlay:
        case localPause:
        {
            if (_localMusicArray.count == 0) {
                return;
            }
            
            NSInteger currentIndex = [_localMusicArray indexOfObject:_playingMusic];
            NSInteger nextIndex = currentIndex + 1;
            if (nextIndex > _localMusicArray.count - 1) {
                nextIndex = 0;
            }
            NSLog(@"newMusic 选中第%d首",nextIndex);
            
            [self palyLocalMusic:_localMusicArray[nextIndex]];
        }
            break;
        case netPlay:
        case netPause:
        {
            NSInteger currentIndex = [_netMusicArray indexOfObject:_playingMusic];
            NSInteger nextIndex = currentIndex + 1;
            if (nextIndex > _netMusicArray.count - 1) {
                nextIndex = 0;
            }
            NSLog(@"newMusic 选中第%d首net",nextIndex);
            [self playNetMusic:_netMusicArray[nextIndex]];
        }
            break;
        case uPlay:
        case uPause:
        {
             [_globalManager setMode:MODE_UHOST];
            _musicManager = nil;
            _musicManager =  [_mMediaManager getMusicManager:(id)self];
            [_musicManager next];
            _musicState = uPlay;
        }
            break;
        default:
            break;
    }
    _nowPlayTime = @"00:00";
}
-(void)musicPre{
    NSLog(@"newMusic上一首");
    switch (_musicState) {
        case localPlay:
        case localPause:
        {
            NSInteger currentIndex = [_localMusicArray indexOfObject:_playingMusic];
            NSInteger nextIndex = currentIndex - 1;
            if (nextIndex < 0) {
                nextIndex = _localMusicArray.count - 1;
            }
            [self palyLocalMusic:_localMusicArray[nextIndex]];
        }
            break;
        case netPlay:
        case netPause:
        {
            NSInteger currentIndex = [_netMusicArray indexOfObject:_playingMusic];
            NSInteger nextIndex = currentIndex - 1;
            if (nextIndex < 0) {
                nextIndex = _netMusicArray.count - 1;
            }
            NSLog(@"newMusic 选中第%d首net",nextIndex);
            [self playNetMusic:_netMusicArray[nextIndex]];
        }
            break;
        case uPlay:
        case uPause:
        {
             [_globalManager setMode:MODE_UHOST];
            _musicManager = nil;
            _musicManager =  [_mMediaManager getMusicManager:(id)self];
            [_musicManager previous];
            _musicState = uPlay;
        }
            break;
        default:
            break;
    }
}


-(void)addProgressTimer
{
    if (_musicTimer == nil) {
        _musicTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(updateMusicState)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}
-(void)updateMusicState{
    if (isGetData) {
        isGetData = NO;
        noGetDataInt = 0;
        if (isCanSendNoti) {
            isCanSendNoti = NO;
            NSLog(@"updateMusicState_BT收到数据判断蓝牙连接");
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BTCONNECTED" object:nil];
            waitTime = 2;
//            APPDELEGATE.isGetData = YES;
            
        }
    }else{
        if (waitTime > 0) {
            waitTime--;
        }else{
            noGetDataInt++;
            if (noGetDataInt == 3) {
                NSLog(@"updateMusicState_BT没收到数据判断蓝牙断开");
                [USER_PLIST setObject:[NSDate date] forKey:@"leaveTime"];
                [USER_PLIST synchronize];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"BTDISCONNECT" object:nil];
                isCanSendNoti = YES;
//                APPDELEGATE.isGetData = NO;
            }

        }
    }
    
    switch (_musicState) {
        case localPlay:
        case localPause:
        {
            _nowPlayTime = [NSString stringWithTime:_localMusicPlayer.currentTime];
        }
            break;
        case netPause:
        case netPlay:{
        }
            break;
            case uPlay:
        case uPause:{
            float time = [_musicManager getCurrentPosition]; //获取音乐当前播放时间
            if (time < 36000000) {
                NSLog(@"当前时间%@",_nowPlayTime);
                _nowPlayTime = [self Time2String:time];
                
            }
        }
            
        default:
            break;
    }
//    NSLog(@"updateMusicState_nowPlayTime播放时间%@",_nowPlayTime);
//    NSLog(@"updateMusicState_totalPlayTime播放时间%@",_totalPlayTime);
    NSArray * nowArray = [_nowPlayTime componentsSeparatedByString:@":"];
    NSInteger now = [nowArray[0] integerValue]*60 + [nowArray[1] integerValue];
    NSArray * totalArray = [_totalPlayTime componentsSeparatedByString:@":"];
    NSInteger total = [totalArray[0] integerValue]*60 + [totalArray[1] integerValue];
    _musicProgressFloat = now/(float)total > 0.999? 0:now/(float)total;
    
//    NSLog(@"updateMusicState_musicProgressFloat播放时间%f.0",_musicProgressFloat);

    if ([KDXFvoiceManager shareInstance].isLink) {
        sendInt++;
        if (sendInt >= 3) {
            sendInt = 3;
            if (_globalManager != nil) {
                int key = [_globalManager buildKey:QUE cmdID:0x83];
                [_globalManager sendCustomCommand:key param1:0 param2:0 others:nil];
            }
        }
    }

}
-(NSString *)Time2String:(NSInteger)nTime
{
    CGFloat secondsF = (int)nTime / 1000.;
    int secondsI = (int)nTime / 1000;
    int minute = 0;
    if (secondsF >= 60)
    {
        CGFloat index = secondsF / 60.;
        minute = secondsI / 60;
        secondsF = secondsF - minute * 60;
    }
    NSLog(@"minute = %d seconds = %d ",nTime/60000,nTime%60000);
    NSInteger second = nTime%60000/1000;
    NSInteger nextInt = nTime%60000%1000/100;
    if (nextInt > 4) {
        second ++;
    }
    return [NSString stringWithFormat:@"%02d:%02d",nTime/60000,second];
}

-(void)changeMusicValue:(CGFloat)value{
    switch (_MusicMode) {
        case MODELOCAL:
        {
            _localMusicPlayer.currentTime = [_localMusicPlayer duration]*value == [_localMusicPlayer duration]*value ? [_localMusicPlayer duration]*value - 1:[_localMusicPlayer duration]*value;
        }
            break;
        case MODENET:
        {
            if (!isCanotSlider) {
                CMTime totalTime = _netMusicPlayer.currentItem.duration;
                CMTime time = CMTimeMake(value * totalTime.value, totalTime.timescale);
                [_netMusicPlayer seekToTime:time];
            }
        }
            break;
        default:
            break;
    }

}

#pragma mark --- BtLink
//-(void)initBluzDevice{
//    _BtArray = [NSMutableArray array];
//    _mBluzConnector = [[BluzDevice alloc]init];
//    [_mBluzConnector setConnectDelegate:self];
//    [_mBluzConnector setAppForeground:YES];
//    [_mBluzConnector scanStart];
//}
//-(void)scanBlue{
//    if (!APPDELEGATE.isBlueOpen)
//    {
//        UIAlertView *alet = [[UIAlertView alloc] initWithTitle:@"当前蓝牙服务不可用" message:@"请到“设置->蓝牙”中开启蓝牙" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//        alet.tag = 500;
//        [alet show];
//    }
//    else{
//        [_BtArray removeAllObjects];
//        if (_linkingBT != nil) {
//            [_BtArray addObject:_linkingBT];
//            [_mBluzConnector scanStart];
//        }
//    }
//}
//-(void)foundPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData
//{
//    
//}
-(void)lianjielanya{
    NSLog(@"newMusic 蓝牙连接通知");
        [self initMediaManager];
    order = NO;
    getOutNumber = 0;
    sendInt = 0;
}
//蓝牙连接时候一直重复生成一个连接对象，不停发送暂停指令，导致逻辑混乱。已修改
-(void)duankailanya{
    _uSongChange = YES;
    isCanchangeFM = YES;
    order = NO;
    UUIDStr = @"";
    NSLog(@"newMusic 蓝牙连接断开");
    [_mMediaManager close];
    _mMediaManager = nil;
    [_globalManager close];
    _globalManager = nil;
    
    [self changeOutSpeak];//蓝牙断开后防止声音从听筒出来
    double delayInSecond5 = 2.0f;
    dispatch_time_t popTime5 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSecond5 * NSEC_PER_SEC));
    dispatch_after(popTime5, dispatch_get_main_queue(), ^(void)
                   {
                       [self changeOutSpeak];//蓝牙断开后防止声音从听筒出来
                   });
    
    double delayInSeconds = 5.0f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                        [self changeOutSpeak];//蓝牙断开后防止声音从听筒出来
                   });

    
    
    
    [_UhoustMusicArray removeAllObjects];
    if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
        NSLog(@"newmusicChangeMode----------1");
        [_NewMusicDele tableViewReloadData:MODEUHOST];
    }
    
    [self musicPause];
    
    [self UhoustLeastGoToLocal]; 
}
-(void)initMediaManager{
    _mMediaManager = [[BluzManager alloc] initWithConnector:self.mBluzConnector];
    _globalManager = [_mMediaManager getGlobalManager:(id)self];
    [self CheckSafe];
}
-(void)playUhoustMusic:(UInt32)UhoustSelect{
    [_globalManager setMode:MODE_UHOST];
    
    [_musicManager select:(UInt32)UhoustSelect];
    _musicState = uPlay;
    _uSongSelectNum = UhoustSelect;
}
-(void)playUhoustMusic2:(MusicEntry*)entry{

}
-(void)setUhoustPlayMusic:(MusicEntry*)entry{
    [_globalManager setMode:MODE_UHOST];
    _musicState = uPlay;
    _uMusicSelect = entry;
    _uSongSelectNum = entry.index;
    _musicManager = nil;
    _musicManager =  [_mMediaManager getMusicManager:(id)self];
    [_musicManager select:_uSongSelectNum];
    _totalPlayTime = [self Time2String:[_musicManager getDuration]];
    
    MusicBean *model = [[MusicBean alloc]init];
    model.m_musicName = entry.name;
    model.m_singerName =  entry.artist;
    model.m_musicCover = [UIImage imageNamed: MusicImage];
    _playingMusic = model;
    
    _musicSelectNum = _uSongSelectNum - 1;
    if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(changeSelectMusic:)]) {
        if (_musicSelectNum >= 0) {
            [_NewMusicDele changeSelectMusic:_musicSelectNum];
        }
    }
}
#pragma mark --- GlobalDelegate

-(void)managerReady
{
    NSLog(@"newMusicU盘log GlobalDelegate managerReady准备就绪");
   isCanGoToUhouse = YES;
    [_globalManager setMode:MODE_UHOST];
//    [_globalManager setVolume:6];
}
-(void)UhoustRefresh{
    
        if (![KDXFvoiceManager shareInstance].isLink) {
            [UIUtil showToast:@"您还未连接蓝牙" inView:SELFVIEW];
        }else if(![newMusic shareInstance].isHaveUhoust){
            [UIUtil showToast:@"设备未插入U盘" inView:SELFVIEW];
        }else{
//            [self managerReady];
            
            _uSongChange = YES;
            isCanchangeFM = YES;
            [_mMediaManager close];
            _mMediaManager = nil;
            [_globalManager close];
            _globalManager = nil;
            [self initMediaManager];
            _MusicMode = MODEUHOST;
            if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
                NSLog(@"newmusicChangeMode----------2");
                [_NewMusicDele tableViewReloadData:MODEUHOST_UhostLoad];
            }
        }
}
-(void)modeChanged:(UInt32)mode
{
    NSLog(@"newMusicU盘log 当前模式%ld    _uSongSelectNum = %d",mode,_uSongSelectNum);
    if (!_isSpeaking) {
        if (mode == MODEUHOST) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(deselectTable)]) {
                    [_NewMusicDele deselectTable];
                }
            });           
            [_localMusicPlayer pause];
            [_netMusicPlayer pause];
            
            _MusicMode = MODEUHOST;
            _musicManager = nil;
            //添加延时 处理设备读“u” 0.0
            if (!_isHaveUhoust) {
            
            double delayInSeconds = 1.0f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
            _musicManager =  [_mMediaManager getMusicManager:(id)self];
            if (_uSongSelectNum > 0) {
                [_musicManager select:_uSongSelectNum];
            }
            });
            }else{
                _musicManager =  [_mMediaManager getMusicManager:(id)self];
                if (_uSongSelectNum > 0) {
                    [_musicManager select:_uSongSelectNum];
                }

            }
        }
    }else{
        if (mode == MODEUHOST) {
//            _isSpeaking = NO;   原本有U盘的情况下 语音模式切换到U模式设置下面命令  没有U盘的情况下就是插入U盘不做处理
            if (_isHaveUhoust) {
                [_globalManager setMode:MODE_A2DP];
            }
        }
    }
}
//U盘插拔状态变化
-(void)hotplugUhostChanged:(BOOL)visibility{
    
    
    if (visibility) {
        
        
         //添加延时 处理设备读“u” 0.0
        double delayInSeconds = 1.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
        
                           
                           
        isCanGoToUhouse = YES;
        
        if (_isSpeaking) {
            _isSpeaking = NO;
//            [_globalManager setMode:MODE_UHOST]; //语音功能时插入U盘能立马放U盘歌曲  有可能失效

        }
        if (!_isHaveUhoust) {
//             [self UhoustRefresh];           //模拟重连 比较彻底
            _uSongChange = YES;
            isCanchangeFM = YES;
            [_mMediaManager close];
            _mMediaManager = nil;
            [_globalManager close];
            _globalManager = nil;
            [self initMediaManager];
            _MusicMode = MODEUHOST;
            if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
                NSLog(@"newmusicChangeMode----------3");
                [_NewMusicDele tableViewReloadData:MODEUHOST_UhostLoad];
            }

        }
        _isHaveUhoust = YES;
//需要恢复        [[KDXFvoiceManager shareInstance]cancelVoiceNoVoice];//取消语音功能

        dispatch_async(dispatch_get_main_queue(), ^{
            if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(deselectTable)]) {
                [_NewMusicDele deselectTable];//删除其他tableview点击效果 必须主线程才有效
            }
        });
                           
        if (_MusicMode == MODEUHOST) {
            _musicState = uPlay;
        }
        double delayInSeconds = 1.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           if (_isHaveUhoust) {
                               _saveMusicState = uPlay;  //延时缓存U盘播放状态
                           }
                           
                           
          });
        linkUhoustTimes ++;
        int blockLinkTimes = linkUhoustTimes;
        double delayInSeconds2 = 10.0f;
        dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
        dispatch_after(popTime2, dispatch_get_main_queue(), ^(void)
                       {
                           NSLog(@"linkUhoustTimes= %d  blockLinkTimes= %d",linkUhoustTimes,blockLinkTimes);
                           if (linkUhoustTimes != blockLinkTimes) {
                               return ;
                           }

                           if (!_isHaveUhoust) {
                               return ;
                           }
                           _uSongAllNum = [_musicManager getPListSize];
                           if(_uSongAllNum == 0)
                           {
                               if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
                                   NSLog(@"newmusicChangeMode----------5");
                                   [_NewMusicDele tableViewReloadData:MODEUHOST];
                               }
                               _MusicMode = MODELOCAL;
                               _musicState = localPause;
                               if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(changeSelectMusic:)]) {
                                   [_NewMusicDele changeSelectMusic:_musicSelectNum];
                               }
                               //屏蔽下面 不跳转本地列表
//                               if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
//                                   [_NewMusicDele tableViewReloadData:MODELOCAL];
//                               }
                           }
                           
                       });
          
                       });
    }else{
        _isHaveUhoust = NO;
        NSLog(@"newMusicU盘log 检测无U盘");
        //删除U盘歌曲列表
        [_UhoustMusicArray removeAllObjects];
        if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
            NSLog(@"newmusicChangeMode----------6");
            [_NewMusicDele tableViewReloadData:MODEUHOST_NotGoto];
        }
        [self UhoustLeastGoToLocal];
    }
}
-(void)UhoustLeastGoToLocal{
    //跳转到本地音乐
    if (_MusicMode == MODEUHOST) {
        _uSongChange = YES;
        //            _musicState = uPause;
        if (_localMusicArray.count  != 0) {
            _localMusicPlayer.delegate = nil;
            _localMusicPlayer = nil;
            _playingMusic = _localMusicArray[0];
            
            NSError *error;
            _localMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_playingMusic.m_url error:&error];
            _localMusicPlayer.delegate = self;
            [_localMusicPlayer prepareToPlay];
            _totalPlayTime = [NSString stringWithTime:_localMusicPlayer.duration];
            _musicSelectNum = 0;
        }
        
        _MusicMode = MODELOCAL;
        _musicState = localPause;
        if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(changeSelectMusic:)]) {
            [_NewMusicDele changeSelectMusic:_musicSelectNum];
        }
        if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
            [_NewMusicDele tableViewReloadData:MODELOCAL];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"UhoustLeast" object:nil];
        _MusicMode = MODELOCAL;
        _musicState = localPause;
    }
}
//卡插拔状态变化
-(void)hotplugCardChanged:(BOOL)visibility
{
//    if (visibility) {
//        NSLog(@"newMusicU盘log 检测有SD卡");
//    }else{
//        NSLog(@"newMusicU盘log盘log 检测无SD卡");
//    }
}
//USB线插拔状态变化
-(void)hotplugUSBChanged:(BOOL)visibility
{
//    if (visibility) {
//        NSLog(@"newMusic 检测有USB盘");
//    }else{
//        NSLog(@"newMusic 检测无USB盘");
//    }
}
//音箱Linein连接线插拔状态变化
-(void)lineinChanged:(BOOL)visibility
{
}
-(void)dialogMessageArrived:(UInt32)type messageID:(UInt32)messageId
{
}
-(void)toastMessageArrived:(UInt32)messageId
{
}
-(void)dialogCancel
{
}
-(void)soundEffectChanged:(UInt32)mode
{
}
-(void)eqModeChanged:(UInt32)mode
{
}
-(void)batteryChanged:(UInt32)battery charging:(BOOL)charging
{
}
-(void)daeModeChanged:(int)daeOpts //可选择的实现方法
{
}
//声音变化回调
-(void)volumeChanged:(UInt32)current max:(UInt32)max min:(UInt32)min isMute:(BOOL)mute
{
}
//自定义命令回调
-(void)customCommandArrived:(UInt32)cmdKey param1:(UInt32)param1 param2:(UInt32)param2 others:(NSData*)param3
{
    
    isGetData = YES;
    
    
    
    
    if (cmdKey == 16771)
    {
        NSLog(@"MusicVC:customCommandArrived:param1 = %u，param2 = %u",(unsigned int)param1,(unsigned int)param2);
        
        int a = param2/10;
        int b = param2%10;
        if (b>=5)
        {
            a++;
        }
        
        if (param2 < 1000)
        {
            [USER_PLIST setObject:[NSString stringWithFormat:@"%.1f",param2/10.] forKey:@"DIANYA"];
        }
        [USER_PLIST setObject:[NSString stringWithFormat:@"%d",(unsigned int)param1] forKey:@"FMpinglv"];
        [USER_PLIST synchronize];
        //陈工:屏蔽无效电压
        if (isCanchangeFM)
        {
            if (param2 < 1000)
            {
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:@"changeFMUI" object:self userInfo:@{@"FM":[NSString stringWithFormat:@"%d",(unsigned int)param1],@"DIANYA":[NSString stringWithFormat:@"%.1f",param2/10.]}];
                isCanchangeFM = NO;
            }
        }
        
        //陈工:识别一键语音消息
        int a2 = 0;
        NSMutableArray *dataArray = [NSMutableArray array];
        int x = param2,tmp = x;
        while(tmp)
        {
            NSString *str = [NSString stringWithFormat:@"%02X",tmp&255];
            tmp>>=8;
            [dataArray addObject:str];
            a2++;
        }
        if (a2 == 4)
        {
            NSLog(@"MusicVC:customCommandArrived:每秒返回param2分割成数组:dataArray = %@",dataArray);
            
            if ([dataArray[3] isEqualToString:@"03"] && [dataArray[2] isEqualToString:@"01"])
            {
                
                NSLog(@"自定义指令:播放暂停");
                                if (![KDXFvoiceManager shareInstance].isTelComing)
                                {
                                    if (_MusicMode != MODEUHOST)
                                    {
                                        if (![KDXFvoiceManager shareInstance].isEnterOnekeyVoiceVC) {
                                            NSLog(@"打电话 播放暂停");
                                            if (![KDXFvoiceManager shareInstance].isMapNIL) {
                                                [self musicPlayaAndPause];
                                            }
                                        }  //与远程控制事件 puse重复了导致走了两次  打开这里的就要关闭远程事件。
                                    }else{
                                        if (modeChangeIsCanSelectMusic) {
                                            modeChangeIsCanSelectMusic = NO;
                                            [self musicPlayaAndPause];
                                        }
                                    }
                                }
                
            }
            if ([dataArray[3] isEqualToString:@"01"] && [dataArray[2] isEqualToString:@"02"])
            {
                NSLog(@"自定义指令:上一曲");
//                                if (!APPDELEGATE.isTelComing)
//                                {
//                                    if (_MusicMode != MODEUHOST)
//                                    {
//                                    
//                                    if (!APPDELEGATE.isEnterOnekeyVoiceVC) {
//                                        [self musicPre];
//                                    }
//                                    }
//                                }
                
                
            }
            if ([dataArray[3] isEqualToString:@"01"] && [dataArray[2] isEqualToString:@"03"])
            {
                NSLog(@"自定义指令:下一曲");
//                                if (!APPDELEGATE.isTelComing)
//                                {
//                                    if (_MusicMode != MODEUHOST)
//                                    {
//                                    
//                                    if (!APPDELEGATE.isEnterOnekeyVoiceVC) {
//                                        [self musicNext];
//                                    }
//                                    }
//                                }
            }
            if ([dataArray[3] isEqualToString:@"01"] && [dataArray[2] isEqualToString:@"01"])
            {
                NSLog(@"自定义指令 一键语音");
                if ([KDXFvoiceManager shareInstance].isCanVoice) {
                    if (![KDXFvoiceManager shareInstance].isTelComing && ![KDXFvoiceManager shareInstance].isTelBreak)
                    {
                        [KDXFvoiceManager shareInstance].isOneKeyEnterVoiceVC = YES;
                        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                        [nc postNotificationName:@"gotoVoice" object:self];
                        
                    }
                    [KDXFvoiceManager shareInstance].isTelBreak = NO;
                }
            }
        }
    }
    else if(cmdKey == 16780)
    {
        
        [self firstCherkBT:param3];
    }
    else if(cmdKey == 16781)
    {
        order = YES;
        
        UUIDStr = [[NSString alloc] initWithData:param3 encoding:NSUTF8StringEncoding];
        UUIDStr = [UUIDStr uppercaseString]; //转换为大写的字符串
        NSLog(@"转变前UUIDStr = %@",UUIDStr); //F44EFD234AF2
        
        NSMutableString *str1 = [[NSMutableString alloc] initWithString:UUIDStr];
        int k = 0;
        for (int i = 0; i < 5; i++)
        {
            [str1 insertString:@":" atIndex:(i + 1) * 2 + k];
            k++;
        }
        UUIDStr = str1;
        NSLog(@"转变后UUIDStr = %@",UUIDStr); //F4:4E:FD:23:4A:F2
        [self checkBLUE];
    }
}
#pragma mark --- MusicDelegate MusicDelegate MusicDelegate

//{@link MusicManager}对象准备就绪
-(void)managerReady:(UInt32)mode
{
    NSLog(@"newMusicU盘log U盘对象managerReady准备就绪");
    _MusicMode = MODEUHOST;
    if (mode == MODEUHOST) {
        _uSongAllNum = [_musicManager getPListSize]; //获取歌曲列表大小
        NSLog(@" 歌曲总数：%d",_uSongAllNum);
        if(_uSongAllNum > 0)
        {
            if (_UhoustMusicArray.count < _uSongAllNum) {
                
            }
        }else{
            
        }
        getPListFrom = -1;
        [self getPlist];
    }
}
-(void)getPlist
{
    NSLog(@"newMusicU盘log 获取U盘清单");
    if (getPListFrom == _UhoustMusicArray.count + 1)
    {
        
        return;
    }
    else
    {
        getPListFrom = (int)_UhoustMusicArray.count + 1;
    }
    
    UInt32 left = (UInt32)(_uSongAllNum - _UhoustMusicArray.count);
    [_musicManager getPListFrom:getPListFrom withCount:(left >= 10 ? 10 : left >= 5 ? 5 : left)];
}
//音箱播放音乐条目切换(entry:当前播放的音乐条目)
-(void)musicEntryChanged:(MusicEntry*) entry
{
    
    if(entry.name==nil) entry.name = @"未知";
    if ([entry.name hasSuffix:@".mp3"] ||[entry.name hasSuffix:@".wav"]||[entry.name hasSuffix:@".amr"]||[entry.name hasSuffix:@".wma"] ||[entry.name hasSuffix:@".ape"]) {
        entry.name = [entry.name substringToIndex:entry.name.length - 4];
    }
    if(entry.artist==nil) entry.artist = @"未知";
    
//    if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(deselectTable)]) {        
//        [_NewMusicDele deselectTable];
//    }
    
    
    if (_MusicMode == MODEUHOST) {
        NSLog(@"newMusicU盘log 获取U盘当前播放歌曲");
        _uMusicSelect = entry;
        _uSongSelectNum = entry.index;
        _totalPlayTime = [self Time2String:[_musicManager getDuration]];
        
        MusicBean *model = [[MusicBean alloc]init];
        model.m_musicName = entry.name;
        model.m_singerName =  entry.artist;
        model.m_musicCover = [UIImage imageNamed: @"ic_launcher.png"];
        _playingMusic = model;
        _musicSelectNum = _uSongSelectNum - 1;
         if (_UhoustMusicArray.count != 0) {
             
                if (_UhoustMusicArray.count >= _musicSelectNum) {
                    MusicEntry* model = _UhoustMusicArray[_musicSelectNum];
                    if ([model.name isEqualToString:entry.name]) {
                        
                        //匹配 entry和当前要选中的model 是的话则替换名称 和选中效果  防止选中效果换来换去和歌曲名称乱更换
                        
                        [_UhoustMusicArray replaceObjectAtIndex:_musicSelectNum withObject:entry];
                        
                        if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(changeSelectMusic:)]) {
                            if (_uSongSelectNum - 1 >=0) {
                                [_NewMusicDele changeSelectMusic:_musicSelectNum];
                            }
                        }
                    }
               
        
        
                    
                }
        }

    }
}
-(void)setPlayMusic:(MusicEntry *)enty
{
    
}
//音箱播放状态变化
-(void)stateChanged:(UInt32) state
{
    switch (state) {
        case 2:
            NSLog(@"newMusicU盘log U盘state播放");
            if (_MusicMode == MODEUHOST) {
//                if (_UhoustMusicArray.count == 0) {
//                    [self getPlist];
//                }
                
//                _totalPlayTime = [self Time2String:[_musicManager getDuration]];
//                if ([_totalPlayTime isEqualToString:@"00:00"]) {
//                    [self musicNext];
//                }
                
                modeChangeIsCanSelectMusic = NO;
                _musicState = uPlay;
            }
            break;
            
        default:
            NSLog(@"newMusicU盘log U盘state不播放");
            if (_MusicMode == MODEUHOST) {
                _musicState = uPause;
            }
            break;
    }
}
//音箱播放列表变化，应用需重新同步播放列表
-(void)contentChanged
{
    
}
//音箱发送播放列表(走完getPListFrom:withCount:方法后执行)
-(void)pListEntryReady:(NSMutableArray*) entryList
{
//    BOOL isGoToUhoust;
//    
//    if (_UhoustMusicArray > 0) {
//        isGoToUhoust = NO;
//    }else{
//        isGoToUhoust = YES;
//    }
    
    NSLog(@"newMusic 获取到U盘歌曲");
    for (MusicEntry *data in entryList)
    {
        if(data.mimeType==nil) data.mimeType = @"未知";
        if(data.name==nil) data.name = @"未知";
        if ([data.name hasSuffix:@".mp3"] ||[data.name hasSuffix:@".wav"]||[data.name hasSuffix:@".amr"]||[data.name hasSuffix:@".wma"] ||[data.name hasSuffix:@".ape"]) {
            data.name = [data.name substringToIndex:data.name.length - 4];
        }
        if(data.title==nil) data.title = @"未知";
        if(data.artist==nil) data.artist = @"未知";
        if(data.album==nil) data.album = @"未知";
        if(data.genre==nil) data.genre = @"未知";
        BOOL found = NO;
        for (int i = 0; i < _UhoustMusicArray.count; i++) {
            MusicEntry *entry = [_UhoustMusicArray objectAtIndex:i];
            NSInteger index = entry.index;
            if (index == data.index)
            {
                NSLog(@"=====found====");
                found = YES;
                break;
            }
        }
        
        //按顺序依次建立播放列表，防止列表中歌曲乱序
        if (data.index > _UhoustMusicArray.count + 1)
        {
            found = YES;
        }
        
        if (!found)
        {
            [_UhoustMusicArray addObject:data];
            NSLog(@"newMusic U盘歌曲数据源当前个数:%d",(int)_UhoustMusicArray.count);
        }
    }

    getPListFrom = -1;
    if(_UhoustMusicArray.count < _uSongAllNum)
    {
        if (isCanGoToUhouse) {
            isCanGoToUhouse = NO;
            _musicState = uPlay;
            if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
                NSLog(@"newmusicChangeMode----------7--%d",(int)_UhoustMusicArray.count);
                [_NewMusicDele tableViewReloadData:MODEUHOST];
            }
        }else{
            if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
                NSLog(@"newmusicChangeMode----------8");
                [_NewMusicDele tableViewReloadData:MODEUHOST_NotGoto];
            }
        }
        
        [self getPlist];
    }else{
        if (isCanGoToUhouse) {
            isCanGoToUhouse = NO;
            if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
                NSLog(@"newmusicChangeMode----------9");
            [_NewMusicDele tableViewReloadData:MODEUHOST];
            }
        }else{
            if (_NewMusicDele && [_NewMusicDele respondsToSelector:@selector(tableViewReloadData:)]) {
                NSLog(@"newmusicChangeMode----------10");
                [_NewMusicDele tableViewReloadData:MODEUHOST_NotGoto];
            }
        }

    }
}
//音箱返回指定歌曲的歌词信息
-(void)lyricReady:(UInt32)index lyric:(NSData*)lyric
{
}
//音箱当前循环模式变化
-(void)loopModeChanged:(UInt32) mode
{
}

//打开扬声器防止听筒放歌曲
-(void)changeOutSpeak{
    NSArray *outArray3 = [[AVAudioSession sharedInstance] currentRoute].outputs;
    NSLog(@"输出源:outArray3 = %@",outArray3);
    
    for (AVAudioSessionPortDescription *mDes in outArray3){
        printf("outPort: %s\n",[mDes.portType UTF8String]);
        //hfp蓝牙规范 支持边输入边输出 不同于A2DP 和hsp
        if ([mDes.portType isEqualToString:@"Speaker"] || [mDes.portType isEqualToString:@"Receiver"]) {
            //上面通话模式打开扬声器输出声音
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
    }
}
#pragma mark --- 杂七杂八
-(void)setFM:(NSString*)FMStr{
    int key = [_globalManager buildKey:SET cmdID:0x81];
    CGFloat f = [FMStr floatValue];
    [_globalManager sendCustomCommand:key param1:f param2:0 others:nil];
    NSLog(@"FM电台发射*************************fm2 = %f",f);
}
-(void)CTCallStateDisconnected{
    dispatch_async(dispatch_get_main_queue(), ^{
    
    NSLog(@"newMusic挂电话播放");
    switch (_musicState) {
        case localPlay:
        {
            [_localMusicPlayer play];
            NSLog(@"newMusic挂电话播放local");
        }
            break;
        case netPlay:{
            [_netMusicPlayer play];
 
            NSLog(@"newMusic挂电话播放net");
        }
            break;
        default:
            break;
    }
    });
}
#pragma mark --- BT检查安全性
-(void)CheckSafe{
    int key2 = [_globalManager buildKey:QUE cmdID:0x8C];
    [_globalManager sendCustomCommand:key2 param1:0 param2:0 others:nil];
    [self performSelector:@selector(getout) withObject:self afterDelay:5.0];
}
-(void)getout
{
    if (![KDXFvoiceManager shareInstance].isLink)
    {
        
        return;
    }
    if (!order)
    {
        getOutNumber++;
        
        NSLog(@"[getout]-----------------getOutNumber =%d",getOutNumber);
        
        if (getOutNumber == 5)
        {
            outNumber = 2;
            [self sorryOut];
        }
        else
        {
            [self CheckSafe];
        }
    }
}
-(void)sorryOut
{
    if ([IDStr isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"OKUUID"]])
    {
        return;
    }    
    NSString *str1;
    if (outNumber == 1)
    {
        str1 = @"您连接的设备不是正规厂家生产，已自动断开连接，请购买正品设备";
    }
    else if(outNumber == 2)
    {
        str1 = @"查询产品序列号未有结果，已自动断开连接，请购买正品设备";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:str1 delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    
    NSDictionary *dict = self.blueDictionary;
    CBPeripheral *peripheral = [dict objectForKey:@"peripheral"];
    [USER_PLIST removeObjectForKey:@"linkID"];
    [USER_PLIST removeObjectForKey:@"linkNAME"];
    self.blueDictionary = nil;
    [self.mBluzConnector disconnect:peripheral];
    self.isLegal = NO;
    NSLog(@"蓝牙不正规");
}

-(void)firstCherkBT:(NSData *)param3
{
    NSLog(@"NSData:param3 = %@",param3); //<66383335 30303062>
    NSLog(@"NSString:param3 = %@",[[NSString alloc] initWithData:param3 encoding:NSUTF8StringEncoding]); //f835000b
    
    //    order = YES;
    
    long ser = param3;
    NSString *str = [NSString stringWithFormat:@"%ld",ser];
    IDStr = str;
    NSLog(@"转变前IDStr = %@",IDStr); //351239984
    
    Byte *bytes = (Byte *)malloc(param3.length);
    memcpy(bytes, [param3 bytes], param3.length); //从源src所指的内存地址的起始位置开始拷贝len个字节到目标dest所指的内存地址的起始位置中
    
    NSMutableString *contentString2 = [NSMutableString string];
    for (int i = 0; i < param3.length; i++)
    {
        [contentString2 appendString:[NSString stringWithFormat:@"%c",bytes[i]]];
    }
    IDStr = contentString2;
    NSLog(@"转变后IDStr = %@",IDStr); //f835000b
    
    UInt64 mac1 = strtoul([IDStr UTF8String], 0, 16); //16进制的IDStr转换成10进制([IDStr UTF8String]:转变为打印出来是%s的形式)
    IDStr = [NSString stringWithFormat:@"%llu",mac1];
    NSLog(@"转变十六进制后IDStr = %@",IDStr); //4164222987
    
    CHERKNUMBER = 5;
    
    int key = [_globalManager buildKey:QUE cmdID:0x8D];
    NSLog(@"_globalManager buildKey:QUE cmdID:0x8D = %d",key);
    [_globalManager sendCustomCommand:key param1:0 param2:0 others:nil];
    
    //    [self performSelector:@selector(checkBLUE) withObject:self afterDelay:10.0];
}
-(void)cherkBlue:(NSString *)str UUID:(NSString *)UUID
{
    NSLog(@"蓝牙校验  串口号 = %@  UUID = %@",str,UUID);
    NSString *textStr = APPURL;
    NSDictionary *ceshiParams2 = @{@"a":@"config",@"m":@"addSerial",@"arg":@""};
    NSDictionary *ceshiParams3 = @{@"appType":APPTYPE,@"serial":str,@"macId":UUID};
    [ZZXDataService ZZXNoSignRequest:textStr httpMethod:@"POST" params1:ceshiParams2 params2:ceshiParams3 file:nil success:^(id data)
     {
         NSDictionary *dict = (NSDictionary *)data;
         
         NSLog(@"检测串口号合法%@",dict);
         
         if ([dict[@"retCode"] intValue] == 1) //1代表成功
         {
             NSLog(@"retDesc = %@",dict[@"retDesc"]);
             
             if ([dict[@"qualified"] intValue] == 1)
             {                 
                 [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"OKUUID"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 self.isLegal = YES;
             }
             else
             {
                 outNumber = 1;
                 [self sorryOut];
             }
         }
         else
         {
             NSLog(@"检查串口号返回错误原因:%@",dict[@"retDesc"]);
             
             if (CHERKNUMBER > 0)
             {
                 double delayInSeconds = 5.0f;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                {
                                    CHERKNUMBER--;
                                    [self cherkBlue:IDStr UUID:UUIDStr];
                                });
             }
             else
             {
                 
             }
         }
     } fail:^(NSError *error)
     {
         //         NSLog(@"请求失败:error = %@",error);
         //
         //         if (CHERKNUMBER != 0)
         //         {
         //             double delayInSeconds = 5.0f;
         //             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
         //             dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
         //                            {
         //                                CHERKNUMBER--;
         //                                [self cherkBlue:IDStr UUID:UUIDStr];
         //                            });
         //         }
         //         else
         //         {
         //
         //         }
     }];
}

-(void)checkBLUE
{
    [self cherkBlue:IDStr UUID:UUIDStr];
    NSLog(@"网络查询串口号");
}

@end
