//
//  AddAddressVC.h
//  FHZL
//
//  Created by hk on 2018/12/11.
//  Copyright © 2018年 hk. All rights reserved.
//



#import "RootViewController.h"
typedef NS_ENUM(NSInteger,AddressType) {
    AddressType_add = 1,
    AddressType_exit ,
};

@interface AddAddressVC : RootViewController
@property (nonatomic, assign) AddressType addressTypeC;
@property (weak, nonatomic) IBOutlet UIView *deleBackVIew;
@end
