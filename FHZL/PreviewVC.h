//
//  PreviewVC.h
//  FHZL
//
//  Created by hk on 2018/2/8.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "RootViewController.h"
#import "MapPhoneModel.h"
@interface PreviewVC : RootViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableview;
@property (nonatomic,strong)MapPhoneModel *detailModel;
@property (nonatomic,strong)NSMutableArray *photoArray;
@property (nonatomic, copy) void (^deleSuccess)();
@property(nonatomic,assign)BOOL isOnlyOne;
@end
