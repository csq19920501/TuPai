//
//  MapPhoneModel.m
//  FHZL
//
//  Created by hk on 2018/2/5.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "MapPhoneModel.h"

@implementation MapPhoneModel
- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _ID = dict[@"id"];
        _userID = dict[@"userId"];
        _title = dict[@"title"];
        _x = dict[@"x"];
        _y = dict[@"y"];
        _icconid = dict[@"iconid"];//
        _groupDate = dict[@"groupDate"];
        _headPicPath = dict[@"headPicPath"];
        _note = dict[@"note"];
        _address = dict[@"address"];
        _nickName = dict[@"nickName"];
    }
    return self;
    
}

+ (instancetype)provinceWithDictionary:(NSDictionary *)dict

{
    return [[self alloc] initWithDictionary:dict];
}

@end
