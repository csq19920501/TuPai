/*
 ============================================================================
 Name        : HotlineViewController.h
 Version     : 1.0.0
 Copyright   : 
 Description : 情感热线界面
 ============================================================================
 */

#import <UIKit/UIKit.h>
#import "ImageSingelModel.h"
#import "MapPhoneModel.h"
#import "CustomeCsqButton.h"
@protocol navcDelegate <NSObject>
@end
@interface LookPeople : UIView<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollIMageVIew;
@property(nonatomic,strong)NSArray *imageDataArray;
@property(nonatomic,strong)NSMutableArray *imageArray;
@property(nonatomic,weak)id<navcDelegate>navcDelegate;
@property (nonatomic, copy) void (^didClickPhotoButton)(int number,NSArray*imageArr);
@property (nonatomic, copy) void (^didClickNaviButton)();
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (nonatomic,strong)MapPhoneModel *detailModel;


- (id)init;
- (void)showInView:(UIView*)view;
- (void)dismiss;
- (void)showOneTFInView:(UIView*) view;
@end
@interface CSQTableHeadView : UIView
@property(nonatomic,copy)void (^backClick)();
@end

@interface CSQPreHeadView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *biaotiLabel;

@property (nonatomic, copy) void (^NavClick)();
- (id)init;
@end



@interface CSQNewBiaoTiHeadView : UIView
@property (weak, nonatomic) IBOutlet UILabel *biaoTiLabel;
@property (weak, nonatomic) IBOutlet CustomeCsqButton *shareButton;
@property (weak, nonatomic) IBOutlet CustomeCsqButton *NaviButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priseLabel;
@property (weak, nonatomic) IBOutlet UILabel *parameterLabel;



@property (nonatomic, copy) void (^shareClick)();
@property (nonatomic, copy) void (^NavClick)();
@property (nonatomic, copy) void (^editBlock)();
- (id)init;
@end
