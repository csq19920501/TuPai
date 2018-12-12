//
//  PictureEditVC.h
//  FHZL
//
//  Created by hk on 2018/1/31.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "RootViewController.h"

@interface PictureEditVC : RootViewController
@property (weak, nonatomic) IBOutlet UITextField *biaoQianLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *pictureBackView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationButtonConstant;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationButtonWidth;
@property (nonatomic,strong)UIImage *photeImage;
@property (nonatomic, copy) void (^updatePictureSuccess)();
@end
