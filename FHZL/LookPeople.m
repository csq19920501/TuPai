/*
 ============================================================================
 Name        : HotlineViewController.m
 Version     : 1.0.0
 Copyright   : 
 Description : 情感热线界面
 ============================================================================
 */
#import "Header.h"
#import <QuartzCore/QuartzCore.h>
#import "LookPeople.h"
#import "UIUtil.h"
#import "LocalizedStringTool.h"
#import "UIButton+WebCache.h"

@interface LookPeople ()<UITextFieldDelegate>
{
}


@end

@implementation LookPeople

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"LookPeople" owner:self options:nil] objectAtIndex:0];
    _imageArray = [NSMutableArray array];
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
//  DISPATCH_ON_MAIN_THREAD((^{

    
//   }));
}
-(void)setImageDataArray:(NSArray*)imageDataArray{
    _imageDataArray = imageDataArray   ;
    _scrollIMageVIew.contentSize = CGSizeMake(60 *self.imageDataArray.count, 50);
    _scrollIMageVIew.showsHorizontalScrollIndicator = NO;
    
    for (int i = 0; i <self.imageDataArray.count; i++) {
        ImageSingelModel *model = _imageDataArray[i];
        UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton sd_setBackgroundImageWithURL:[NSURL URLWithString:model.path] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"testPicture.png"]];
        photoButton.frame = CGRectMake(60 *i, 0, 50, 50);
        [photoButton addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        photoButton.tag = 1000 + i;
        [_scrollIMageVIew addSubview:photoButton];
        [_imageArray addObject:model.path];
    }
}
- (void)showInView:(UIView*) view
{
    self.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [view addSubview:self];
}
- (void)showOneTFInView:(UIView*) view{
    self.frame = CGRectMake(0, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [view addSubview:self];
}
- (void)dismiss{
    [self removeFromSuperview];
}

- (IBAction)cancelButton:(id)sender {
    
    [self dismiss];
}
- (IBAction)NaviClick:(id)sender {
    [self dismiss];
    if (self.didClickNaviButton) {
        self.didClickNaviButton();
    }
}
- (IBAction)TwoButtonClick:(id)sender {
    self.hidden = YES;
    if (self.didClickPhotoButton) {
        self.didClickPhotoButton(0,_imageArray);
    }
}
-(void)ButtonClick:(UIButton *)but{
    int number = (int)but.tag - 1000;
    self.hidden = YES;
    if (self.didClickPhotoButton) {
        self.didClickPhotoButton(number,_imageArray);
    }
    
}
//-(void)seePhoto{
//    CSQPhotoPreviewController *selectImagePickerVc = [[CSQPhotoPreviewController alloc] init];
//    selectImagePickerVc.photos = _imageArray;
////    selectImagePickerVc.allowPickingOriginalPhoto = NO;
//
//    [self.navcDelegate presentViewController:selectImagePickerVc animated:YES completion:nil];
//}
@end


@interface CSQTableHeadView ()
@end
@implementation CSQTableHeadView
- (IBAction)backClick:(id)sender {
    if (self.backClick) {
        self.backClick();
    }
}
@end
@interface CSQPreHeadView ()
@end
@implementation CSQPreHeadView


- (IBAction)naviClick:(id)sender {
    if (self.NavClick) {
        self.NavClick();
    }
}

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"LookPeople" owner:self options:nil] objectAtIndex:2];
    _headImage.layer.masksToBounds = YES;
    _headImage.layer.cornerRadius = _headImage.width/2;
    return self;
}
@end


@interface CSQNewBiaoTiHeadView ()


@end
@implementation CSQNewBiaoTiHeadView

- (IBAction)editBlock:(id)sender {
    if (self.editBlock) {
        self.editBlock();
    }
}



- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"LookPeople" owner:self options:nil] objectAtIndex:3];
//    _headImage.layer.masksToBounds = YES;
//    _headImage.layer.cornerRadius = _headImage.width/2;
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    SDLog(@"layoutSubviews");
    [self.NaviButton afterLayoutRefreshViewWithNormalImageStr:@"列表_5_N.png" seleImageStr:@"列表_5_N.png" higligthImageStr:@"列表_5_N.png" titleStr:@"导航" numberStr:@"0" ClickBlock:^(NSInteger numberIntData){
        SDLog(@"点击导航");
        if (self.NavClick) {
            self.NavClick();
        }
    }];
    
    [self.shareButton afterLayoutRefreshViewWithNormalImageStr:@"圆角矩形1.png" seleImageStr:@"分享.png" higligthImageStr:@"圆角矩形1.png" titleStr:@"分享" numberStr:@"0" ClickBlock:^(NSInteger numberIntData){
        SDLog(@"点击分享");
        if (self.shareClick) {
            self.shareClick();
        }
    }];
}

@end
