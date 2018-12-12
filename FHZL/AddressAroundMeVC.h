//
//  AddressAroundMeVC.h
//  FHZL
//
//  Created by hk on 2018/2/1.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "RootViewController.h"
#import "AddressSingelModel.h"
@interface AddressAroundMeVC : RootViewController
@property(nonatomic,strong)AddressSingelModel *seleModel;
@property (nonatomic, copy) void (^didFinishPickingAddressHandle)(AddressSingelModel *model);
@end
