//
//  NewMyContentCell.m
//  FHZL
//
//  Created by hk on 2018/12/10.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "NewMyContentCell.h"

@implementation NewMyContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)checkLogisticsClick:(id)sender {
    if (self.checkLogisticsClick) {
        self.checkLogisticsClick();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
