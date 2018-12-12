//
//  UIButton+Button_Block.m
//  FHZL
//
//  Created by hk on 2018/11/26.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "UIButton+Button_Block.h"
static const char btnBlock;
@implementation UIButton (Button_Block)
@dynamic block;


-(void)setBlock:(ButtonSenderBlock)block
{
    objc_setAssociatedObject(self, &btnBlock, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
       
    [self addTarget:self action:@selector(ButtonSenderOpen) forControlEvents:(UIControlEventTouchUpInside)];
}

-(ButtonSenderBlock)block
{
       return objc_getAssociatedObject(self, &btnBlock);
}


- (void)ButtonSenderOpen
{
       if (self.block)
           {
                   self.block(self);
               }
}

+ (instancetype)quickBuildButtonWithFrame:(CGRect)frame  title:(NSString *)title  color:(UIColor *)color font:(UIFont *)font  backgroundImage:(UIImage *)backgroundImage  block:(ButtonSenderBlock)block{
       
       
       
       UIButton *btn = [[UIButton alloc] initWithFrame:frame];
        
       [btn setTitle:title forState:UIControlStateNormal];
       
       [btn setTitleColor:color forState:UIControlStateNormal];
       
       [btn.titleLabel setFont:font];
     
       
       
       [btn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
       
     
       btn.block = ^(UIButton *sender) {
               block(sender);
           };
       return btn;
}
@end
