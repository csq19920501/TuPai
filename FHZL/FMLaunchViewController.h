//
//  FMLaunchViewController.h
//  WeiZhong_ios
//
//  Created by haoke on 17/3/28.
//
//

#import <UIKit/UIKit.h>
#import "Header.h"
@protocol FMdele <NSObject>

-(void)sousuo;
-(void)lianjie;
-(void)duankai;

@end

@interface FMLaunchViewController : RootViewController

@property (weak, nonatomic) id<FMdele>delegate;

@end
