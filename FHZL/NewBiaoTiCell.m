//
//  NewBiaoTiCell.m
//  FHZL
//
//  Created by hk on 2018/8/29.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "NewBiaoTiCell.h"
#import "UIImageView+WebCache.h"

@implementation NewBiaoTiCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.pictureView.layer.cornerRadius = 5;
    self.pictureView.layer.masksToBounds = YES;
    self.pictureView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTap)];
    [self.pictureView addGestureRecognizer:tap];
}
-(void)setModel:(ImageSingelModel*)model ImageBlock:(cellImageClick)black editBlock:(cellImageClick)editBlock deleBlock:(cellImageClick)deleBlock  {
    [self.pictureView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:[UIImage imageNamed:@"人工导航_弹出栏_列表下载_N"]];
    self.descriptionLabel.text = model.desc;
    self.imageClick = black;
    self.deleClick = deleBlock;
    self.editClick = editBlock;
}
-(void)imageTap{
    if (self.imageClick) {
        self.imageClick();
    }
}
- (IBAction)editClick:(id)sender {
    if (self.editClick) {
        self.editClick();
    }
}
- (IBAction)deleClick:(id)sender {
    if (self.deleClick) {
        self.deleClick();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
