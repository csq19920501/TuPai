//
//  GoodSetVC.h
//  FHZL
//
//  Created by hk on 2018/11/26.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "RootViewController.h"
#import "MapPhoneModel.h"
@interface GoodSetVC : RootViewController
@property (weak, nonatomic) IBOutlet UITextField *numTF;
@property (weak, nonatomic) IBOutlet UITextField *priceTF;
@property(nonatomic,strong)MapPhoneModel* mapModel;
@property(nonatomic,copy)void(^setModelBlock)(MapPhoneModel* mapModel);
@end
