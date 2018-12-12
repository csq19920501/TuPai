//
//  photoUserCell.m
//  FHZL
//
//  Created by hk on 2018/3/8.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "photoUserCell.h"

@implementation photoUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _imageViewV.layer.cornerRadius = _imageViewV.frame.size.width/2;
    _imageViewV.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
