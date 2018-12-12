//
//  HomeMusicCell.m
//  FHZL
//
//  Created by hk on 17/12/5.
//  Copyright © 2017年 hk. All rights reserved.
//

#import "HomeMusicCell.h"
#import "Header.h"
#import "CALayer+PauseAimate.h"
@interface HomeMusicCell()
{
   
}
@end
@implementation HomeMusicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    NSLog(@"awakeFromNib");
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(set_isAdd) name:@"MusicCell_isAddSetNo" object:nil];
    _cellBackImageVIew.layer.cornerRadius = 5;
    _cellBackImageVIew.layer.masksToBounds  = YES;
    if (_Timer == nil) {
        _Timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(changePicture)
                                                userInfo:nil
                                                 repeats:YES];
    }
    _MusicImageView.layer.cornerRadius = 42;
    _MusicImageView.layer.borderColor = [UIColor clearColor].CGColor;
    _MusicImageView.layer.borderWidth = 4;
    _MusicImageView.layer.masksToBounds = YES;
    
    _progressView.arcFinishColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];//RGB(69, 84, 111);
    _progressView.arcUnfinishColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];//RGB(69, 84, 111);
    _progressView.arcBackColor = [UIColor whiteColor];//RGB(30, 158, 255);
    _progressView.percent = 1;
    _progressView.transform=CGAffineTransformMakeRotation(-M_PI/2);
    
}
-(void)set_isAdd{
    NSLog(@"接收到通知——————MusicCell_isAddSetNo");
    _isAdd = NO;
    _isReload = NO;

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
    [_MusicImageView.layer addAnimation:rotationAnim forKey:nil];
    [_MusicImageView.layer resumeAnimateCSQ];
    _isAdd = YES;
}
-(void)changePicture{
//    NSLog(@"cell计时器检测是否多次生成");
    switch ([newMusic shareInstance].musicState) {   
        case localPlay:
        case netPlay:
        {
            [_PlayOrPauseButton setImage:[UIImage imageNamed:@"音乐_暂停_N"] forState:UIControlStateNormal];

            if (!_isReload) {
                if (_isAdd) {

                    [_MusicImageView.layer resumeAnimate];
//                    NSLog(@"动画处理resumeAnimate");
                }else{
                    
                    [self addIconViewAnimate];
//                    NSLog(@"动画处理addIconViewAnimate");
                }
                _isReload = YES;
            }
        }
            break;
        case uPlay:
        {
//            isPictureInt = 2;
            [_PlayOrPauseButton setImage:[UIImage imageNamed:@"音乐_暂停_N"] forState:UIControlStateNormal];

            if (!_isReload) {
                if (_isAdd) {
                    [_MusicImageView.layer resumeAnimate];
                }else{
                    [self addIconViewAnimate];
                }
                _isReload = YES;
            }

        }
            break;
        default:
        {
            [_PlayOrPauseButton setImage:[UIImage imageNamed:@"音乐_播放_N"] forState:UIControlStateNormal];
            if (_isReload) {
                    [_MusicImageView.layer pauseAnimate];
                    _isReload = NO;
//                NSLog(@"动画处理pauseAnimate");
            }
        }
    }
    _MusicImageView.image = [newMusic shareInstance].playingMusic.m_musicCover;
    _musicNameLabel.text = [newMusic shareInstance].playingMusic.m_musicName;
    _progressView.percent = 1 - [newMusic shareInstance].musicProgressFloat;
    _dianImageView.transform=CGAffineTransformMakeRotation(-2*M_PI*[newMusic shareInstance].musicProgressFloat);
}
- (IBAction)preMusic:(id)sender {
    
    [self set_isAdd];
    
    
    //    if (![UserManager sharedInstance].user.isLogined)
    //    {
    //        [UIUtil showQuestion:L(@"NeedToLogin") title:nil delegate:self];
    //        return;
    //    }
    if ([newMusic shareInstance].isSpeaking) {
        //        _chatTableView.hidden = YES;
        //        helpButton.hidden = YES;
        //        [[KDXFvoiceManager shareInstance]back];
        //        isSpeak = NO;
        [newMusic shareInstance].isSpeaking = NO;
        //        double delayInSeconds = 0.3f;
        //        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
        //                       {
        //                           [circleButton setImage:[UIImage imageNamed:@"主界面_语音_N.png"] forState:UIControlStateNormal];
        //                       });
        [[newMusic shareInstance]resumeMusicState];
    }
    [[newMusic shareInstance]musicPre];
    
}
- (IBAction)nextMusic:(id)sender {
    
    [self set_isAdd];
    
//    if (![UserManager sharedInstance].user.isLogined)
//    {
//        [UIUtil showQuestion:L(@"NeedToLogin") title:nil delegate:self];
//        return;
//    }
    if ([newMusic shareInstance].isSpeaking) {
//        _chatTableView.hidden = YES;
//        helpButton.hidden = YES;
//        [[KDXFvoiceManager shareInstance]back];
//        isSpeak = NO;
        [newMusic shareInstance].isSpeaking = NO;
//        double delayInSeconds = 0.3f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                       {
//                           [circleButton setImage:[UIImage imageNamed:@"主界面_语音_N.png"] forState:UIControlStateNormal];
//                       });
        [[newMusic shareInstance]resumeMusicState];
    }
    [[newMusic shareInstance]musicNext];
  
}
- (IBAction)playOrPause:(id)sender {
//    if (![UserManager sharedInstance].user.isLogined)
//    {
//        [UIUtil showQuestion:L(@"NeedToLogin") title:nil delegate:self];
//        return;
//    }
    
    if ([newMusic shareInstance].isSpeaking) {
//        [self cancelVoice];
        [[newMusic shareInstance]musicPlay];
    }else{
        [[newMusic shareInstance]musicPlayaAndPause];
    }
    [self changePicture];
}
-(void)dealloc{
    NSLog(@"音乐celldealloc");
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
