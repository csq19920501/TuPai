/*
 ============================================================================
 Name        : HotlineViewController.m
 Version     : 1.0.0
 Copyright   : 
 Description : 情感热线界面
 ============================================================================
 */
#import "Header.h"
#import <QuartzCore/QuartzCore.h>
#import "photoTableviewC.h"
#import "UIUtil.h"
#import "LocalizedStringTool.h"


#import "BMKClusterItem.h"
#import "photoUserCell.h"
@interface photoTableviewC ()
{
}
@property (weak, nonatomic) IBOutlet UIView *BigBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeigthConstraint;


@end

@implementation photoTableviewC

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"photoTableviewC" owner:self options:nil] objectAtIndex:0];
    
    _modelArray = [NSMutableArray array];
    [_photoTableview registerNib:[UINib nibWithNibName:@"photoUserCell" bundle:nil] forCellReuseIdentifier:@"photoUserCell"];
    _photoTableview.layer.cornerRadius = 5;
    _photoTableview.layer.masksToBounds = YES;
//    _photoTableview.bounces = NO;
    _photoTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _photoTableview.delegate = self;
    _photoTableview.dataSource = self;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [_BigBackView addGestureRecognizer:tap];
    return self;
}

- (void)showInView:(UIView*) view
{
    self.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [view addSubview:self];
}
- (void)showOneTFInView:(UIView*) view{
    self.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [view addSubview:self];
}
-(void)setH:(NSString*)str{
    if ([str isEqualToString:@"ONE"]) {
//            CGRect rect = _backView.frame;
//            rect.size.height = 291;
//            _backView.frame =  rect;
    }else if([str isEqualToString:@"TWO"]){
//        CGRect rect = _backView.frame;
//        rect.size.height = 155;
//        _backView.frame =  rect;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
//    NSLog(@"tableviewcellHeigth = %d",50);
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"tableView的数量%d",_modelArray.count);
    return _modelArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     BMKClusterItem *ClusterItem = _modelArray[indexPath.row];
     MapPhoneModel *model = ClusterItem.csqPhoneModel;

    static NSString*identifier = @"photoUserCell";
    photoUserCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.nameLabel.text = model.nickName;
    cell.reailTimeLabel.text = [UserManager getDateDisplayShortString:[model.groupDate longLongValue]];
    cell.timeLabel.text = model.title;

    if([model.icconid integerValue] == 13 || [model.icconid integerValue] == 14){
        [cell.imageViewV sd_setImageWithURL:[NSURL URLWithString:model.headPicPath] placeholderImage:[UIImage imageNamed:@"微众世界_头像0"]];
    }else{
        cell.imageViewV.image = [UIImage imageNamed:[NSString stringWithFormat:@"ui2_user_icon%ld.png",(long)[model.icconid integerValue]]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismiss];
    if (self.didClickCell) {
        BMKClusterItem *ClusterItem = _modelArray[indexPath.row];
        MapPhoneModel *model = ClusterItem.csqPhoneModel;
        _didClickCell(model);
    }
}

-(void)reloadData{
    _tableHeigthConstraint.constant = _modelArray.count >= 8?8*50:_modelArray.count*50;
    [_photoTableview reloadData];
}
- (void)dismiss{
    [self removeFromSuperview];//
}


@end
