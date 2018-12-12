//
//  NewMyContentCell.h
//  FHZL
//
//  Created by hk on 2018/12/10.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewMyContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *stateLabel;
@property (nonatomic, copy)void (^checkLogisticsClick)(void);
@end
