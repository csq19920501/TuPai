//
//  WMTimeLineViewController1.m
//  WeChat
//
//  Created by zhengwenming on 2017/9/21.
//  Copyright © 2017年 zhengwenming. All rights reserved.
//

#import "WMTimeLineViewController1.h"
#import "MessageCell1.h"
#import "CommentCell1.h"
#import "FriendInfoModel.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"

@interface WMTimeLineViewController1 ()<UITableViewDelegate, UITableViewDataSource, MessageCellDelegate>
//@property (nonatomic, strong) ChatKeyBoard *chatKeyBoard;
@property (nonatomic, assign) CGFloat history_Y_offset;//记录table的offset.y
@property (nonatomic, assign) CGFloat seletedCellHeight;//记录点击cell的高度，高度由代理传过来
@property (nonatomic, assign) BOOL isShowKeyBoard;//记录点击cell的高度，高度由代理传过来

//专门用来回复选中的cell的model
@property (nonatomic, strong) CommentInfoModel1 *replayTheSeletedCellModel;


@property (nonatomic, assign) BOOL needUpdateOffset;//控制是否刷新table的offset

@property (nonatomic,copy)NSIndexPath *currentIndexPath;



@end

@implementation WMTimeLineViewController1
- (void)chatKeyBoardSendText:(NSString *)text{
    MessageInfoModel1 *messageModel = self.dataSource[self.currentIndexPath.row];
    messageModel.shouldUpdateCache = YES;
    
    //创建一个新的CommentModel,并给相应的属性赋值，然后加到评论数组的最后，reloadData
    CommentInfoModel1 *commentModel = [[CommentInfoModel1 alloc]init];
    commentModel.commentUserName = @"文明";
    commentModel.commentUserId = @"274";
    commentModel.commentPhoto = @"http://q.qlogo.cn/qqapp/1104706859/189AA89FAADD207E76D066059F924AE0/100";
    commentModel.commentByUserName = self.replayTheSeletedCellModel?self.replayTheSeletedCellModel.commentUserName:@"";
    commentModel.commentId = [NSString stringWithFormat:@"%i",[self getRandomNumber:100 to:1000]];
    commentModel.commentText = text;
    [messageModel.commentModelArray addObject:commentModel];
    
    messageModel.shouldUpdateCache = YES;
    [self reloadCellHeightForModel:messageModel atIndexPath:self.currentIndexPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //注册键盘出现NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    //注册键盘隐藏NSNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [self registerCellWithClass:@"MessageCell1" tableView:self.tableView];
    self.tableView.bounces = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_group_t group =  dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getTestData1];// 执行1个耗时的异步操作
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //添加timer需要放在主线程
        [self.tableView reloadData]; //等前面的异步操作都执行完毕后，回到主线程...
    });
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell1" forIndexPath:indexPath];
    cell.delegate = self;
    __weak __typeof(self) weakSelf= self;
    
    MessageInfoModel1 *model = self.dataSource[indexPath.row];
    [cell configCellWithModel:model indexPath:indexPath];
    //评论
    cell.CommentBtnClickBlock = ^(UIButton *commentBtn,NSIndexPath * indexPath)
    {
        
        if (weakSelf.isShowKeyBoard) {
            [weakSelf.view endEditing:YES];
            return ;
        }
        
        //不是点击cell进行回复，则置空replayTheSeletedCellModel，因为这个时候是点击评论按钮进行评论，不是回复某某某
        weakSelf.replayTheSeletedCellModel = nil;
        weakSelf.seletedCellHeight = 0.0;
        weakSelf.needUpdateOffset = YES;
//        weakSelf.chatKeyBoard.placeHolder = [NSString stringWithFormat:@"评论 %@",model.userName];
        weakSelf.history_Y_offset = [commentBtn convertRect:commentBtn.bounds toView:[UIApplication sharedApplication].keyWindow].origin.y;
        weakSelf.currentIndexPath = indexPath;
    };
    //更多
    cell.MoreBtnClickBlock = ^(UIButton *moreBtn,NSIndexPath * indexPath)
    {
        if (weakSelf.isShowKeyBoard) {
            [weakSelf.view endEditing:YES];
            return ;
        }
        model.isExpand = !model.isExpand;
        model.shouldUpdateCache = YES;
        [weakSelf.tableView reloadData];
    };
    
    //点击九宫格
    cell.tapImageBlock = ^(NSInteger index,NSArray *dataSource){
        if (weakSelf.isShowKeyBoard) {
            [weakSelf.view endEditing:YES];
            return ;
        }
        
        WMPhotoBrowser *browser = [WMPhotoBrowser new];
        browser.dataSource = dataSource.mutableCopy;
        browser.downLoadNeeded = YES;
        browser.currentPhotoIndex = index;
        [weakSelf presentViewController:browser animated:YES completion:^{
            
        }];
    };
    
    
    //点击文字
    cell.TapTextBlock=^(UILabel *desLabel){
        if (weakSelf.isShowKeyBoard) {
            [weakSelf.view endEditing:YES];
            return ;
        }
    };
    
    //点击点赞的人名字
    cell.tapNameBlock = ^(FriendInfoModel *friendModel) {
        if (weakSelf.isShowKeyBoard) {
            [weakSelf.view endEditing:YES];
            return ;
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:friendModel.userName message:[NSString stringWithFormat:@"id = %@",friendModel.userId] delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageInfoModel1 *messageModel = self.dataSource[indexPath.row];
    CGFloat h = [MessageCell1 hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
        MessageCell1 *cell = (MessageCell1 *)sourceCell;
        [cell configCellWithModel:messageModel indexPath:indexPath];
    } cache:^NSDictionary *{
        NSDictionary *cache = @{kHYBCacheUniqueKey : messageModel.cid,
                                kHYBCacheStateKey  : @"",
                                kHYBRecalculateForStateKey : @(messageModel.shouldUpdateCache)};
        messageModel.shouldUpdateCache = NO;
        return cache;
    }];
    return h;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isShowKeyBoard) {
        [self.view endEditing:YES];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
#pragma mark - passCellHeightWithModel
-(void)passCellHeight:(CGFloat)cellHeight commentModel:(CommentInfoModel1 *)commentModel commentCell:(CommentCell1 *)commentCell messageCell:(MessageCell1 *)messageCell{
    if (self.isShowKeyBoard) {
        [self.view endEditing:YES];
        return ;
    }
    self.needUpdateOffset = YES;
    self.replayTheSeletedCellModel = commentModel;
    self.currentIndexPath = [self.tableView indexPathForCell:messageCell];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    self.chatKeyBoard.placeHolder = [NSString stringWithFormat:@"回复 %@",commentModel.commentUserName];
    self.history_Y_offset = [commentCell convertRect:commentCell.bounds toView:window].origin.y;
    self.seletedCellHeight = cellHeight;
}
- (void)reloadCellHeightForModel:(MessageInfoModel1 *)model atIndexPath:(NSIndexPath *)indexPath{
    model.shouldUpdateCache = YES;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark
#pragma mark keyboardWillShow
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.isShowKeyBoard = YES;
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    __block  CGFloat keyboardHeight = [aValue CGRectValue].size.height;
    if (keyboardHeight==0) {
        //解决搜狗输入法三次调用此方法的bug、
        //        IOS8.0之后可以安装第三方键盘，如搜狗输入法之类的。
        //        获得的高度都为0.这是因为键盘弹出的方法:- (void)keyBoardWillShow:(NSNotification *)notification需要执行三次,你如果打印一下,你会发现键盘高度为:第一次:0;第二次:216:第三次:282.并不是获取不到高度,而是第三次才获取真正的高度.
        return;
    }
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    CGFloat delta = 0.0;
    if (self.seletedCellHeight){//点击某行row，进行回复某人
        delta = self.history_Y_offset - ([UIApplication sharedApplication].keyWindow.bounds.size.height - keyboardHeight-self.seletedCellHeight-40-2);
    }else{//点击评论按钮
        delta = self.history_Y_offset - ([UIApplication sharedApplication].keyWindow.bounds.size.height - keyboardHeight-40-24-10);//24为评论按钮高度，10为评论按钮上部的5加评论按钮下部的5
    }
    CGPoint offset = self.tableView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    if (self.needUpdateOffset) {
        [self.tableView setContentOffset:offset animated:YES];
    }
}
#pragma mark
#pragma mark keyboardWillHide
- (void)keyboardWillHide:(NSNotification *)notification {
    self.isShowKeyBoard = NO;
    self.needUpdateOffset = NO;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__FUNCTION__);
}

@end
