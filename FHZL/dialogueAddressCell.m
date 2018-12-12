//
//  dialogueAddressCell.m
//  FHZL
//
//  Created by hk on 2018/1/11.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "dialogueAddressCell.h"
#import "Header.h"
@implementation dialogueAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _numberLabel.layer.cornerRadius = 15;
    _numberLabel.layer.masksToBounds = YES;
    _numberLabel.layer.borderColor = RGB(29, 159, 249).CGColor;
    _numberLabel.layer.borderWidth = 1.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
