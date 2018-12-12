//
//  ImageSingelModel.m
//  FHZL
//
//  Created by hk on 2018/2/5.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "ImageSingelModel.h"
#import "Header.h"
@implementation ImageSingelModel
- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _ID = dict[@"id"];
        _groupId = dict[@"groupId"];
        _photoName = dict[@"photoName"];
        _path = dict[@"path"];
        _uploadDate = dict[@"uploadDate"];
        _desc = dict[@"desc"];
        _imageHeigth = kScreenWidth - 16 +6;
    }
    return self;
    
}

+ (instancetype)provinceWithDictionary:(NSDictionary *)dict

{
    return [[self alloc] initWithDictionary:dict];
}
@end
