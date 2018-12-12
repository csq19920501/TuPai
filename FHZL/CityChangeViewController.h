//
//  CityChangeViewController.h
//  LianChengTong
//
//  Created by macmini on 15/7/13.
//  Copyright (c) 2015年 ___SJHY___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Header.h"
@interface CityChangeViewController : RootViewController
@property (nonatomic, copy) void (^successBlock)(NSString * addressStr);

@end
