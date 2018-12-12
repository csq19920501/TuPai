//
//  photoUserCell.h
//  FHZL
//
//  Created by hk on 2018/3/8.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface photoUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewV;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@property (weak, nonatomic) IBOutlet UILabel *reailTimeLabel;

@end
