//
//  MapPhoneModel.h
//  FHZL
//
//  Created by hk on 2018/2/5.
//  Copyright © 2018年 hk. All rights reserved.
//
//地图用户模型
#import <Foundation/Foundation.h>

@interface MapPhoneModel : NSObject
@property(nonatomic,copy)NSString *userID;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *x;
@property(nonatomic,copy)NSString *y;
@property(nonatomic,copy)NSString *icconid;
@property(nonatomic,copy)NSString *headPicPath;
@property(nonatomic,copy)NSString *address;
@property(nonatomic,copy)NSString *nickName;

@property(nonatomic,copy)NSString *groupDate;//
@property(nonatomic,copy)NSString *note;
@property(nonatomic,copy)NSString *ID;
@property(nonatomic,assign)NSInteger tagNumber;

@property(nonatomic,copy)NSString *goodPrise;
@property(nonatomic,copy)NSString *goodParameter;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (instancetype)provinceWithDictionary:(NSDictionary *)dict;
@end
