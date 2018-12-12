//
//  NewBiaoTiVC.h
//  FHZL
//
//  Created by hk on 2018/8/29.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "RootViewController.h"
#import "MapPhoneModel.h"
typedef enum {
    AddType = 0,
    Edit,
    Look,
}NewBiaoTiType;
@interface NewBiaoTiVC : RootViewController
@property(nonatomic,assign)NewBiaoTiType enumType;
@property (nonatomic,copy) NSString *groupId;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *addShopBut;
@property(nonatomic,strong)MapPhoneModel *mapPhoneModel;
@end
