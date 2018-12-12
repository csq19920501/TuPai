//
//  TIPmodel.h
//  WeiZhong_ios
//
//  Created by hk on 16/9/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface TIPmodel : NSObject

@property(nonatomic,copy)NSString *keyString;
@property(nonatomic,copy)NSString *addressString;
@property(nonatomic,assign)CGFloat latitude;
@property(nonatomic,assign)CGFloat longitude;
@property(nonatomic,copy)NSString *twoCharStr;
@end
