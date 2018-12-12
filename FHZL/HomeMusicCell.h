//
//  HomeMusicCell.h
//  FHZL
//
//  Created by hk on 17/12/5.
//  Copyright © 2017年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressView.h"
@interface HomeMusicCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellBackImageVIew;
@property (weak, nonatomic) IBOutlet UIButton *preMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *nextMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *PlayOrPauseButton;
@property (weak, nonatomic) IBOutlet UIImageView *MusicImageView;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet ProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *dianImageView;



@property(nonatomic,strong)NSTimer * Timer;

@property(nonatomic,assign)BOOL isAdd;
@property(nonatomic,assign)BOOL isReload;

@end
