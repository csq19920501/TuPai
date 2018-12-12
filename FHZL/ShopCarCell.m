//
//  ShopCarCell.m
//  FHZL
//
//  Created by hk on 2018/12/8.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "ShopCarCell.h"

@implementation ShopCarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backVIew.layer.cornerRadius = 8;
    self.backVIew.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
