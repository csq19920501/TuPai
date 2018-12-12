//
//  GoodsOneTableViewCell.h
//  FHZL
//
//  Created by hk on 17/11/25.
//  Copyright © 2017年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsOneTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *backVIew;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *NewPrice;
@property (weak, nonatomic) IBOutlet UILabel *OldPrice;
@property (weak, nonatomic) IBOutlet UILabel *BuyingTime;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *InStockNumber;
@property (weak, nonatomic) IBOutlet UILabel *SalesNumber;
@end
