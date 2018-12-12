/*
 ============================================================================
 Name        : HotlineViewController.m
 Version     : 1.0.0
 Copyright   : 
 Description : 情感热线界面
 ============================================================================
 */
#import "Header.h"
#import <QuartzCore/QuartzCore.h>
#import "ShowCarView.h"
#import "UIUtil.h"
#import "LocalizedStringTool.h"


@interface ShowCarView ()<UITextFieldDelegate>
{
}


@end

@implementation ShowCarView

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"ShowCarView" owner:self options:nil] objectAtIndex:0];
    self.macIdLable.layer.cornerRadius = 4;
    self.macIdLable.layer.masksToBounds = YES;
    
    
    return self;
}

- (void)showInView:(UIView*) view
{
    self.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [view addSubview:self];
}

- (void)showInView:(UIView*) view  withFrame:(CGRect)rect
{
    self.frame = rect;
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [view addSubview:self];
}

- (void)showOneTFInView:(UIView*) view{
    self.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [view addSubview:self];
    
//    CGRect rect = _backView.frame;
//    rect.size.height = 150;
//    _backView.frame =  rect;
//    _textFile2.hidden = YES;
//    _textFile3.hidden = YES;
    
}
- (void)dismiss{
    [self removeFromSuperview];
}
- (IBAction)openView:(id)sender {
//    UIButton *but = sender;
//    but.selected = !but.selected;
//    if (but.selected) {
//        
//    }
    NSLog(@"偷偷的执行方法");
}

- (IBAction)cancelButton:(id)sender {
    
    [self dismiss];
}

- (IBAction)phoneButtonClicked:(id)sender
{
    
    
    [self dismiss];
}

@end
