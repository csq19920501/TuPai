/*
 ============================================================================
 Name        : HotlineViewController.h
 Version     : 1.0.0
 Copyright   : 
 Description : 情感热线界面
 ============================================================================
 */

#import <UIKit/UIKit.h>
#import "MapPhoneModel.h"

@interface photoTableviewC : UIView<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *photoTableview;
@property(nonatomic,strong)NSMutableArray *modelArray;
@property(nonatomic,copy)void (^didClickCell)(MapPhoneModel *photoModel);
- (id)init;
- (void)showInView:(UIView*)view;
- (void)dismiss;
- (void)showOneTFInView:(UIView*) view;
-(void)setH:(NSString*)str;
-(void)reloadData;
@end
