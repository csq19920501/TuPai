//
//  DrickingClassCell.m
//  FHZL
//
//  Created by hk on 17/12/7.
//  Copyright © 2017年 hk. All rights reserved.
//

#import "DrickingClassCell.h"

@implementation DrickingClassCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _BackImageView.layer.cornerRadius = 5;
    _BackImageView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
