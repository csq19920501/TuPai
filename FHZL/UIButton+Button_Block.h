//
//  UIButton+Button_Block.h
//  FHZL
//
//  Created by hk on 2018/11/26.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void(^ButtonSenderBlock) (UIButton* sender);
@interface UIButton (Button_Block)
@property(nonatomic,copy)ButtonSenderBlock block;

+ (instancetype)quickBuildButtonWithFrame:(CGRect)frame  title:(NSString *)title  color:(UIColor *)color font:(UIFont *)font  backgroundImage:(UIImage *)backgroundImage  block:(ButtonSenderBlock)block;

@end
