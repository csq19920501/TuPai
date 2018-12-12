//
//  NewBiaoTiCell.h
//  FHZL
//
//  Created by hk on 2018/8/29.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSingelModel.h"
typedef void (^cellImageClick)();
@interface NewBiaoTiCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
-(void)setModel:(ImageSingelModel*)model ImageBlock:(cellImageClick)black editBlock:(cellImageClick)editClick deleBlock:(cellImageClick)deleBlock;
@property(nonatomic,copy)cellImageClick imageClick;
@property(nonatomic,copy)cellImageClick editClick;
@property(nonatomic,copy)cellImageClick deleClick;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleButton;
@end
