//
//  newMusicTableViewCell.m
//  WeiZhong_ios
//
//  Created by hk on 17/9/14.
//
//
#import "Header.h"
#import "newMusicTableViewCell.h"

@implementation newMusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
//    UIView * seleView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 5, 40)];
//    seleView.backgroundColor = [UIColor blueColor];
//    [self.contentView addSubview:seleView];
//    if (selected) {
//        seleView.hidden = NO;
//    }else{
//        seleView.hidden = YES;
//    }
    if (selected) {
        _musicName.textColor = HTextColor;
        _musicSingerLabel.textColor = HTextColor;
    }else{
        _musicName.textColor = [UIColor blackColor];
        _musicSingerLabel.textColor = [UIColor blackColor];
    }
}

@end
