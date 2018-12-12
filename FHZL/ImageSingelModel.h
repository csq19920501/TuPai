//
//  ImageSingelModel.h
//  FHZL
//
//  Created by hk on 2018/2/5.
//  Copyright © 2018年 hk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSingelModel : NSObject
@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,copy)NSString *photoName;
@property(nonatomic,copy)NSString *path;
@property(nonatomic,copy)NSString *uploadDate;
@property(nonatomic,copy)NSString *desc;
@property(nonatomic,assign)float imageHeigth;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
+ (instancetype)provinceWithDictionary:(NSDictionary *)dict;
@end
