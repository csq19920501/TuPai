//
//  DialogueVC.m
//  FHZL
//
//  Created by hk on 2018/1/11.
//  Copyright © 2018年 hk. All rights reserved.
//
#define buttonHeigth 80

#import "SDChatMessage.h"
#import "SDChatDetail.h"
#import "SDChatDetailFrame.h"
#import "SDChatDetailTableViewCell.h"
#import "SDChat.h"
#import "SDChatDetailTableView.h" //列表


#import "DialogueVC.h"
#import "KDXFvoiceManager.h"
#import "newMusic.h"
#import "NewMusicVC.h"
#import "helpCell.h"
@interface DialogueVC ()<ChangeChat,UITableViewDelegate,UITableViewDataSource,ChangeEnable>
{
    int circleClickInt; //利用block宏变量和局部变量的不同变化情况区分 是否reture掉 只有最后一次才能生效
    BOOL isCanChangeMode; //和上面的合作使用避免多次设置模式导致存储错误模式
    BOOL OldSaveIsChanged; //旧存储模式是否被强行改变过
    MusicState OldState;
    
    BOOL isSpeak;
    BOOL isShowTableView;
    int isPictureInt;
    BOOL isDismiss;
    BOOL isCircleClickCan;
    
    __weak IBOutlet UIButton *circleButton;
//    UIButton *circleButton;
    UIButton *helpButton;
}
@property (weak, nonatomic) IBOutlet UIImageView *soundImage;
@property (nonatomic,strong)NSMutableArray *chatDataArr; //消息数据源
@property (weak, nonatomic) IBOutlet UITableView *helpTableview;
@property (nonatomic,strong)SDChatDetailTableView *chatTableView;
@end

@implementation DialogueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"语音";
    
    [KDXFvoiceManager shareInstance].ChangeChatDele = self;
    [newMusic shareInstance].ChangeDele = self;
    
    circleClickInt = 0;
    isCanChangeMode = YES;
    isSpeak = NO;
    isCircleClickCan = YES;
    _chatDataArr = [NSMutableArray array];
    [self setViews];
    
    [self circleClick];
}
-(void)setViews{
    _chatTableView = [[SDChatDetailTableView alloc] initWithFrame:CGRectMake(0,kTopHeight, kScreenWidth, (kScreenHeight - kTopHeight)/3) style:UITableViewStylePlain];
    [self.view addSubview:_chatTableView];
//    _chatTableView.hidden = NO;
    self.chatTableView.dataArray =self.chatDataArr;
    [self.chatTableView reloadData];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenTableView)];
    [self.chatTableView addGestureRecognizer:tap];
    
    [KDXFvoiceManager shareInstance].myTableView.frame = CGRectMake(0,  SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT - _chatTableView.bottom - buttonHeigth);
    [self.view addSubview:[KDXFvoiceManager shareInstance].myTableView];
    
    [_helpTableview registerNib:[UINib nibWithNibName:@"helpCell" bundle:nil] forCellReuseIdentifier:@"helpCell"];
    _helpTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)goToMusicVC:(BOOL)isGotoNet{
    NewMusicVC *vc = [[NewMusicVC alloc]init];
    if (isGotoNet) {
        vc.isNet = YES;
    }else{
        [[newMusic   shareInstance]musicPlay];
    }
    
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [viewControllers removeLastObject];
    if (![viewControllers containsObject:vc])
    {
        [viewControllers addObject:vc];
    }
    [self.navigationController setViewControllers:viewControllers animated:NO];
    
//    [self.navigationController pushViewController:vc animated:YES];
}
-(void)cancelVoice{
    isPictureInt = 0;
    if (isSpeak) {
//        _chatTableView.hidden = YES;
        helpButton.hidden = YES;
        [[KDXFvoiceManager shareInstance]back];
        isSpeak = NO;
        [newMusic shareInstance].isSpeaking = NO;
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [circleButton setImage:[UIImage imageNamed:@"主界面_语音_N.png"] forState:UIControlStateNormal];
                           [_soundImage setImage:[UIImage imageNamed:@"voicenaci_sound0.png"]];
                       });
        [KDXFvoiceManager shareInstance].myTableView.frame = CGRectMake(0,  SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT - _chatTableView.bottom - buttonHeigth);
      
        isShowTableView = NO;
        [[newMusic shareInstance]resumeMusicState];
    }
}
-(void)cancelVoiceNoVoice{
    isPictureInt = 0;
    if (isSpeak) {
//        _chatTableView.hidden = YES;
        helpButton.hidden = YES;
        [[KDXFvoiceManager shareInstance]back];
        isSpeak = NO;
        [newMusic shareInstance].isSpeaking = NO;
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [circleButton setImage:[UIImage imageNamed:@"主界面_语音_N.png"] forState:UIControlStateNormal];
                           [_soundImage setImage:[UIImage imageNamed:@"voicenaci_sound0.png"]];
                       });
        [KDXFvoiceManager shareInstance].myTableView.frame = CGRectMake(0,  SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT - _chatTableView.bottom - buttonHeigth);
        isShowTableView = NO;
    }
}
- (IBAction)cirlceButtonClick:(id)sender {
    [self circleClick];
//     [[KDXFvoiceManager shareInstance]firstStep];
}

-(void)circleClick{
    isPictureInt = 0;
    if (!isSpeak) {
        if (![KDXFvoiceManager shareInstance].isNetOK) {
            [UIUtil showToast:@"网络未连接，请稍候再试" inView:self.view];
            return;
        }
        [newMusic shareInstance].isSpeaking = YES;
        if (isCanChangeMode) {
            [[newMusic shareInstance]SaveMusicState];
            NSLog(@"[newMusic shareInstance].saveMusicState前 = %ld",[newMusic shareInstance].saveMusicState);
            [[newMusic shareInstance].globalManager setMode:MODE_A2DP];
            isCanChangeMode = NO;
        }
        circleClickInt++;
        int CircleNumber = circleClickInt;
        double delayInSeconds = 0.3f;
        if ([KDXFvoiceManager shareInstance].isLink) {
            if (IOS_VERSION >= 10.0f) {
                delayInSeconds = 1.0f;
            }else{
                delayInSeconds = 0.3f;
            }
            
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           
                           if (CircleNumber != circleClickInt) {
                               return ;
                           }
                           isCanChangeMode = YES;
//                           [self hiddenHelpView];
//                           _chatTableView.hidden = NO;
                           helpButton.hidden = NO;
                           [[KDXFvoiceManager shareInstance]firstStep];
                           [circleButton setImage:[UIImage imageNamed:@"main_mymic.png"] forState:UIControlStateNormal];
                           isSpeak = YES;
                       });
    }else{
/*
        helpButton.hidden = YES;
        [circleButton setImage:[UIImage imageNamed:@"主界面_语音_N.png"] forState:UIControlStateNormal];
        [_soundImage setImage:[UIImage imageNamed:@"voicenaci_sound0.png"]];
        [[KDXFvoiceManager shareInstance]back];
        isSpeak = NO;
        [newMusic shareInstance].isSpeaking = NO;
        
        MusicState thisTimeState = [newMusic shareInstance].saveMusicState;
        
        if (OldSaveIsChanged) {
            if ( thisTimeState == netPlay || thisTimeState == netPause) {
                [newMusic shareInstance].saveMusicState = OldState;
            }
        }
        OldState = thisTimeState;
        
        CSQ_DISPATCH_AFTER(0.1f,^{
            [[newMusic shareInstance]resumeMusicState];
        })
        
        
        double delayInSeconds = 0.2f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [circleButton setImage:[UIImage imageNamed:@"主界面_语音_N.png"] forState:UIControlStateNormal];
                           [_soundImage setImage:[UIImage imageNamed:@"voicenaci_sound0.png"]];
                           
                       });
        if ( thisTimeState == netPlay || thisTimeState == netPause) {
            double delayInSeconds2 = 1.0f;
            dispatch_time_t popTime2 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds2 * NSEC_PER_SEC));
            dispatch_after(popTime2, dispatch_get_main_queue(), ^(void)
                           {
                               OldSaveIsChanged = YES;
                               //                           if ([newMusic shareInstance].isSpeaking) {
                               [newMusic shareInstance].saveMusicState = thisTimeState;
                               NSLog(@"[newMusic shareInstance].saveMusicState后1 = %ld",thisTimeState);
                               //                           }
                           });
            double delayInSeconds3 = 3.0f;
            dispatch_time_t popTime3 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds3 * NSEC_PER_SEC));
            dispatch_after(popTime3, dispatch_get_main_queue(), ^(void)
                           {
                               OldSaveIsChanged = NO;
                               //                           if ([newMusic shareInstance].isSpeaking) {
                               [newMusic shareInstance].saveMusicState = thisTimeState;
                               NSLog(@"[newMusic shareInstance].saveMusicState后2 = %ld",thisTimeState);
                               //                           }
                           });
            
        }
 */
        [[KDXFvoiceManager shareInstance]firstStep];
        [circleButton setImage:[UIImage imageNamed:@"main_mymic.png"] forState:UIControlStateNormal];
        isSpeak = YES;
        [newMusic shareInstance].isSpeaking = YES;
        [KDXFvoiceManager shareInstance].myTableView.frame = CGRectMake(0,  SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT - _chatTableView.bottom - buttonHeigth);
        isShowTableView = NO;
    }
}
-(void)wakeUpVoice{
    isPictureInt = 0;
    [[newMusic shareInstance]SaveMusicState];
    [[newMusic shareInstance].globalManager setMode:MODE_A2DP];
//    _chatTableView.hidden = NO;
    helpButton.hidden = NO;
    [[KDXFvoiceManager shareInstance]firstStep];
    [circleButton setImage:[UIImage imageNamed:@"main_mymic.png"] forState:UIControlStateNormal];
    isSpeak = YES;
    [newMusic shareInstance].isSpeaking = YES;
}
-(void)changeFirstStr:(NSString *)str :(BOOL)isDele{
    //isDele 左边  else 右边
    NSLog(@"strstrstrstrstrstrstrstrstrstrstrstr %@",str);
    if (isDele) {

        NSDictionary *dic = @{@"msg":str,@"msgID":@"1",@"sender":@"0",@"sendTime":@"",@"msgType":@"0",@"staffName":@"11",@"staffID":@"0"};
        SDChatMessage *msg =[SDChatMessage chatMessageWithDic:dic];
        SDChatDetail *chat =[SDChatDetail sd_chatWith:msg];
        SDChatDetailFrame *chatFrame =[[SDChatDetailFrame alloc]init];
        chatFrame.chat=chat;
        [_chatDataArr addObject:chatFrame];
    }else{
        NSDictionary *dic = @{@"msg":str,@"msgID":@"1",@"sender":@"1",@"sendTime":@"",@"msgType":@"0",@"staffName":@"11",@"staffID":@"0"};
        SDChatMessage *msg =[SDChatMessage chatMessageWithDic:dic];
        SDChatDetail *chat =[SDChatDetail sd_chatWith:msg];
        SDChatDetailFrame *chatFrame =[[SDChatDetailFrame alloc]init];
        chatFrame.chat=chat;
        [_chatDataArr addObject:chatFrame];
    }
    [self.chatTableView reloadData];
    _chatTableView.hidden = NO;
    helpButton.hidden = NO;
    [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
-(void)changeSoundImage:(NSInteger)voiceLevel{
    NSLog(@"voiceLevel =   %ld ",(long)voiceLevel);
    if (voiceLevel == 0) {
        [_soundImage setImage:[UIImage imageNamed:@"voicenaci_sound0.png"]];
        [circleButton setImage:[UIImage imageNamed:@"main_mymic.png"] forState:UIControlStateNormal];
    }else{
        int i = (int)voiceLevel/3;
        if (i == 0) {
            i = 1;
        }
        [_soundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"voicenaci_sound%ld.png",(long)voiceLevel]]];
        [circleButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"主界面_%d.png",i]] forState:UIControlStateNormal];
    }
    if (!isSpeak) {
//        _chatTableView.hidden = YES;
        helpButton.hidden = YES;
        [[KDXFvoiceManager shareInstance]back];
        isSpeak = NO;
        [newMusic shareInstance].isSpeaking = NO;
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [circleButton setImage:[UIImage imageNamed:@"主界面_语音_N.png"] forState:UIControlStateNormal];
                           [_soundImage setImage:[UIImage imageNamed:@"voicenaci_sound0.png"]];
                       });
        [KDXFvoiceManager shareInstance].myTableView.frame = CGRectMake(0,  SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT - _chatTableView.bottom - buttonHeigth);
        isShowTableView = NO;
    }
}
-(void)pushTableview{
    [KDXFvoiceManager shareInstance].myTableView.frame = CGRectMake(0,  _chatTableView.bottom, SCREENWIDTH, SCREENHEIGHT - _chatTableView.bottom - buttonHeigth);
    isShowTableView = YES;
}
-(void)hiddenTableView{
    if (isShowTableView) {
        [[KDXFvoiceManager shareInstance]firstStep];
        [circleButton setImage:[UIImage imageNamed:@"main_mymic.png"] forState:UIControlStateNormal];
        isSpeak = YES;
        [newMusic shareInstance].isSpeaking = YES;
    }
    [KDXFvoiceManager shareInstance].myTableView.frame = CGRectMake(0,  SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT - _chatTableView.bottom - buttonHeigth);
    isShowTableView = NO;
}
-(void)removeSpeakData{
    [_chatDataArr removeAllObjects];
}
-(void)showLeft{
    [[KDXFvoiceManager shareInstance]back];
    [newMusic shareInstance].isSpeaking = NO;
    [[newMusic shareInstance]resumeMusicState];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 60;
    }else{
        return 40;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"helpCell";
//    NSArray *helpArray = @[@"您可以这样说",@"导航到深圳北站",@"打电话给小红",@"来一首小苹果",@"来一首刘德华的歌曲",];
    NSArray *helpArray = @[@"您可以这样说",@"导航到深圳北站",@"打电话给小红"];
    helpCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = helpArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont systemFontOfSize:19];
    }else{
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
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
