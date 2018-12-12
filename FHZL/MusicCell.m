//
//  MusicCell.m
//  WeiZhong_ios
//
//  Created by haoke on 17/3/13.
//
//

#import "MusicCell.h"

@implementation MusicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.songNameLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
