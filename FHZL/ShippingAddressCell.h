//
//  ShippingAddressCell.h
//  FHZL
//
//  Created by hk on 2018/12/11.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShippingAddressCell : UITableViewCell
@property (nonatomic ,copy) void (^editClick)(void);
@end
