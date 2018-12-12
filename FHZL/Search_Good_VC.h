//
//  Search_Good_VC.h
//  FHZL
//
//  Created by hk on 2018/11/26.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "RootViewController.h"
#import "Header.h"
@interface Search_Good_VC : RootViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchTopBar;
@property(nonatomic ,copy) void (^serchBlock)(NSString* searchStr);
@end
