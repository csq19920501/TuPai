//
//  CSQ_titleImageButton.m
//  FHZL
//
//  Created by hk on 2018/11/23.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "CSQ_titleImageButton.h"

#define margin 5
@implementation CSQ_titleImageButton
-(instancetype)init{
    self = [super init];
    if (self) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat butW = self.width;
    CGFloat butH = self.height;
    //获取图片的宽度和高度
    CGFloat imageW = self.imageView.width;
    CGFloat imageH = self.imageView.height;
    
    //布局图片
    CGFloat imageX =  butW - imageW;
    CGFloat imageY = (butH - imageH) * 0.5;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    //首先布局文字
    self.titleLabel.left = 0;
    self.titleLabel.width = butW - imageW - margin;
}
@end
