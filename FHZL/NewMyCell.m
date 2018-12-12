//
//  NewMyCell.m
//  FHZL
//
//  Created by hk on 2018/12/10.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "NewMyCell.h"

@implementation NewMyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)collectionClick:(id)sender {
    if (self.collectionVC) {
        self.collectionVC();
    }
}
- (IBAction)saleClick:(id)sender {
    if (self.saleClick) {
        self.saleClick();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
