//
//  GoodsOneTableViewCell.m
//  FHZL
//
//  Created by hk on 17/11/25.
//  Copyright © 2017年 hk. All rights reserved.
//

#import "GoodsOneTableViewCell.h"

@implementation GoodsOneTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _BuyingTime.layer.borderColor = [UIColor redColor].CGColor;
    _BuyingTime.layer.borderWidth = 0.5;
    _BuyingTime.layer.masksToBounds = YES;
    _BuyingTime.layer.cornerRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
