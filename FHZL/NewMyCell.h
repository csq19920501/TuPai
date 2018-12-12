//
//  NewMyCell.h
//  FHZL
//
//  Created by hk on 2018/12/10.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^saleOrderClick)(void);
@interface NewMyCell : UITableViewCell
@property (nonatomic, copy)void (^collectionVC)(void);
@property (nonatomic, copy)saleOrderClick saleClick;
@end
