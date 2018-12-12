//
//  PictureEditVC.h
//  FHZL
//
//  Created by hk on 2018/1/31.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "RootViewController.h"

@interface PictureEditVC2 : RootViewController
@property (weak, nonatomic) IBOutlet UITextField *biaoQianLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentLabel;


@property (nonatomic,strong)UIImage *photeImage;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (nonatomic, copy) void (^updatePictureSuccess)();
@end
