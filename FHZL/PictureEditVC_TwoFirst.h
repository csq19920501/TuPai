//
//  PictureEditVC.h
//  FHZL
//
//  Created by hk on 2018/1/31.
//  Copyright © 2018年 hk. All rights reserved.
//
//拍完照片直接新增图标标题
#import "RootViewController.h"
typedef enum {
    PictureEditV_New = 0,
    PictureEditV_Add,
    PictureEditV_Edit,
}PictureEditV_Type;
@interface PictureEditVC_TwoFirst : RootViewController
@property(nonatomic,assign)PictureEditV_Type pictureEditV_Type;
@property (weak, nonatomic) IBOutlet UIImageView * _Nullable photoImageView;


@property (weak, nonatomic) IBOutlet UITextField * _Nullable biaoQianLabel;
@property (weak, nonatomic) IBOutlet UITextView * _Nullable contentLabel;
@property (weak, nonatomic) IBOutlet UIView *pictureBackView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationButtonConstant;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationButtonWidth;
@property (nonatomic,strong,nonnull)UIImage *photoImage;
@property (nonatomic,copy) NSString * _Nullable titleStr;
@property (nonatomic,copy) NSString * _Nullable contentStr;
@property (nonatomic,copy) NSString * _Nullable groupId;
@property (nonatomic,copy) NSString * _Nullable itemId;
@property (nonatomic, copy) void (^ _Nullable updatePictureSuccess)();
@end
